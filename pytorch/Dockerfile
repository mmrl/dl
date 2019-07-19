FROM mmrl/dl:base

# https://github.com/pytorch/pytorch/blob/master/docker/pytorch/Dockerfile
RUN conda config --append channels pytorch
RUN conda install --quiet --yes \
      # setuptools \
      # git \
      # cudatoolkit=${cuda_version} \
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
      pytorch \
      ignite \
      torchvision \
      magma-cuda100 && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn

# WORKDIR /work
# VOLUME /work
