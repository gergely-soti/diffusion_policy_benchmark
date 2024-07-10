#!/bin/bash
##############################################################################
##                            Run the container                             ##
##############################################################################
SRC_CONTAINER=/home/jovyan/workspace/diffusion_policy
SRC_HOST="$(pwd)"/../diffusion_policy_benchmark

DATA_CONTAINER=/home/jovyan/data
DATA_HOST=/home/soti/project_data/2024-2/kiro2024

ROBOSUITE_CONTAINER=/home/jovyan/workspace/robosuite
ROBOSUITE_HOST="$(pwd)"/../robosuite

ROBOMIMIC_CONTAINER=/home/jovyan/workspace/robomimic
ROBOMIMIC_HOST="$(pwd)"/../robomimic

docker run \
  --name diffusion-policy \
  --rm \
  -it \
  --ipc=host \
  --net=host \
  -v "$SRC_HOST":"$SRC_CONTAINER":rw \
  -v "$DATA_HOST":"$DATA_CONTAINER":rw \
  -v "$ROBOSUITE_HOST":"$ROBOSUITE_CONTAINER":rw \
  -v "$ROBOMIMIC_HOST":"$ROBOMIMIC_CONTAINER":rw \
  -e DISPLAY="$DISPLAY" \
  --gpus all \
  torch/diffusion-policy
