export PYTHONPATH=/home/zhangyanqi/git_repos/DiffKV:$PYTHONPATH
# # gsm8k 88-88
CUDA_VISIBLE_DEVICES=0,1 RAY_DEDUP_LOGS=0 \
    python3 /home/zhangyanqi/git_repos/DiffKV/param_tuning/run_aime.py \
        --model /data1/modelscope/QwQ-32B \
        --load-format safetensors \
        --enforce-eager \
        --dtype float16 \
        --kv-buffer-size 64 \
        --kbits-high 8 \
        --vbits-high 4 \
        --kbits-low 4 \
        --vbits-low 2 \
        --kv-prune-thresh 0.0 \
        --kv-quant-thresh 0.1 \
        --gpu-memory-utilization 0.75 \
        --max-num-batched-tokens 40960 \
        --max-paddings 2048 \
        --tensor-parallel-size 2 \
        --prompt-limit 40960 \
        --max-num-seqs 16 \
        --log-path ../logs/per_token_thresh/qwq-32b/aime/k8v4_k4v2/buffer_64/p0_q3000/round_0/eval_0 \
        --indices-csv ../logs/per_token_thresh/qwq-32b/aime/k8v4_k4v2/buffer_64/p0_q3000/round_0/sample_indices_0.csv \
        --data-label test