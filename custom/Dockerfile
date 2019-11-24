ARG BASE_CONTAINER=mmrl/dl-base
FROM $BASE_CONTAINER

# Use the environment.yml to create the conda environment.
# https://fmgdata.kinja.com/using-docker-with-conda-environments-1790901398
COPY environment.yml /tmp/environment.yml
# RUN [ "conda", "update", "conda", "-y" ]
# RUN [ "conda", "update", "--all", "-y" ]

# RUN [ -s /tmp/environment.yml ] && conda env update -n root -f /tmp/environment.yml

WORKDIR /tmp
RUN [ "conda", "env", "update", "-n", "root", "-f", "environment.yml" ]
# https://github.com/ian-r-rose/binder-workspace-demo/
# Set custom Jupyter lab settings
COPY jupyterlab.settings ${HOME}/.jupyter/lab/user-settings/.
# Import custom Jupyter lab workspace
COPY workspace.json .
RUN jupyter lab workspaces import /tmp/workspace.json
WORKDIR /work
# CMD [ "exec python run.py" ]
