ARG cuda_version=10.0
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel

LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

# Install system packages
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
      bzip2 \
      build-essential \
      git \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      locales \
      openmpi-bin \
      tree \
      wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
# RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
#     locale-gen

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
# LC_ALL=en_US.UTF-8 \
# LANG=en_US.UTF-8 \
# LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# ENV LC_ALL=C.UTF-8
# ENV LANG=C.UTF-8

# Install conda
ARG MINICONDA_VERSION=4.6.14
ARG MINCONDA_MD5=718259965f234088d785cad1fbd7de03
# ARG MINICONDA_VERSION=4.5.4
# ARG MINCONDA_MD5=a946ea1d0c4a642ddf0c3a26a18bb16d

ENV MINICONDA_VERSION=$MINICONDA_VERSION \
    MINCONDA_MD5=$MINCONDA_MD5
RUN wget --quiet --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
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
    mkdir -p /work/{src,data,results,logs} && \
    chown -R $NB_USER /work
USER $NB_USER

# Install Python packages and keras
ARG python_version=3.6
# RUN echo "python ${python_version}.*" > $CONDA_DIR/conda-meta/pinned
RUN conda config --append channels conda-forge
RUN conda config --append channels pytorch
# RUN conda update -n base conda
# RUN conda install -y python=${python_version}
RUN pip install --upgrade pip
# RUN pip install --upgrade pip && \
#     pip install \
#       sklearn_pandas \
RUN conda install --quiet --yes \
      python=${python_version} \
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
      tensorflow-gpu \
      keras-gpu \
      setuptools \
      cmake \
      cffi \
      typing \
      pytorch \
      ignite \
      torchvision \
      cudatoolkit=${cuda_version} \
      # 'cudatoolkit>=10.0' \
      magma-cuda100 \
      tensorboard \
      nodejs \
      'notebook=5.7.8' \
      'jupyterhub=1.0.0' \
      'jupyterlab=1.0.2' \
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

ENV PYTHONPATH='/src/:/work/src/:$PYTHONPATH'

WORKDIR /work
VOLUME /work

# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 6006 8888

CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0"]
