#!/bin/bash
##############################################################################
##                            Build the image                               ##
##############################################################################

uid=$(eval "id -u")
gid=$(eval "id -g")
docker build \
  --build-arg UID="$uid" \
  --build-arg GID="$gid" \
  -f Dockerfile \
  -t torch/diffusion-policy .
