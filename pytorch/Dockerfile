FROM mmrl/dl-base

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
      'pytorch=1.4.*' \
      ignite \
      torchvision \
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
