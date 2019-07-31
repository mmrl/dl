FROM mmrl/dl:base
# https://github.com/keras-team/keras/blob/master/docker/Dockerfile
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile

# # Install Python packages and keras
# RUN conda install -y python=${python_version}
# RUN pip install --upgrade pip && \
#     pip install \
#       sklearn_pandas \
#       # tensorflow-gpu \
#       cntk-gpu
# ARG cuda_version=10.0

RUN conda install --quiet --yes \
      # mkl \
      # git \
      # setuptools \
      # cudatoolkit=${cuda_version} \
      wheel \
      mock \
      tensorflow-gpu \
      # keras-preprocessing \
      # keras-applications \
      keras-gpu \
      tensorboard && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn
#      && \
# RUN git clone git://github.com/keras-team/keras.git /src && pip install -e /src[tests] && \
#     pip install git+git://github.com/keras-team/keras.git && \
#     conda clean -yt

RUN git clone https://github.com/tensorflow/models.git /src/models
ENV PYTHONPATH="$PYTHONPATH:/src/models"

EXPOSE 6006
