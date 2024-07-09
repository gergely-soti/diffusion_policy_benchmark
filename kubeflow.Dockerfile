##############################################################################
##                                 Base Image                               ##
##############################################################################
FROM kubeflownotebookswg/jupyter-pytorch-cuda-full:v1.7.0 as kubeflow-base
##############################################################################
##                                 Dependencies                             ##
##############################################################################
FROM kubeflow-base as dependencies

USER root
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt install -y mesa-utils libgl1-mesa-glx libglu1-mesa-dev freeglut3-dev mesa-common-dev libopencv-dev python3-opencv python3-tk
RUN apt-get update && apt-get install -y screen

RUN DEBIAN_FRONTEND=noninteractive \
	apt update && \
    apt install -y libosmesa6-dev libgl1-mesa-glx libglfw3 patchelf

USER $NB_USER

RUN pip install --no-cache-dir opencv-contrib-python
RUN pip install --no-cache-dir transforms3d tensorflow_addons
RUN pip install --no-cache-dir scipy numpy
RUN pip install --no-cache-dir scikit-learn einops
RUN pip install --no-cache-dir wandb pandas
RUN pip install --no-cache-dir imageio
RUN pip install --no-cache-dir msgpack colortrans
RUN pip install --no-cache-dir fastapi uvicorn
RUN pip install --no-cache-dir loguru
RUN pip install --no-cache-dir matplotlib
RUN pip install hydra-core --upgrade

##############################################################################
##                                 Diffusion Policy                         ##
##############################################################################
FROM dependencies as diffusion-policy

USER root
RUN apt-get update && apt-get install -y curl
USER $NB_USER

USER root
RUN conda update -n base -c conda-forge conda
USER $NB_USER
RUN curl -L -o /home/$NB_USER/Miniforge3-Linux-x86_64.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
RUN bash /home/$NB_USER/Miniforge3-Linux-x86_64.sh -b
COPY --chown=jovyan:jovyan conda_environment.yaml /home/$NB_USER

USER root
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc \
    g++
USER $NB_USER
 RUN eval "$(/home/$NB_USER/miniforge3/bin/conda shell.bash hook)" && \
    mamba env create -f /home/$NB_USER/conda_environment.yaml