ARG TAG=latest
FROM mmrl/dl-base:${TAG}
# https://github.com/keras-team/keras/blob/master/docker/Dockerfile
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile

ARG TENSORFLOW_VERSION=2.1
RUN conda install --quiet --yes \
      # mkl \
      # git \
      # setuptools \
      # cudatoolkit=${CUDA_VERSION} \
      wheel \
      mock \
      tensorflow-gpu=${TENSORFLOW_VERSION} && \
      # 'tensorflow-gpu=2.0.*' && \
      # 'tensorflow-gpu=2.1.*' && \
      # tensorboard && \
      # pip install tensorflow-gpu && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn

# Clone Official Tensorflow models
ARG TF_MODELS_VERSION=master
ENV TF_MODELS_VERSION=${TF_MODELS_VERSION}
RUN git clone -b ${TF_MODELS_VERSION} https://github.com/tensorflow/models.git /src/models
ENV PYTHONPATH="$PYTHONPATH:/src/models"

# Print versions
RUN python -c 'import tensorflow as tf; print(f"TensorFlow: {tf.__version__}")'
# tf.config.list_physical_devices('GPU')

EXPOSE 6006
