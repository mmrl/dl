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
      # 'cudatoolkit>=${cuda_version}' \
      # 'cudatoolkit>=10.0' \
      # theano \
      wheel \
      mock \
      tensorflow-gpu \
      keras \
      # keras-preprocessing \
      # keras-applications \
      tensorboard && \
      conda clean --all -f -y && \
      npm cache clean --force && \
      rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
      rm -rf /home/$NB_USER/.cache/yarn
#      && \
# RUN git clone git://github.com/keras-team/keras.git /src && pip install -e /src[tests] && \
#     pip install git+git://github.com/keras-team/keras.git && \
#     conda clean -yt

# COPY theanorc /home/thedude/.theanorc

EXPOSE 6006
