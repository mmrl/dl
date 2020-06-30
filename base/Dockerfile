ARG CUDA_VERSION=10.1
ARG CUDNN_VERSION=7
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel

# LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"

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
    rm -rf /var/lib/apt/lists/*

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

# Install conda
ARG MINICONDA_VERSION=py38_4.8.3
ARG MINCONDA_MD5=d63adf39f2c220950a063e0529d4ff74
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

# Set Open MPI CUDA support
ENV OMPI_MCA_opal_cuda_support=true

# Install Python packages
ARG PYTHON_VERSION=3.8
RUN conda config --prepend channels bokeh
RUN conda config --prepend channels conda-forge
RUN conda install --quiet --yes \
      python=${PYTHON_VERSION} \
      pip \
      cudatoolkit=${CUDA_VERSION} \
      # cudatoolkit \
      setuptools \
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
      mpi4py \
      nodejs \
      'notebook=6.0.*' \
      'jupyterhub=1.1.*' \
      'jupyterlab=2.1.*' \
      ipywidgets \
      widgetsnbextension \
      nbdime \
      jupytext \
      jupyternotify \
      jupyter_conda \
      jupyterlab-git && \
      conda clean --all -f -y && \
      # Activate ipywidgets extension in the environment that runs the notebook server
      jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
      # Also activate ipywidgets extension for JupyterLab
      jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
      jupyter labextension install @jupyterlab/toc --no-build && \
      jupyter labextension install @jupyterlab/google-drive --no-build && \
      jupyter labextension install @jupyterlab/git --no-build && \
      jupyter serverextension enable --py jupyterlab_git && \
      jupyter labextension install @jupyterlab/github --no-build && \
      jupyter labextension install jupyterlab-drawio --no-build && \
      # jupyter labextension install jupyterlab_bokeh --no-build && \
      jupyter labextension install @bokeh/jupyter_bokeh --no-build && \
      jupyter labextension install jupyter-matplotlib --no-build && \
      jupyter labextension install jupyterlab_toastify jupyterlab_conda --no-build && \
      jupyter labextension install jupyterlab-jupytext --no-build && \
      jupyter lab build && \
      npm cache clean --force && \
      jupyter notebook --generate-config && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn && \
      rm -rf /home/$NB_USER/.node-gyp
RUN nbdime config-git --enable --global

WORKDIR /work
VOLUME /work

LABEL maintainer="ben.d.evans@gmail.com" \
    name="Deep learning base image" \
    description="A Python based GPU-accelerated Jupyter image for deep learning." \
    org.opencontainers.image.authors="Ben Evans" \
    org.opencontainers.image.url="https://github.com/mmrl/dl"

EXPOSE 8888
ENTRYPOINT ["entrypoint.sh"]
# CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--allow-root"]

# Build mmrl/dl-base image
# CUDA_VERSION=10.1
# CUDNN_VERSION=7
# docker build -t mmrl/dl-base:CUDA${CUDA_VERSION}-cudnn${CUDNN_VERSION} \
# --build-arg CUDA_VERSION=$(CUDA_VERSION) \
# --build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
# -f base/Dockerfile .
