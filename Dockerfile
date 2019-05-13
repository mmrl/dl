ARG cuda_version=10.0
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel

# ENTRYPOINT [ "/bin/bash", "-c" ]

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      # build-essential \
      g++ \
      git \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      openmpi-bin \
      wget && \
    rm -rf /var/lib/apt/lists/*

# Install conda
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN wget --quiet --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash /Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh

# RUN wget --quiet --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-4.5.12-Linux-x86_64.sh && \
#     echo "e5e5b4cd2a918e0e96b395534222773f7241dc59d776db1b9f7fedfcb489157a *Miniconda3-4.5.12-Linux-x86_64.sh" | sha256sum -c - && \
#     /bin/bash /Miniconda3-4.5.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
#     rm Miniconda3-4.5.12-Linux-x86_64.sh && \
#     echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh

# Install Python packages and keras
ARG NB_UID=1000
ARG NB_GID=100
ENV NB_USER thedude
ENV NB_UID=$NB_UID
ENV HOME=/home/$NB_USER

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

RUN useradd -m -s /bin/bash -N -u $NB_UID -g $NB_GID $NB_USER && \
    chown $NB_USER $CONDA_DIR -R && \
    mkdir -p /src && \
    chown $NB_USER /src && \
    mkdir -p /workspace/src && \
    chown $NB_USER /workspace/src && \
    mkdir -p /workspace/data && \
    chown $NB_USER /workspace/data && \
    mkdir -p /workspace/results && \
    chown $NB_USER /workspace/results && \
    mkdir -p /workspace/logs && \
    chown $NB_USER /workspace/logs

USER $NB_USER

ARG python_version=3.6

RUN conda config --append channels conda-forge
RUN conda config --append channels pytorch
RUN conda install -y python=${python_version}
# RUN pip install --upgrade pip
RUN pip install --upgrade pip && \
    pip install \
      sklearn_pandas \
      # tensorflow-gpu \
      cntk-gpu
RUN conda install \
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
      notebook \
      Pillow \
      pandas \
      pydot \
      pygpu \
      pyyaml \
      scikit-learn \
      scikit-image \
      opencv \
      six \
      theano \
      mkdocs \
      tqdm \
      tensorflow-gpu \
      # git \
      # setuptools \
      cmake \
      # cffi \
      typing \
      pytorch \
      ignite \
      torchvision \
      # 'cudatoolkit>=${cuda_version}' \
      'cudatoolkit>=10.0' \
      # mamgma-cuda100 \
      tensorboard \
      nodejs \
      'jupyterhub=0.9.6' \
      'jupyterlab=0.35.5' \
      ipywidgets \
      widgetsnbextension \
      jupyterlab-git && \
      conda clean --all && \
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
#      && \
RUN git clone git://github.com/keras-team/keras.git /src && pip install -e /src[tests] && \
    pip install git+git://github.com/keras-team/keras.git && \
    conda clean -yt

# Use the environment.yml to create the conda environment.
# https://fmgdata.kinja.com/using-docker-with-conda-environments-1790901398
# COPY environment.yml /tmp/environment.yml
# RUN [ "conda", "update", "conda", "-y" ]
# RUN [ "conda", "update", "--all", "-y" ]

# RUN [ -s /tmp/environment.yml ] && conda env update -n root -f /tmp/environment.yml

COPY theanorc /home/thedude/.theanorc

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PYTHONPATH='/src/:/workspace/src/:$PYTHONPATH'

# WORKDIR /data
# WORKDIR $HOME
WORKDIR /workspace
# VOLUME $HOME

EXPOSE 6006 8888

# We set ENTRYPOINT, so while we still use exec mode, we don’t
# explicitly call /bin/bash
# CMD [ "exec python run.py" ]
CMD ["jupyter", "lab", "--port=8888", "--ip=0.0.0.0"]
