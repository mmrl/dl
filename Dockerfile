ARG CUDA_VERSION=10.0
ARG CUDNN_VERSION=7
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel
# https://gitlab.com/nvidia/cuda/blob/ubuntu18.04/10.0/devel/cudnn7/Dockerfile
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"

# ENTRYPOINT [ "/bin/bash", "-c" ]
# Needed for string substitution
SHELL ["/bin/bash", "-c"]

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bzip2 \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      git \
      graphviz \
      libfreetype6-dev \
      libgl1-mesa-glx \
      libhdf5-serial-dev \
      libhdf5-dev \
      libjpeg-dev \
      libpng-dev \
      libzmq3-dev \
      locales \
      openmpi-bin \
      pkg-config \
      rsync \
      software-properties-common \
      tmux \
      tree \
      unzip \
      wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Dependencies from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu-jupyter.Dockerfile
# N.B. Most of these libraries are included in cudatoolkit
# cuda-command-line-tools-${CUDA/./-} \
# cuda-cublas-${CUDA/./-} \
# cuda-cufft-${CUDA/./-} \
# cuda-curand-${CUDA/./-} \
# cuda-cusolver-${CUDA/./-} \
# cuda-cusparse-${CUDA/./-} \
# libcudnn7=${CUDNN}+cuda${CUDA} \

RUN echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ARG NB_UID=1000
ARG NB_GID=100
ARG NB_USER=thedude

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_GB.UTF-8 \
    LANG=en_GB.UTF-8 \
    LANGUAGE=en_GB.UTF-8

# See http://bugs.python.org/issue19846
# ENV LC_ALL=C.UTF-8
# ENV LANG=C.UTF-8

# Install conda
ARG MINICONDA_VERSION=4.7.12.1
ARG MINCONDA_MD5=81c773ff87af5cfac79ab862942ab6b3
# Last version to include Python 3.6: 4.5.4
# ARG MINICONDA_VERSION=4.5.4
# ARG MINCONDA_MD5=a946ea1d0c4a642ddf0c3a26a18bb16d

ENV MINICONDA_VERSION=$MINICONDA_VERSION \
    MINCONDA_MD5=$MINCONDA_MD5
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINCONDA_MD5} *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash /Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

RUN useradd -m -s /bin/bash -N -u $NB_UID -g $NB_GID $NB_USER && \
    chown -R $NB_USER:$NB_GID $CONDA_DIR && \
    mkdir -p /src && \
    chown $NB_USER /src && \
    mkdir -p /work/{code,data,logs,models,notebooks,results} && \
    chown -R $NB_USER /work
USER $NB_USER

ENV PATH="/work/code:$CONDA_DIR/bin:$PATH" \
    PYTHONPATH="/work/code:$PYTHONPATH:/src:/src/models" \
    HOME="/home/$NB_USER"

# Install Python packages

# Inherit CUDA_VERSION from global layer
ARG CUDA_VERSION
RUN echo "CUDA: ${CUDA_VERSION}"
ARG CUDNN_VERSION
RUN echo "cuDNN: ${CUDNN_VERSION}"

# Succeeds
# RUN echo ${CUDA_VERSION//.}
# RUN echo ${CUDA_VERSION%.*}
# Fails
# RUN echo ${${CUDA_VERSION%.*}//.}
# ARG CUDA_SHORT_VERSION=${CUDA_VERSION%.*}
# ENV CUDA_SHORT_VERSION="${CUDA_VERSION%.*}"
# RUN echo ${${CUDA_VERSION//.}:0:3}
# Not supported by docker build: 
# https://github.com/docker/cli/blob/master/docs/reference/builder.md#environment-replacement

ARG PYTHON_VERSION=3.7
# RUN echo "python ${PYTHON_VERSION}.*" > $CONDA_DIR/conda-meta/pinned

# Disabling channel_priority installs the highest version then sorts ties by channel priority
# RUN conda config --set channel_priority false
# Strict channel_priority ensures all packages come from the top priority channel unless they only exist in another
# RUN conda config --set channel_priority strict
RUN conda config --prepend channels conda-forge
RUN conda config --prepend channels pytorch
# RUN conda update -n base conda
# RUN conda install -y python=${PYTHON_VERSION}
# RUN pip install --upgrade pip
# RUN pip install --upgrade pip && \
#     pip install \
#       sklearn_pandas \
RUN conda install --quiet --yes \
      python=${PYTHON_VERSION} \
      pip \
      numpy \
      scipy \
      cython \
      sympy \
      imagemagick \
      bcolz \
      h5py \
      joblib \
      matplotlib \
      bokeh \
      selenium \
      phantomjs \
      networkx \
      sphinx \
      seaborn \
      mkl \
      nose \
      Pillow \
      python-lmdb \
      pandas \
      papermill \
      pydot \
      pygpu \
      pyyaml \
      scikit-learn \
      scikit-image \
      opencv \
      six \
      mkdocs \
      tqdm \
      xlrd \
      xlwt \
      'tensorflow-gpu=2.0.*' \
      # tensorboard \
      # keras-gpu \
      setuptools \
      cmake \
      cffi \
      typing \
      'pytorch=1.4.*' \
      ignite \
      torchvision \
      cudatoolkit=${CUDA_VERSION} \
      # 'cudatoolkit>=10.0' \
      # magma-cuda${CUDA_VERSION//.} \
      magma-cuda100 \
      nodejs \
      'notebook=6.0.*' \
      'jupyterhub=1.1.*' \
      'jupyterlab=1.2.*' \
      ipywidgets \
      widgetsnbextension \
      nbdime \
      jupyter_conda \
      jupyterlab-git && \
      # pip install tensorflow-gpu && \
      conda clean --all -f -y && \
      jupyter labextension install @jupyterlab/google-drive && \
      jupyter labextension install jupyterlab_toastify jupyterlab_conda && \
      jupyter labextension install @jupyterlab/git && \
      jupyter serverextension enable --py jupyterlab_git && \
      jupyter labextension install @jupyterlab/github && \
      jupyter labextension install jupyterlab-drawio && \
      jupyter labextension install jupyterlab_bokeh && \
      jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
      npm cache clean --force && \
      jupyter notebook --generate-config && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn
RUN nbdime config-git --enable --global

# Clone Official Tensorflow models
ARG TF_MODELS_VERSION=master
ENV TF_MODELS_VERSION=${TF_MODELS_VERSION}
RUN git clone -b ${TF_MODELS_VERSION} https://github.com/tensorflow/models.git /src/models

# WORKDIR /work/notebooks
WORKDIR /work
VOLUME /work

# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 6006 8888

CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
