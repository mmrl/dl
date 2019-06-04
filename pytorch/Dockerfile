FROM mmrl/dl:base

# https://github.com/pytorch/pytorch/blob/master/docker/pytorch/Dockerfile
RUN conda config --append channels pytorch
RUN conda install --quiet --yes \
      # git \
      numpy \
      ninja \
      pyyaml \
      # cmake \
      # mkl \
      mkl-include \
      setuptools \
      # cffi \
      typing \
      pytorch \
      ignite \
      torchvision \
      magma-cuda100 && \
      # 'cudatoolkit>=${cuda_version}' \
      # 'cudatoolkit>=10.0' && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn

WORKDIR /work
VOLUME /work
