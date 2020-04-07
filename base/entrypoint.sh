#!/bin/bash

# For additional ideas see: 
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/start.sh

# DIR=/docker-entrypoint.d
DIR=/work/scripts/entrypoint.d

if [[ -d "$DIR" ]]
then
    /bin/run-parts --verbose "$DIR"
fi

exec "$@"