# SPDX-License-Identifier: Apache-2.0

from typing import Callable, List, Optional, Tuple, Union

import torch

# from vllm import _custom_ops as ops
import torch.version
from vllm.model_executor.custom_ops import scaled_fp8_quant

# Input scaling factors are no longer optional in _scaled_mm starting
# from pytorch 2.5. Allocating a dummy tensor to pass as input_scale
TORCH_DEVICE_IDENTITY = None


def cutlass_fp8_supported() -> bool:
    capability = torch.cuda.get_device_capability()
    capability = capability[0] * 10 + capability[1]
    cuda_version = int(float(torch.version.cuda) * 1000)
    if capability >= 90:
        return cuda_version >= 12000
    elif capability >= 89:
        return cuda_version >= 12040
    return False


def cutlass_block_fp8_supported() -> bool:
    capability = torch.cuda.get_device_capability()
    capability = capability[0] * 10 + capability[1]
    cuda_version = int(float(torch.version.cuda) * 1000)
    if capability >= 90 and capability < 100:
        return cuda_version >= 12000
    return False


def cutlass_group_gemm_supported() -> bool:
    capability = torch.cuda.get_device_capability()
    capability = capability[0] * 10 + capability[1]
    cuda_version = int(float(torch.version.cuda) * 1000)

    return capability == 90 and cuda_version >= 12030


CUTLASS_FP8_SUPPORTED = cutlass_fp8_supported()
CUTLASS_BLOCK_FP8_SUPPORTED = cutlass_block_fp8_supported()


def per_tensor_dequantize(
        tensor: torch.Tensor, inv_scale: Union[float,
                                               torch.Tensor]) -> torch.Tensor:
    fake_qweight = tensor.to(torch.float16)
    dq_weight = fake_qweight * inv_scale
    return dq_weight


def all_close_1d(x: torch.Tensor) -> bool:
    assert len(x.shape) == 1
    return all(torch.allclose(x[0], x[i]) for i in range(x.shape[0]))


def requantize_with_max_scale(
        weight: torch.Tensor, weight_scale: torch.Tensor,
        logical_widths: List[int]) -> Tuple[torch.Tensor, torch.Tensor]:
    # Max scale to be used for requanitzation.
    max_w_scale = weight_scale.max()

    # QKV / MLP is fused in the on disk checkpoint if any of the
    # weight scales are still set to the default since we initialize
    # N weight scales for N shards but we only load 1 weight scale
    # from disk in this case. Skip requantization in this case (since)
    # we already are quantized with the single scale.
    # * Sample Model: nm-testing/Phi-3-mini-128k-instruct-FP8
    unfused_module_in_checkpoint = (weight_scale[-1]
                                    > torch.finfo(torch.float8_e4m3fn).min)

    # If unfused checkpoint, need requanize with the single scale.
    if unfused_module_in_checkpoint:
        start = 0
        for idx, logical_width in enumerate(logical_widths):
            end = start + logical_width
            weight_dq = per_tensor_dequantize(weight[start:end, :],
                                              weight_scale[idx])
            weight[start:end, :], _ = scaled_fp8_quant(
                weight_dq, max_w_scale)
            start = end

    return max_w_scale, weight


def maybe_create_device_identity():
    # Allocate dummy ones tensor for torch._scaled_mm
    global TORCH_DEVICE_IDENTITY
    if TORCH_DEVICE_IDENTITY is None:
        TORCH_DEVICE_IDENTITY = torch.ones(1, dtype=torch.float32)


def torch_per_tensor_w8a8_scaled_mm(*, qinput: torch.Tensor,
                                    weight: torch.Tensor,
                                    out_dtype: torch.dtype,
                                    scale_a: torch.Tensor,
                                    scale_b: torch.Tensor, bias: torch.Tensor,
                                    input_2d: torch.Tensor,
                                    output_shape: List) -> torch.Tensor:
    output = torch._scaled_mm(qinput,
                              weight,
                              out_dtype=out_dtype,
                              scale_a=scale_a,
                              scale_b=scale_b,
                              bias=bias)
    # A fix for discrepancy in scaled_mm which returns tuple
    # for torch < 2.5 and a single value in torch >= 2.5
    if type(output) is tuple and len(output) == 2:
        output = output[0]

    return torch.narrow(output, 0, 0, input_2d.shape[0]).view(*output_shape)


def torch_channelwise_w8a8_scaled_mm(*, qinput: torch.Tensor,
                                     weight: torch.Tensor,
                                     out_dtype: torch.dtype,
                                     scale_a: torch.Tensor,
                                     scale_b: torch.Tensor, bias: torch.Tensor,
                                     input_2d: torch.Tensor,
                                     output_shape: List,
                                     **kwargs) -> torch.Tensor:
    # Use unfused DQ due to limitations with scaled_mm

    # Symmetric quantized GEMM by definition computes the following:
    #   C = (s_x * X) (s_w * W) + bias
    # This is equivalent to dequantizing the weights and activations
    # before applying a GEMM.
    #
    # In order to compute quantized operands, a quantized kernel
    # will rewrite the above like so:
    #   C = s_w * s_x * (X * W) + bias
    #
    # For the scaled_mm fallback case, we break this down, since it
    # does not support s_w being a vector.

    # GEMM
    # This computes C = (X * W).
    # Output in fp32 to allow subsequent ops to happen in-place
    output = torch._scaled_mm(qinput,
                              weight,
                              scale_a=TORCH_DEVICE_IDENTITY,
                              scale_b=TORCH_DEVICE_IDENTITY,
                              out_dtype=torch.float32)
    # A fix for discrepancy in scaled_mm which returns tuple
    # for torch < 2.5 and a single value in torch >= 2.5
    if type(output) is tuple and len(output) == 2:
        output = output[0]
    # Unpad (undo num_token_padding)
    output = torch.narrow(output, 0, 0, input_2d.shape[0])
    x_scale = torch.narrow(scale_a, 0, 0, input_2d.shape[0])

    # DQ
    # C = sw * sx * (X * W) + bias
    output = output * x_scale * scale_b.t()
    if bias is not None:
        output = output + bias
    return output.to(out_dtype).view(*output_shape)


