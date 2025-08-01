export PYTHONPATH=/home/zhangyanqi/git_repos/DiffKV:$PYTHONPATH
# ******** minerva_math 88-88
# baselines
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 8 --kbits-low 8 --vbits-low 8 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 1
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 4 --vbits-high 4 --kbits-low 4 --vbits-low 4 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 1
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 1
# chosen config
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 3.0 --kv-buffer 64 --rounds 1
# scaning
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 1.0 --kv-buffer 64 --rounds 1
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 2.0 --kv-buffer 64 --rounds 1
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 4.0 --kv-buffer 64 --rounds 1
python3 _eval_qa_correct.py --model qwq --dataset minerva_math --sample-rate 20 --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 5.0 --kv-buffer 64 --rounds 1
# ******** aime
# baselines
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 8 --kbits-low 8 --vbits-low 8 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 4 --vbits-high 4 --kbits-low 4 --vbits-low 4 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 15
# chosen config = 3
# scaning
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 1.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 2.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 3.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 4.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset aime --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 5.0 --kv-buffer 64 --rounds 15
# ******** gpqa
# baselines
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 8 --kbits-low 8 --vbits-low 8 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 4 --vbits-high 4 --kbits-low 4 --vbits-low 4 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 0.0 --kv-buffer 64 --rounds 15
# chosen config = 3
# scaning
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 1.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 2.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 3.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 4.0 --kv-buffer 64 --rounds 15
python3 _eval_qa_correct.py --model qwq --dataset gpqa --model-gen 2 --model-size 32  --log-path ../logs/per_token_thresh/qwq-32b --kbits-high 8 --vbits-high 4 --kbits-low 4 --vbits-low 2 --kv-prune-thresh 0.0 --kv-quant-thresh 5.0 --kv-buffer 64 --rounds 15