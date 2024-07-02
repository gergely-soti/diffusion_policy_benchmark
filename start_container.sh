#!/bin/bash
##############################################################################
##                            Run the container                             ##
##############################################################################
SRC_CONTAINER=/home/jovyan/workspace/diffusion_policy
SRC_HOST="$(pwd)"/../diffusion_policy_benchmark

DATA_CONTAINER=/home/jovyan/data
DATA_HOST=/home/soti/project_data/2024-2/kiro2024

docker run \
  --name diffusion-policy \
  --rm \
  -it \
  --ipc=host \
  --net=host \
  -v "$SRC_HOST":"$SRC_CONTAINER":rw \
  -v "$DATA_HOST":"$DATA_CONTAINER":rw \
  -e DISPLAY="$DISPLAY" \
  --gpus all \
  torch/diffusion-policy