def dispatch_w8a8_scaled_mm(
        per_tensor_weights: bool,
        per_tensor_activations: bool,
        use_per_token_if_dynamic: Optional[bool]
) -> Callable[..., torch.Tensor]:

    if per_tensor_weights and per_tensor_activations:
        return torch_per_tensor_w8a8_scaled_mm
    return torch_channelwise_w8a8_scaled_mm


# TODO(luka): follow similar pattern for marlin and block-fp8-linear
#  https://github.com/vllm-project/vllm/issues/14397
class Fp8LinearOp:
    """
    This class executes a FP8 linear layer using cutlass if supported and
    torch.scaled_mm otherwise.
    It needs to be a class instead of a method so that config can be read
    in the __init__ method, as reading config is not allowed inside forward.
    """

    def __init__(self,
                 cutlass_fp8_supported: bool = cutlass_fp8_supported(),
                 use_per_token_if_dynamic: bool = False,
                 pad_output: Optional[bool] = None):
        self.cutlass_fp8_supported = cutlass_fp8_supported
        self.use_per_token_if_dynamic = use_per_token_if_dynamic

        # Note: we pad the input because torch._scaled_mm is more performant
        # for matrices with batch dimension > 16.
        # This could change in the future.
        # We also don't pad when using torch.compile,
        # as it breaks with dynamic shapes.
        self.output_padding = 17 if pad_output else None

    def apply(
        self,
        input: torch.Tensor,
        weight: torch.Tensor,
        weight_scale: torch.Tensor,
        out_dtype: Optional[torch.dtype] = None,
        input_scale: Optional[torch.Tensor] = None,
        input_scale_ub: Optional[torch.Tensor] = None,
        bias: Optional[torch.Tensor] = None,
        # TODO(luka) remove this parameter in favor of __init__
        use_per_token_if_dynamic: Optional[bool] = None
    ) -> torch.Tensor:
        # ops.scaled_fp8_quant supports both dynamic and static quant.
        #   If dynamic, layer.input_scale is None and x_scale computed from x.
        #   If static, layer.input_scale is scalar and x_scale is input_scale.

        # View input as 2D matrix for fp8 methods
        input_2d = input.view(-1, input.shape[-1])
        output_shape = [*input.shape[:-1], weight.shape[1]]

        # TODO(luka) this is here because currently MLA only decides this
        #  during the forward method instead of in __init__.
        if use_per_token_if_dynamic is None:
            use_per_token_if_dynamic = self.use_per_token_if_dynamic

        if out_dtype is None:
            out_dtype = input.dtype

        # cutlass_scaled_mm supports per tensor/channel W and per tensor/token A
        fp8_dtype = torch.float8_e4m3fn
        if self.cutlass_fp8_supported:
            assert input.dtype != fp8_dtype, "FP8 input to cutlass is not currently implemented"
            qinput, x_scale = scaled_fp8_quant(
                input_2d,
                input_scale,
                scale_ub=input_scale_ub,
                use_per_token_if_dynamic=use_per_token_if_dynamic)
        else:
            if input.dtype != fp8_dtype:
                # Maybe apply padding to output, see comment in __init__
                qinput, x_scale = scaled_fp8_quant(
                    input_2d,
                    input_scale,
                    num_token_padding=self.output_padding,
                    use_per_token_if_dynamic=use_per_token_if_dynamic)
            else:
                qinput, x_scale = input_2d, input_scale

        per_tensor_weights = (weight_scale.numel() == 1)
        per_tensor_activations = (x_scale.numel() == 1)

        w8a8_scaled_mm_func = dispatch_w8a8_scaled_mm(
            per_tensor_weights,
            per_tensor_activations,
            use_per_token_if_dynamic)

        return w8a8_scaled_mm_func(qinput=qinput,
                                   weight=weight,
                                   out_dtype=out_dtype,
                                   scale_a=x_scale,
                                   scale_b=weight_scale,
                                   bias=bias,
                                   input_2d=input_2d,
                                   output_shape=output_shape)


def normalize_e4m3fn_to_e4m3fnuz(
    weight: torch.Tensor,
    weight_scale: torch.Tensor,
    input_scale: Optional[torch.Tensor] = None
) -> Tuple[torch.Tensor, torch.Tensor, Optional[torch.Tensor]]:
    assert weight.dtype == torch.float8_e4m3fn
    # The bits pattern 10000000(-128) represents zero in e4m3fn
    # but NaN in e4m3fnuz. So here we set it to 0.
    # https://onnx.ai/onnx/technical/float8.html
    weight_as_int8 = weight.view(torch.int8)
    ROCM_FP8_NAN_AS_INT = -128
    weight_as_int8[weight_as_int8 == ROCM_FP8_NAN_AS_INT] = 0
    weight = weight_as_int8.view(torch.float8_e4m3fnuz)

    # For the same bits representation, e4m3fnuz value is half of
    # the e4m3fn value, so we should double the scaling factor to
    # get the same dequantized value.
    # https://onnx.ai/onnx/technical/float8.html
    weight_scale = weight_scale * 2.0
    if input_scale is not None:
        input_scale = input_scale * 2.0
    return weight, weight_scale, input_scale
