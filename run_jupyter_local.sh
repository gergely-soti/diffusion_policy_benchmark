#!/bin/bash
##############################################################################
##                            Run the container                             ##
##############################################################################
SRC_CONTAINER=/home/hephaestus/workspace/src
SRC_HOST="$(pwd)"/src

DATA_CONTAINER=/home/hephaestus/workspace/data
DATA_HOST=/home/soti/project_data/2024-2/kiro2024

docker run \
  --name torch \
  --rm \
  -it \
  --net=host \
  -e DISPLAY="$DISPLAY" \
  --gpus all \
  gergelysoti/torch-jupyter:2024-2-0.1 bash
