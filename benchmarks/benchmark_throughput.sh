# Set PYTHONPATH to the project's root directory
export PYTHONPATH=

# Set the HuggingFace model download directory
export HF_DOWNLOAD_DIR=

# Need 4 GPUs to run Llama3-70B
export CUDA_VISIBLE_DEVICES=0,1,2,3

# Llama3-8B
python benchmark_throughput.py \
    --model meta-llama/Meta-Llama-3-8B-Instruct \
    --download-dir $HF_DOWNLOAD_DIR \
    --num-requests 512 \
    --max-output-len 4096 \
    --kbits-high 8 \
    --vbits-high 4 \
    --kbits-low 4 \
    --vbits-low 2 \
    --kv-prune-thresh 0.02 \
    --kv-quant-thresh 1.0 \
    --max-batch-size 128 > logs/llama3_8b.log

# Qwen2.5-7B
python benchmark_throughput.py \
    --model Qwen/Qwen2.5-7B-Instruct \
    --download-dir $HF_DOWNLOAD_DIR \
    --num-requests 512 \
    --max-output-len 4096 \
    --kbits-high 8 \
    --vbits-high 4 \
    --kbits-low 4 \
    --vbits-low 2 \
    --kv-prune-thresh 0.04 \
    --kv-quant-thresh 0.04 \
    --max-batch-size 128 > logs/qwen2.5_7b.log

# Llama3-70B
python benchmark_throughput.py \
    --model meta-llama/Meta-Llama-3-70B-Instruct \
    --download-dir $HF_DOWNLOAD_DIR \
    --tensor-parallel-size 4 \
    --num-requests 512 \
    --max-output-len 4096 \
    --kbits-high 8 \
    --vbits-high 4 \
    --kbits-low 4 \
    --vbits-low 2 \
    --kv-prune-thresh 0.0 \
    --kv-quant-thresh 1.0 \
    --max-batch-size 64 > logs/llama3_70b.log

# Qwen2.5-32B
python benchmark_throughput.py \
    --model Qwen/Qwen2.5-32B-Instruct \
    --download-dir $HF_DOWNLOAD_DIR \
    --tensor-parallel-size 2 \
    --num-requests 512 \
    --max-output-len 8192 \
    --kbits-high 8 \
    --vbits-high 4 \
    --kbits-low 4 \
    --vbits-low 2 \
    --kv-prune-thresh 0.0 \
    --kv-quant-thresh 3.0 \
    --max-batch-size 32 > logs/qwen2.5_32b.log

# QwQ-32B
python benchmark_throughput.py \
    --model Qwen/QwQ-32B \
    --download-dir $HF_DOWNLOAD_DIR \
    --tensor-parallel-size 2 \
    --num-requests 512 \
    --max-output-len 16384 \
    --kbits-high 8 \
    --vbits-high 4 \
    --kbits-low 4 \
    --vbits-low 2 \
    --kv-prune-thresh 0.0 \
    --kv-quant-thresh 3.0 \
    --max-batch-size 16 > logs/qwq_32b.log
