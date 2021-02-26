ARG CUDA_VERSION=11.0
ARG CUDNN_VERSION=8
ARG OS=ubuntu20.04
# TODO: Try the miniconda base image since cudatoolkit should be enough for GPU use
# FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-${OS}
# https://gitlab.com/nvidia/cuda/blob/ubuntu18.04/10.0/devel/cudnn7/Dockerfile
# https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1/ubuntu20.04-x86_64/devel/Dockerfile
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
# LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"

# NOTE: An ARG declared before the FROM instruction can’t be used after the FROM. 
# If you want to use it you need to declare it without the value as below e.g.:
# ARG CUDA_VERSION

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

# Use an ARG to avoid permanently setting to noninteractive
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # ---- nbconvert dependencies ----
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-plain-generic \
        # Optional dependency
        texlive-fonts-extra \
        # ----
        bzip2 \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        graphviz \
        libfreetype6-dev \
        # libnvinfer6=6.0.1-1+${CUDA/./-} \
        # libnvinfer-dev=6.0.1-1+${CUDA/./-} \
        # libnvinfer-plugin6=6.0.1-1+${CUDA/./-} \
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
    apt clean && \
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
# ARG MINICONDA_VERSION=py39_4.9.2
# ARG MINCONDA_MD5=b4e46fcc8029e2cfa731b788f25b1d36
ARG MINICONDA_VERSION=py38_4.9.2
ARG MINCONDA_MD5=122c8c9beb51e124ab32a0fa6426c656
# ARG MINICONDA_VERSION=py37_4.8.2
# ARG MINCONDA_MD5=87e77f097f6ebb5127c77662dfc3165e
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
    mkdir -p /work/{code,data,logs,models,notebooks,results,scripts/entrypoint.d} && \
    chown -R $NB_USER /work
USER $NB_USER

ENV PATH="/work/scripts:/work/code:$CONDA_DIR/bin:$PATH" \
    PYTHONPATH="/work/scripts:/work/code:$PYTHONPATH:/src:/src/models" \
    HOME="/home/$NB_USER"

# Set entrypoint to run any executable scripts in /work/scripts
USER root
COPY base/entrypoint.sh /usr/local/bin
RUN chown $NB_USER:$NB_GID /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh
USER $NB_USER

# Inherit CUDA_VERSION from global layer
ARG CUDA_VERSION
RUN echo "CUDA: ${CUDA_VERSION}"
ARG CUDNN_VERSION
RUN echo "cuDNN: ${CUDNN_VERSION}"
ENV OMPI_MCA_opal_cuda_support=true
RUN echo "Open MPI CUDA support: ${OMPI_MCA_opal_cuda_support}"

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

# Install Python packages

ARG PYTHON_VERSION=3.8
# RUN echo "python ${PYTHON_VERSION}.*" > $CONDA_DIR/conda-meta/pinned

ARG TENSORFLOW_VERSION=2.4
ARG PYTORCH_VERSION=1.7

