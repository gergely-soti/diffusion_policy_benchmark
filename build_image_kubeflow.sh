#!/bin/bash
##############################################################################
##                            Build the image                               ##
##############################################################################
docker build \
  -f kubeflow.Dockerfile \
  -t gergelysoti/torch-jupyter:2024-2-0.1 .

