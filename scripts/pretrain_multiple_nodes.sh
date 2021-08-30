#! /bin/bash

# Change for multinode config

NUM_WORKERS=10
NUM_GPUS_PER_WORKER=8
MP_SIZE=1

script_path=$(realpath $0)
script_dir=$(dirname $script_path)
main_dir=$(dirname $script_dir)

# OPTIONS_NCCL="NCCL_DEBUG=info NCCL_IB_DISABLE=0 NCCL_SOCKET_IFNAME=bond0 NCCL_IB_GID_INDEX=3 NCCL_NET_GDR_LEVEL=0"
OPTIONS_NCCL="NCCL_DEBUG=info NCCL_IB_DISABLE=0 NCCL_NET_GDR_LEVEL=2"
HOST_FILE_PATH="hostfile2"
# OPTIONS_NCCL=""
# HOST_FILE_PATH="hostfile_single"

small_data="/dataset/fd5061f6/cogview/cogdata_new/cogdata_task_3leveltokens/zijian/zijian.bin.part_0.cogdata"
full_data="/dataset/fd5061f6/cogview/cogdata_new/cogdata_task_3leveltokens/merge.bin"

config_json="$script_dir/ds_config.json"
gpt_options=" \
       --experiment-name cogview-fixgrad-small-test \
       --img-tokenizer-num-tokens 8192 \
       --dataset-type BinaryDataset \
       --model-parallel-size ${MP_SIZE} \
       --num-layers 16 \
       --hidden-size 1024 \
       --num-attention-heads 16 \
       --save $main_dir/data/checkpoints \
       --train-iters 300000 \
       --resume-dataloader \
       --train-data ${full_data} \
       --split 949,50,1 \
       --distributed-backend nccl \
       --lr-decay-style cosine \
       --warmup .1 \
       --checkpoint-activations \
       --deepspeed-activation-checkpointing \
       --max-position-embeddings 5184 \
       --max-memory-length 0 \
       --sandwich-ln \
       --txt-loss-scale 10 \
       --sparse-type cuda_2d \
       --fp16 \
       --save-interval 2000 \
       --load data/checkpoints/cogview-compare
"
       #        



gpt_options="${gpt_options}
               --deepspeed \
               --deepspeed_config ${config_json} \
"


run_cmd="${OPTIONS_NCCL} deepspeed --num_nodes ${NUM_WORKERS} --num_gpus ${NUM_GPUS_PER_WORKER} --hostfile ${HOST_FILE_PATH} pretrain_gpt2.py $@ ${gpt_options}"
echo ${run_cmd}
eval ${run_cmd}

set +x
