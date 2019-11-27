FROM mmrl/dl-base
# https://github.com/keras-team/keras/blob/master/docker/Dockerfile
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile

# # Install Python packages and keras
# RUN conda install -y python=${PYTHON_VERSION}
# RUN pip install --upgrade pip && \
#     pip install \
#       sklearn_pandas \
#       # tensorflow-gpu \
#       cntk-gpu
# ARG CUDA_VERSION=10.0

RUN conda install --quiet --yes \
      # mkl \
      # git \
      # setuptools \
      # cudatoolkit=${CUDA_VERSION} \
      wheel \
      mock \
      'tensorflow-gpu=2.0.*' && \
      # keras-preprocessing \
      # keras-applications \
      # keras-gpu \
      # tensorboard && \
      # pip install tensorflow-gpu && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn
#      && \
# RUN git clone git://github.com/keras-team/keras.git /src && pip install -e /src[tests] && \
#     pip install git+git://github.com/keras-team/keras.git && \
#     conda clean -yt

# Clone Official Tensorflow models
ARG TF_MODELS_VERSION=master
ENV TF_MODELS_VERSION=${TF_MODELS_VERSION}
RUN git clone -b ${TF_MODELS_VERSION} https://github.com/tensorflow/models.git /src/models
ENV PYTHONPATH="$PYTHONPATH:/src/models"

EXPOSE 6006
