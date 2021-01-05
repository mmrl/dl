# MMRL Docker images for deep learning

[![Docker Pulls](https://img.shields.io/docker/pulls/mmrl/dl.svg?style=popout)](https://hub.docker.com/r/mmrl/dl) [![docker stars](https://img.shields.io/docker/stars/mmrl/dl.svg)](https://hub.docker.com/r/mmrl/dl) [![image metadata](https://images.microbadger.com/badges/image/mmrl/dl.svg)](https://microbadger.com/images/mmrl/dl "mmrl/dl image metadata")

This directory contains files to build [Docker](http://www.docker.com/) images - encapsulated computational containers which enhance reproducibility for scientific research. They are similar in design philosophy to the excellent [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks) but with a focus on making it easy to get up and running with GPU-accelerated deep learning. The base image provides a Jupyter Lab (notebook) environment in a Docker container which has direct access to the host system's GPU(s). Several variants with popular deep learning libraries are available to choose from which currently include:

* `mmrl/dl-base` [![image metadata](https://images.microbadger.com/badges/image/mmrl/dl-base.svg)](https://microbadger.com/images/mmrl/dl-base "mmrl/dl-base image metadata"): Contains Jupyter and other useful packages but no DL libraries
* `mmrl/dl-pytorch` [![image metadata](https://images.microbadger.com/badges/image/mmrl/dl-pytorch.svg)](https://microbadger.com/images/mmrl/dl-pytorch "mmrl/dl-pytorch image metadata"): PyTorch (built on top of `mmrl/dl-base`)
* `mmrl/dl-tensorflow` [![image metadata](https://images.microbadger.com/badges/image/mmrl/dl-tensorflow.svg)](https://microbadger.com/images/mmrl/dl-tensorflow "mmrl/dl-tensorflow image metadata"): TensorFlow (built on top of `mmrl/dl-base`)

Additionally there is a `custom` directory with instructions and examples for building your own image. These are considered stable but may be moved to their own repositories in future.

The instructions below refer to the combined (default) image `mmrl/dl` (based on the Keras Dockerfile) which contains ALL TEH THINGZ!!! This is used for development and considered experimental, so may be removed in the future (as it should really be tagged `bloaty-mcbloatface`!). This tag `mmrl/dl` may be substituted for any of the above tags when following the [instructions below](#running-the-container) to use a leaner image.

If you already have a working Docker/nvidia-docker installation, skip to [Running the container](#running-the-container) for a quick start, otherwise work through the installation steps below. Alternatively, try the `mmrl/dl` image on binder without installing anything. 

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/mmrl/dl/master)

## Installation
<details><summary>Click here to see installation instructions.</summary><p>

The following instructions are for setting up Docker with GPU support on Linux (in particular Ubuntu although the commands may be adapted for other distributions). Windows 10 users should also now be able to set up Docker with GPU support using WSL2 by following [this guide](https://ubuntu.com/blog/getting-started-with-cuda-on-ubuntu-on-wsl-2).

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

Note, if the `nvidia-drm` module is in use, it may be necessary to drop into a text console as root to disable the graphical target:
    
    $ systemctl isolate multi-user.target

Next unload the module:

    $ modprobe -r nvidia-drm

Install/upgrade the drive, then re-enable the graphical environment and finally reboot:

    $ systemctl start graphical.target

If you have multiple GPUs, you can run `nvidia-smi -pm 1` to enable persistent mode, which will save some time from loading the driver. It will have a significant effect on machines with more than 4 GPUs. Alternatively install the [Persistence Daemon](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#install-persistenced) by running the following command at boot:

    $ /usr/bin/nvidia-persistenced --verbose

### [Optional] Install CUDA and cuDNN on the host

Optionally, you can also install CUDA (and cuDNN) on the host if you wish to use your GPU without the Docker image. This can be safely skipped if you intend to use Docker for computations however, as CUDA and cuDNN are included in the images. For example, these are the instructions for [Ubuntu 64bit](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu-installation) assuming release 18.10 and CUDA version 10.1.168-1:

    $ sudo dpkg -i cuda-repo-ubuntu1810_10.1.168-1_amd64.deb
    $ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1810/x86_64/7fa2af80.pub
    $ sudo apt-get update
    $ sudo apt-get install cuda

Remember to reboot the system to load the NVIDIA drivers.

N.B. Although the CUDA version installed above is 10.1 which is incompatible with current releases of TensorFlow, CUDA 10.0 will be mounted in the Docker image so that the libraries will work properly. If preferred, CUDA 10.0 can be installed on the host from [here](https://developer.nvidia.com/cuda-10.0-download-archive) or omitted entirely since it is sufficient to install only the drivers on the host.

##### Post-installation
If you installed CUDA/cuDNN on the host, there are a few [additional steps](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions) which need to be performed manually e.g.:

Set the following environment variables e.g. by editing `~/.bashrc`, `/etc/environment`, `/etc/profile` or adding a `.sh` script to `/etc/profile.d/`:

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

Note: Starting from version `19.03`, Docker supports the `--gpus` option for making GPUs available at runtime (and [buildtime](https://github.com/NVIDIA/nvidia-docker/wiki#can-i-use-the-gpu-during-a-container-build-ie-docker-build)). Consequently, the previously required [`nvidia-container-toolkit`](https://nvidia.github.io/nvidia-docker/) is deprecated and no longer necessary.  

* Verify the installation
```
$ docker run --gpus all --rm nvidia/cuda nvidia-smi
```
You should see something like this showing the GPUs available to Docker:

```
Wed Sep 25 13:09:12 2019       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 430.26       Driver Version: 430.26       CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  TITAN Xp            Off  | 00000000:05:00.0  On |                  N/A |
| 23%   31C    P8     9W / 250W |    113MiB / 12192MiB |      0%      Default |
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
</p></details>

## Running the container

To launch the image with GPU support and mount the present working directory in the container's source code directory type (or replace `mmrl/dl` with whichever image you prefer e.g. `mmrl/dl-pytorch`):

    $ docker run --gpus all -it --init --rm -p 8888:8888 -v $(pwd):/work/code mmrl/dl

Then open a browser and enter the following URL if you are running the container locally:
```
http://127.0.0.1:8888
```
(If you're running the container on a remote server, replace 127.0.0.1 with the name or IP address of the server.)
You will then be asked for a token which you can copy and paste from the terminal output that looks something like this:
```
http://(<HOSTNAME> or 127.0.0.1):8888/?token=5233b0<...>8afd2a
```
N.B. If docker complains that the port is in use, then you need to map the Jupyter port to a different host port e.g. `-p 8889:8888` and update the URL accordingly. 

## Container directory structure

On launching a `mmrl/dl` container, the project directory is set to `/work` which contains the following subdirectories:

```
.
├── code        # Place code and scripts here
├── data        # Place or mount input data sets here
├── logs        # Contains the outputs for tensorboard
├── models      # Save model data and metadata here
├── notebooks   # Working directory for notebooks
└── results     # Save model outputs here
```

The `/work` directory is set as a [Docker Volume](https://docs.docker.com/storage/volumes/) meaning that changes made here will persist on the host's file storage. To access the same changes across multiple runs, simply use the same volume name whenever you launch the container e.g. `-v deepnet:/work` (here called `deepnet`). Files may then be copied between the volume (`deepnet`) and the host with [`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/) commands when required. Code and data may also be cloned and downloaded within the running container using the provided tools (`git`, `rsync`, `curl` and `wget`).

Alternatively, directories from the host computer can be mounted over as many of these individual subdirectories as required e.g. `-v $(pwd)/ImageNet:/work/data -v $(pwd)/repo:/work/code` or an entire project directory (which should contain the same layout) can be mounted over the whole working directory e.g. `-v $(pwd):/work`. These [bind mounts](https://docs.docker.com/storage/bind-mounts/) directly share the files between the container and the host, giving full access to the container processes (e.g. writing and deleting) so care should be taken when using this method. For more information, see the [Docker storage](https://docs.docker.com/storage/) pages.

## Tensorboard

Tensorboard is provided in order to track the training of your model and explore its various properties (see [this overview](https://www.tensorflow.org/tensorboard/get_started) for how to use it). 

When staring the Docker container, it is necessary to [publish](https://docs.docker.com/engine/reference/commandline/run/#publish-or-expose-port--p---expose) (forward) the Tensorboard port(s) by including the following argument in the `docker run` command: `-p 0.0.0.0:6006:6006`, in the format `ip:hostPort:containerPort`. To use multiple instances of Tensorboard in the same container, a range of ports can be forwarded instead e.g.: `-p 0.0.0.0:6006-6015:6006-6015`. 

To launch an instance of Tensorboard within a notebook, run the following commands:

```
%load_ext tensorboard
%tensorboard --logdir /work/logs --port 6006 --bind_all
```

If an instance is alreay using the assigned port, find the process id (`pid`):

$ ps -ef | grep 6006

This process can then be killed:

$ kill -9 <pid>

This frees the port and should allow you to successfully launch Tensorboard. 

## Permissions

The images are built by default with user `thedude` which has `UID 1000` and `GID 100` (`users`). In Docker, UIDs are shared by the linux kernel (but not usernames) so if you mount host folders in the container, files created by the container will therefore be owned by this UID/GID (the username does not matter). You may then need to change the permissions on the host if the UIDs/GIDs do not match for the host user to read and edit them. Similarly, the owner of data mounted within the container may not match the UID/GID of the user within the container, potentially causing you to be unable to read, modify or execute files in the mounted folder from within the running container.

There are currently several solutions:

* Change the group of your host folders to `GID 100` and give `r+w` permissions to this group.
* Add the arguments: `-u root -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R'` to `docker run` (See: https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html). You may also need to start `jupter lab` with `--allow-root`. 
* Change the `UID`/`GID` of the container user with the following commands:
    ```
    $ usermod -u 1000 thedude
    $ groupmod -g 100 thedude
    ```
    Replacing `1000` and `100` with the `UID` and `GID` of the host user.
* Run the container with the argument `--user $(id -u):$(id -g)` (the user may also be given additional group membership with: `--group-add`).
* Similarly, use [fixuid](https://boxboat.com/2017/07/25/fixuid-change-docker-container-uid-gid/) and pass host user IDs at runtime. This also updates all files in the container owned by `thedude` and fixes the `$HOME` variable.
* Rebuild the image specifying the `UID`: `--build-arg NB_UID=$(id -u)`.

## Building and running your own container

A `Makefile` is provided to simplify common docker commands with make commands. By default the `Makefile` assumes you are using `mmrl/dl` but any image may be selected by setting the `TAG` variable (e.g. `make lab TAG=mmrl/dl-tensorflow`).

Build the container and run the Jupyter lab interface

    $ make lab

Alternatively, build the container and start a Jupyter Notebook

    $ make notebook

Build the container and start an iPython shell

    $ make ipython

Build the container and start a bash shell

    $ make bash

To restrict access to a specific GPU in the container

    $ make notebook GPU=0  # or [ipython, bash]

Mount a volume for external data sets

    $ make DATA=~/mydata

Display system info

    $ make info

Prints all make tasks

    $ make help

## Advanced - Customising your own container

The above `docker run` command will pull the [ready-made Docker image for deep learning](https://hub.docker.com/r/mmrl/dl) from the [MMRL repository on Docker Hub](https://hub.docker.com/u/mmrl), however you can use it as a base image and customise it to your needs.

Create your own Dockerfile and start with the following line to inherit all the features of the `mmrl/dl-base` container:

```
FROM mmrl/dl-base
```

Alternatively, see the custom directory for example files.

## Resources

* [Docker](https://awesome-docker.netlify.com/)
* [Keras](https://github.com/fchollet/keras-resources)
* [TensorFlow](https://www.tensorflow.org/resources/models-datasets)
* [Using TensorBoard in Notebooks](https://www.tensorflow.org/tensorboard/tensorboard_in_notebooks)
* [PyTorch](https://pytorch.org/resources/)
