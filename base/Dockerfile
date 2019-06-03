ARG cuda_version=10.0
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel

LABEL maintainer="Ben Evans <ben.d.evans@gmail.com>"

# ENTRYPOINT [ "/bin/bash", "-c" ]

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      build-essential \
      # g++ \
      # git \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      locales \
      openmpi-bin \
      wget && \
    rm -rf /var/lib/apt/lists/*

# Dependencies from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu-jupyter.Dockerfile
# N.B. Most of these libraries are included in cudatoolkit
# Check if other libraries e.g. cufft are included in the cuda base image
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         build-essential \
#         cuda-command-line-tools-${CUDA/./-} \
#         cuda-cublas-${CUDA/./-} \
#         cuda-cufft-${CUDA/./-} \
#         cuda-curand-${CUDA/./-} \
#         cuda-cusolver-${CUDA/./-} \
#         cuda-cusparse-${CUDA/./-} \
#         curl \
#         libcudnn7=${CUDNN}+cuda${CUDA} \
#         libfreetype6-dev \
#         libhdf5-serial-dev \
#         libzmq3-dev \
#         pkg-config \
#         software-properties-common \
#         unzip

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
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# Install conda
ARG MINICONDA_VERSION=4.6.14
ARG MINCONDA_MD5=718259965f234088d785cad1fbd7de03

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
    chown $NB_USER $CONDA_DIR -R && \
    mkdir -p /src && \
    chown $NB_USER /src && \
    mkdir -p /work/src && \
    chown $NB_USER /work/src && \
    mkdir -p /work/data && \
    chown $NB_USER /work/data && \
    mkdir -p /work/results && \
    chown $NB_USER /work/results && \
    mkdir -p /work/logs && \
    chown $NB_USER /work/logs

USER $NB_USER

# Install Python packages
ARG python_version=3.6

RUN conda config --append channels conda-forge
RUN conda install -y python=${python_version}
RUN pip install --upgrade pip && \
    pip install \
      sklearn_pandas
RUN conda install --quiet --yes \
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
      git \
      # setuptools \
      # 'cudatoolkit>=${cuda_version}' \
      'cudatoolkit>=10.0' \
      nodejs \
      'notebook=5.7.8' \
      'jupyterhub=1.0.0' \
      'jupyterlab=0.35.6' \
      ipywidgets \
      widgetsnbextension \
      nbdime \
      jupyterlab-git && \
      conda clean --all -f -y && \
      jupyter labextension install @jupyterlab/hub-extension@^0.12.0 && \
      jupyter labextension install @jupyterlab/google-drive && \
      jupyter labextension install @jupyterlab/git && \
      jupyter serverextension enable --py jupyterlab_git && \
      jupyter labextension install @jupyterlab/github && \
      jupyter labextension install jupyterlab-drawio && \
      jupyter labextension install jupyterlab_bokeh@0.6.3 && \
      jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
      npm cache clean --force && \
      jupyter notebook --generate-config && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn

RUN nbdime config-git --enable --global

# ENV LC_ALL=C.UTF-8
# ENV LANG=C.UTF-8

ENV PYTHONPATH='/src/:/work/src/:$PYTHONPATH'

# WORKDIR $HOME
# VOLUME $HOME
WORKDIR /work
VOLUME /work

EXPOSE 8888

CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0"]
