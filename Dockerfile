##############################################################################
##                                 Base Image                               ##
##############################################################################
FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-devel as torch-base
USER root
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

##############################################################################
##                                 Dependencies                             ##
##############################################################################
FROM torch-base as dependencies
USER root
RUN apt update \
  && apt install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
  && rm -rf /var/lib/apt/lists/*# Env vars for the nvidia-container-runtime.

RUN DEBIAN_FRONTEND=noninteractive \
	apt update && \
	apt install -y mesa-utils libgl1-mesa-glx libglu1-mesa-dev freeglut3-dev mesa-common-dev libopencv-dev python3-opencv python3-tk

RUN DEBIAN_FRONTEND=noninteractive \
	apt update && \
    apt install -y libosmesa6-dev libgl1-mesa-glx libglfw3 patchelf

RUN rm /etc/apt/sources.list.d/cuda.list

##############################################################################
##                                  User                                    ##
##############################################################################
FROM dependencies as user
#FROM base-render as user

# install sudo
RUN apt-get update && apt-get install -y sudo

# Create user
ARG USER=jovyan
ARG PASSWORD=automaton
ARG UID=1000
ARG GID=1000
ENV USER=$USER
RUN groupadd -g $GID $USER \
    && useradd -m -u $UID -g $GID -p "$(openssl passwd -1 $PASSWORD)" \
    --shell $(which bash) $USER -G sudo
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudogrp

USER $USER
RUN mkdir -p /home/$USER/workspace/diffusion_policy
RUN mkdir -p /home/$USER/data
WORKDIR /home/$USER/workspace

##############################################################################
##                                 Diffusion Policy                         ##
##############################################################################
FROM user as diffusion-policy

USER root
RUN apt-get update && apt-get install -y curl
USER $USER

COPY --chown=jovyan:jovyan conda_environment.yaml /home/$USER/workspace
USER root
RUN conda update -n base -c conda-forge conda
USER $USER
RUN curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
RUN bash Miniforge3-$(uname)-$(uname -m).sh -b
RUN eval "$(/home/jovyan/miniforge3/bin/conda shell.bash hook)" && \
    mamba env create -f conda_environment.yaml

CMD ["bash"]