# Disabling channel_priority installs the highest version then sorts ties by channel priority
# RUN conda config --set channel_priority false
# Strict channel_priority ensures all packages come from the top priority channel unless they only exist in another
# RUN conda config --set channel_priority strict
RUN conda config --prepend channels bokeh
RUN conda config --prepend channels conda-forge
# RUN conda config --prepend channels nvidia
RUN conda config --prepend channels pytorch
# RUN conda config --add channels conda-forge
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
      jax \
      numba \
      imagemagick \
      pytest \
      bcolz \
      h5py \
      joblib \
      matplotlib-base \
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
      numexpr \
      bottleneck \
      tabulate \
      papermill \
      pydot \
      pygpu \
      pyyaml \
      scikit-learn \
      scikit-image \
      opencv \
      mkdocs \
      tqdm \
      xlrd \
      xlwt \
      # 'tensorflow-gpu=2.1.*' \ 
      # 'tensorflow=2.1.*' \ THIS ONLY HAS GPU SUPPORT IN PIP
      # tensorflow-gpu=${TENSORFLOW_VERSION} \ For conda, explicitly tag with -gpu
      tensorboard \
      setuptools \
      cmake \
      cffi \
      cupti \
      typing \
      # 'pytorch=1.7.*' \
      pytorch=${PYTORCH_VERSION} \
      # magma-cuda${CUDA_VERSION//.} \
      # magma-cuda100 \
      # magma-cuda101 \
      # magma-cuda102 \
      magma-cuda110 \
      # magma-cuda111 \
      ignite \
      torchvision \
      mpi4py \
      openmpi \
      # cudatoolkit=${CUDA_VERSION} \
      # cudnn=${CUDNN_VERSION} \
      # nccl \
      # JupyterLab requires nodejs>=12 (>=10 since 2.1):
      # https://github.com/jupyterlab/jupyterlab/blob/master/dev_mode/package.json
      # nodejs \
      # 'nodejs>=12' \
      'nodejs>=15' \
      # 'notebook=6.1.*' \
      notebook \
      # 'jupyterhub=1.3.*' \
      jupyterhub \
      'jupyterlab=3.0.*' \
      ipywidgets \
      # widgetsnbextension \
      ipympl \
      # nbdime \
      jupytext \
      # jupyternotify \
      jupyterlab_autoversion \
      watermark && \
      # jupyterlab_bokeh \
      # jupyterlab-nvdashboard && \
    #   jupyterlab-git && \
      # jupyter_conda && \
      conda clean --all -f -y && \
      pip install --upgrade pip && \
      pip install \
        tensorflow==${TENSORFLOW_VERSION}.* \
        tf-explain \
        jupyterlab-drawio && \
        # jupyterlab_latex \
        # jupyterlab_autoversion \
        # watermark \
        # Needed as the backend for jupyterlab_tensorboard
        # jupyter-tensorboard \
      pip install --pre \
        jupyterlab-git && \
      # Activate ipywidgets extension in the environment that runs the notebook server
      # jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
      # Also activate ipywidgets extension for JupyterLab
      jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
      # jupyter labextension install @jupyterlab/toc --no-build && \
      # jupyter labextension install @jupyterlab/google-drive --no-build && \
      # jupyter labextension install @jupyterlab/git --no-build && \
    #   jupyter serverextension enable --py jupyterlab_git && \
      # jupyter labextension install @jupyterlab/github --no-build && \
      # jupyter labextension install jupyterlab-drawio --no-build && \
    #  jupyter labextension install jupyterlab_bokeh --no-build && \
      # jupyter labextension install @bokeh/jupyter_bokeh --no-build && \
      # jupyter labextension install jupyter-matplotlib --no-build && \
      jupyter labextension install jupyterlab_toastify --no-build && \
      # jupyter labextension install jupyterlab_conda --no-build && \
      # jupyter labextension install jupyterlab-jupytext --no-build && \
      # jupyter labextension install jupyterlab_autoversion --no-build && \
      # jupyter labextension install jupyterlab-nvdashboard --no-build && \
    #   jupyter labextension install @jupyterlab/latex --no-build && \
      # jupyter labextension install jupyterlab_tensorboard --no-build && \
      jupyter lab build && \
      npm cache clean --force && \
      jupyter notebook --generate-config && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn && \
      rm -rf /home/$NB_USER/.node-gyp
RUN nbdime config-git --enable --global

# Clone Official Tensorflow models
# TODO: Move to /work
ARG TF_MODELS_VERSION=master
# ARG TF_MODELS_VERSION=${TENSORFLOW_VERSION}
ENV TF_MODELS_VERSION=${TF_MODELS_VERSION}
RUN git clone -b ${TF_MODELS_VERSION} https://github.com/tensorflow/models.git /src/models

# WORKDIR /work/notebooks
WORKDIR /work
VOLUME /work

# Print versions
RUN python -c 'import tensorflow as tf; print(f"TensorFlow: {tf.__version__}")'
# tf.config.list_physical_devices('GPU')
RUN python -c 'import torch; print(f"PyTorch: {torch.__version__}")'
# torch.cuda.is_available()

LABEL maintainer="ben.d.evans@gmail.com" \
    name="Deep learning image" \
    description="A Python based GPU-accelerated Jupyter image for deep learning." \
    org.opencontainers.image.authors="Ben Evans" \
    org.opencontainers.image.url="https://github.com/mmrl/dl"

RUN conda list --explicit

# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 6006 8888

ENTRYPOINT ["entrypoint.sh"]
CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
