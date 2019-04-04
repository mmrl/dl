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

# Install Python packages and keras
ARG NB_UID=1000
# ARG NB_GID
ENV NB_USER thedude
ENV NB_UID=$NB_UID

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chown $NB_USER $CONDA_DIR -R && \
    mkdir -p /src && \
    chown $NB_USER /src && \
    mkdir -p /logs && \
    chown $NB_USER /logs

USER $NB_USER

ARG python_version=3.6

RUN conda config --append channels conda-forge
RUN conda install -y python=${python_version}
RUN pip install --upgrade pip && \
    pip install \
      sklearn_pandas \
      tensorflow-gpu \
      cntk-gpu
RUN conda install \
      bcolz \
      h5py \
      matplotlib \
      mkl \
      nose \
      notebook \
      Pillow \
      pandas \
      pydot \
      pygpu \
      pyyaml \
      scikit-learn \
      six \
      theano \
      mkdocs \
      tensorboard
#      && \
RUN git clone git://github.com/keras-team/keras.git /src && pip install -e /src[tests] && \
    pip install git+git://github.com/keras-team/keras.git && \
    conda clean -yt

# Use the environment.yml to create the conda environment.
# https://fmgdata.kinja.com/using-docker-with-conda-environments-1790901398
COPY environment.yml /tmp/environment.yml
# RUN [ "conda", "update", "conda", "-y" ]
# RUN [ "conda", "update", "--all", "-y" ]

RUN conda env update -n root -f /tmp/environment.yml

COPY theanorc /home/thedude/.theanorc

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PYTHONPATH='/src/:$PYTHONPATH'

WORKDIR /data

EXPOSE 8888
EXPOSE 6006

# We set ENTRYPOINT, so while we still use exec mode, we don’t
# explicitly call /bin/bash
# CMD [ "exec python run.py" ]
CMD jupyter notebook --port=8888 --ip=0.0.0.0
