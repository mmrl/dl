# Using the MMRL Docker image for deep learning

![Docker Pulls](https://img.shields.io/docker/pulls/mmrl/dl.svg?style=popout)

This directory contains files to build [Docker](http://www.docker.com/) images which make it easy to get up and running with GPU-accelerated deep learning. The base image provides a Jupyter Lab (notebook) environment in a Docker container which has direct access to the host system's GPU(s). Several variants with popular deep learning libraries are available to choose from (built on top of the base image - `mmrl/dl:base`) which currently include:

* `mmrl/dl:pytorch`: PyTorch
* `mmrl/dl:keras`: Keras and TensorFlow

Additionally there is a `custom` directory with instructions and examples for building your own image. These are considered experimental and may be moved to their own repositories in future. In the meantime, the instructions below refer to the combined image `mmrl/dl` (based on the Keras Dockerfile) which contains ALL TEH THINGZ!!!

## Installation

### 1. Installing NVIDIA drivers

#### 1. a) Run file

For the most versatility, download and install the NVIDIA drivers with the [run file](https://www.nvidia.com/Download/index.aspx?lang=en-in). This allows you to pass options to register the driver with the kernel `--dkms` (so the kernel can be updated without having to reinstall the driver) and optionally, use your onboard graphics for the display and make the NVIDIA GPU a headless computational device `--no-opengl-files` (freeing up the maximum resources for number crunching). For example on Ubuntu:

    $ sudo apt-get install build-essential gcc-multilib dkms
    $ chmod +x NVIDIA-Linux-x86_64-430.34.run
    $ sudo ./NVIDIA-Linux-x86_64-430.34.run --dkms --no-opengl-files
    $ sudo reboot

#### 1. b) Package Manager

As an alternative to the Run file, perhaps the simplest way to Install the latest NVIDIA drivers for Linux is through the [Package Manager](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#package-manager-installation).

For example with Ubuntu to install driver version 430:

    $ sudo add-apt-repository ppa:graphics-drivers
    $ sudo apt update
    $ sudo apt install nvidia-430
    $ sudo reboot

If you have multiple GPUs, you can run `nvidia-smi -pm 1` to enable persistent mode, which will save some time from loading the driver. It will have a significant effect on machines with more than 4 GPUs.

Optionally, you can also install CUDA (and cuDNN) on the host if you wish to use your GPU without the Docker image. For example, these are the instructions for [Ubuntu 64bit](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu-installation) assuming release 18.10 and CUDA version 10.1.168-1:

    $ sudo dpkg -i cuda-repo-ubuntu1810_10.1.168-1_amd64.deb
    $ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1810/x86_64/7fa2af80.pub
    $ sudo apt-get update
    $ sudo apt-get install cuda

Remember to reboot the system to load the NVIDIA drivers.

N.B. Although the CUDA version installed above is 10.1 which is incompatible with current releases of TensorFlow, CUDA 10.0 will be mounted in the Docker image so that the libraries will work properly. If preferred, CUDA 10.0 can be installed on the host from [here](https://developer.nvidia.com/cuda-10.0-download-archive) or omitted entirely since it is sufficient to install only the drivers on the host.

##### Post-installation
If you installed CUDA/cuDNN on the host, there are a few [additional steps](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions) which need to be performed manually e.g.:

Set the following environment variables e.g. by editing `~/.bashrc`:

    $ export PATH=/usr/local/cuda-10.1/bin${PATH:+:${PATH}}
    $ export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64\
                             ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

### 2. Installing Docker

General installation instructions are
[on the Docker site](https://docs.docker.com/install/), but we give some
quick links here:

* [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
* [macOS](https://docs.docker.com/docker-for-mac/install/)
* [Windows](https://docs.docker.com/docker-for-windows/install/)

### 3. Installing nvidia-docker

* [Add the NVIDIA repository](https://nvidia.github.io/nvidia-docker/)

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

To launch the image with GPU support and mount the present working directory in the container's source code directory type:

    $ docker run --runtime=nvidia -it --rm -p 8888:8888 -v $(pwd):/work/src mmrl/dl

Then open a browser and enter the following URL if you are running the container locally:

    $ http://127.0.0.1:8888

(If you're running the container on a remote server, replace 127.0.0.1 with the name or IP address of the server.)
You will then be asked for a token which you can copy and paste from the terminal output that looks something like this:

```
http://(<HOSTNAME> or 127.0.0.1):8888/?token=5233b0<...>8afd2a
```

## Container directory structure

On launching a `mmrl/dl` container, the working directory is set to `/work` which contains the following subdirectories:

```
.
├── data        # Place input data and image sets here
├── logs        # Contains the outputs for tensorboard
├── results     # Model outputs should be saved here
└── src         # Place code and scripts here
```

The `/work` is set as a [Docker Volume](https://docs.docker.com/storage/volumes/) meaning that changes made here will persist on the host's file storage. To access the same changes across multiple runs, simply use the same volume name whenever you launch the container e.g. `-v deepnet:/work` (here called `deepnet`). Files may then be copied between the volume (`deepnet`) and the host with [`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/) commands when required. Code and data may also be cloned and downloaded within the running container using the provided tools (`wget` and `git`). 

Alternatively, directories from the host computer can be mounted over as many of these individual subdirectories as required e.g. `-v $(pwd)/ImageNet:/work/data -v $(pwd)/repo:/work/src` or an entire project directory (which should contain the same layout) can be mounted over the whole working directory e.g. `-v $(pwd):/work`. These [bind mounts](https://docs.docker.com/storage/bind-mounts/) directly share the files between the container and the host, giving full access to the container processes (e.g. writing and deleting) so care should be taken when using this method. For more information, see the [Docker storage](https://docs.docker.com/storage/) pages. 

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

A `Makefile` is provided to simplify common docker commands with make commands.

Build the container and run the Jupyter lab interface

    $ make lab

Alternatively, build the container and start a Jupyter Notebook

    $ make notebook

Build the container and start an iPython shell

    $ make ipython

Build the container and start a bash shell

    $ make bash

For GPU support install NVIDIA drivers (ideally latest) and
[nvidia-docker](https://github.com/NVIDIA/nvidia-docker). Run using

    $ make notebook GPU=0  # or [ipython, bash]

Mount a volume for external data sets

    $ make DATA=~/mydata

Prints all make tasks

    $ make help

## Advanced - Customising your own container

The above `docker run` command will pull the [ready-made Docker image for deep learning](https://hub.docker.com/r/mmrl/dl) from the [MMRL repository on Docker Hub](https://hub.docker.com/u/mmrl), however you can use it as a base image and customise it to your needs.

Create your own Dockerfile and start with the following line to inherit all the features of the mmrl/dl container:

```
FROM mmrl/dl
```

Alternatively, see the custom directory for example files.
