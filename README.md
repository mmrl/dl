# Using the MMRL Docker image for deep learning

This directory contains `Dockerfile` to make it easy to get up and running with
deep learning via [Docker](http://www.docker.com/).

## Installation

Install the latest nvidia drivers
* [Ubunutu](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu-installation)

### Installing Docker

General installation instructions are
[on the Docker site](https://docs.docker.com/install/), but we give some
quick links here:

* [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
* [macOS](https://docs.docker.com/docker-for-mac/install/)
* [Windows](https://docs.docker.com/docker-for-windows/install/)

### Installing nvidia-docker

* [Add the nvidia repository](https://nvidia.github.io/nvidia-docker/)
These instructions are for Ubuntu. For other distributions, see [here](https://nvidia.github.io/nvidia-docker/).

```
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
```

* Install the nvidia-docker2 package

```
sudo apt-get install nvidia-docker2
sudo pkill -SIGHUP dockerd
```

* Verify the installation

`docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi`

## Quick start - Running the container

To launch the image with GPU support and mount the present working directory in the container type:

    $ docker run --runtime=nvidia -it --rm -v $(pwd):/workspace/src mmrl/dl

Then open a browser and enter the following URL if your running the container locally:

    $ http://127.0.0.1:8888

(If you're running the container on a remote server, replace 127.0.0.1 with the name or IP address of the server.)
You will then be asked for a token which you can copy and paste from the terminal output that looks something like this:

```
http://(kraken or 127.0.0.1):8888/?token=5233b03f99e38bf5c5fc045abd65fbe154ef8ae1a48afd2a
```

## Advanced - Building and running your own container

We are using `Makefile` to simplify docker commands within make commands.

Build the container and start a Jupyter Notebook

    $ make notebook

Alternatively, run the container with the new Jupyter lab interface

    $ make lab

Build the container and start an iPython shell

    $ make ipython

Build the container and start a bash

    $ make bash

For GPU support install NVIDIA drivers (ideally latest) and
[nvidia-docker](https://github.com/NVIDIA/nvidia-docker). Run using

    $ make notebook GPU=0 # or [ipython, bash]

Switch between Theano and TensorFlow

    $ make notebook BACKEND=theano
    $ make notebook BACKEND=tensorflow

Mount a volume for external data sets

    $ make DATA=~/mydata

Prints all make tasks

    $ make help

You can change Theano parameters by editing `/docker/theanorc`.


Note: If you would have a problem running nvidia-docker you may try the old way
we have used. But it is not recommended. If you find a bug in the nvidia-docker report
it there please and try using the nvidia-docker as described above.

    $ export CUDA_SO=$(\ls /usr/lib/x86_64-linux-gnu/libcuda.* | xargs -I{} echo '-v {}:{}')
    $ export DEVICES=$(\ls /dev/nvidia* | xargs -I{} echo '--device {}:{}')
    $ docker run -it -p 8888:8888 $CUDA_SO $DEVICES gcr.io/tensorflow/tensorflow:latest-gpu
