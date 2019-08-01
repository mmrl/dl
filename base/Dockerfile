ARG cuda_version=10.0
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel

LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"

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
# ARG MINICONDA_VERSION=4.7.10
# ARG MINCONDA_MD5=1c945f2b3335c7b2b15130b1b2dc5cf4
ARG MINICONDA_VERSION=4.6.14
ARG MINCONDA_MD5=718259965f234088d785cad1fbd7de03

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
    PYTHONPATH="/work/code:$PYTHONPATH:/src" \
    HOME="/home/$NB_USER"

# Install Python packages
ARG python_version=3.6
RUN conda config --prepend channels conda-forge
# RUN pip install --upgrade pip
RUN conda install --quiet --yes \
      python=${python_version} \
      pip \
      cudatoolkit=${cuda_version} \
      setuptools \
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
      nodejs \
      'notebook=6.0.0' \
      'jupyterhub=1.0.0' \
      'jupyterlab=1.0.4' \
      ipywidgets \
      widgetsnbextension \
      nbdime \
      jupyterlab-git && \
      conda clean --all -f -y && \
      jupyter labextension install @jupyterlab/google-drive && \
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

WORKDIR /work/notebooks
VOLUME /work
EXPOSE 8888
CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0", "--notebook-dir='/work/notebooks'"]
