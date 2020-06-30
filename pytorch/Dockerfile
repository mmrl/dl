ARG TAG=latest
FROM mmrl/dl-base:${TAG}
# ARG BASE_TAG=latest
# FROM mmrl/dl-base:${BASE_TAG}

ARG PYTORCH_VERSION=1.5
# https://github.com/pytorch/pytorch/blob/master/docker/pytorch/Dockerfile
RUN conda config --prepend channels pytorch
RUN conda install --quiet --yes \
      # setuptools \
      # git \
      # cudatoolkit=${CUDA_VERSION} \
      # numpy \
      # pyyaml \
      # scipy \
      # cython \
      # cmake \
      # mkl \
      mkl-include \
      ninja \
      typing \
      cffi \
      # 'pytorch=1.4.*' \
      pytorch=${PYTORCH_VERSION} \
      ignite \
      torchvision \
      # magma-cuda100 && \
      magma-cuda101 && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn

# WORKDIR /work
# VOLUME /work

# Print version 
RUN python -c 'import torch; print(f"PyTorch: {torch.__version__}")'
# torch.cuda.is_available()

LABEL maintainer="ben.d.evans@gmail.com" \
    name="Deep learning pytorch image" \
    description="A Python based GPU-accelerated Jupyter image for deep learning." \
    org.opencontainers.image.authors="Ben Evans" \
    org.opencontainers.image.url="https://github.com/mmrl/dl"
