# Using the MMRL Docker image for deep learning

![Docker Pulls](https://img.shields.io/docker/pulls/mmrl/dl.svg?style=popout)

This directory contains files to build [Docker](http://www.docker.com/) images which make it easy to get up and running with GPU-accelerated deep learning. The base image provides a Jupyter Lab (notebook) environment in a Docker container which has direct access to the host system's GPU(s). Several variants with popular deep learning libraries are available to choose from (built on top of the base image) which currently include:

* `mmrl/dl:pytorch`: PyTorch
* `mmrl/dl:keras`: Keras and TensorFlow

## Installation

Install the latest nvidia drivers
* [Ubuntu](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu-installation)

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

You should see something like this showing the GPUs available:

```
Fri Apr 12 16:51:39 2019       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 418.56       Driver Version: 418.56       CUDA Version: 10.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  TITAN Xp            Off  | 00000000:05:00.0  On |                  N/A |
| 23%   30C    P8    10W / 250W |     72MiB / 12192MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  TITAN Xp            Off  | 00000000:09:00.0 Off |                  N/A |
| 23%   27C    P8     9W / 250W |      2MiB / 12196MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0      1361      G   /usr/lib/xorg/Xorg                            69MiB |
+-----------------------------------------------------------------------------+
```

## Quick start - Running the container

To launch the image with GPU support and mount the present working directory in the container type:

    $ docker run --runtime=nvidia -it --rm --net=host -v $(pwd):/workspace/src mmrl/dl

Then open a browser and enter the following URL if your running the container locally:

    $ http://127.0.0.1:8888

(If you're running the container on a remote server, replace 127.0.0.1 with the name or IP address of the server.)
You will then be asked for a token which you can copy and paste from the terminal output that looks something like this:

```
http://(<HOSTNAME> or 127.0.0.1):8888/?token=5233b0<...>8afd2a
```

## Permissions

The images are built by default with user `thedude` which has `UID 1000` and `GID 100` (`users`). In Docker, UIDs are shared by the linux kernel (but not usernames) so if you mount host folders in the container, files created by the container will therefore be owned by this UID/GID (the username does not matter). You may then need to change the permissions on the host if the UIDs/GIDs do not match for the host user to read and edit them. Similarly, the owner of data mounted within the container may not match the UID/GID of the user within the container, potentially causing you to be unable to read, modify or execute files in the mounted folder from within the running container.

There are currently several solutions:

1. Change the group of your host folders to GID 100 and give r+w permissions to this group.
2. Change the UID/GID of the container user with the following commands:
    $ usermod -u 1000 thedude
    $ groupmod -g 100 thedude
    Replacing 1000 and 100 with the UID and GID of the host user.
3. Run the container with the argument `--user $(id -u):$(id -g)` (the user may also be given additional group membership with: `--group-add`).
4. Similarly, use [fixuid](https://boxboat.com/2017/07/25/fixuid-change-docker-container-uid-gid/) and pass host user IDs at runtime. This also updates all files in the container owned by `thedude` and fixes the `$HOME` variable.
5. Rebuild the image specifying the UID: `--build-arg NB_UID=$(id -u)`.

## Advanced - Building and running your own container

We are using `Makefile` to simplify docker commands within make commands.

Build the container and start a Jupyter Notebook

    $ make notebook

Alternatively, run the container with the new Jupyter lab interface

    $ make lab

Build the container and start an iPython shell

    $ make ipython

Build the container and start a bash shell

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

## Advanced - Customising your own container

The above `docker run` command will pull the [ready-made Docker image for deep learning](https://hub.docker.com/r/mmrl/dl) from the [MMRL repository on Docker Hub](https://hub.docker.com/u/mmrl), however you can use it as a base image and customise it to your needs.

Create your own Dockerfile and start with the following line to inherit all the features of the mmrl/dl container:

```
FROM mmrl/dl
```
