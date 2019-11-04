help:
	@cat Makefile

DATA?="${HOME}/data"
RESULTS?="${HOME}/results"
VOLUME?=deepnet
UID?=1000
HOST_PORT?=8888
GPU?=all
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) nvidia-docker
# DOCKER=docker run --gpus=$(GPU)
TAG?=mmrl/dl
PYTHON_VERSION?=3.7
CUDA_VERSION?=10.0
CUDNN_VERSION?=7
TEST=tests/
SRC?=$(shell dirname `pwd`)
LOGS?="${HOME}/logs"

all: base build keras pytorch

.PHONY: help all base build keras pytorch prune nuke clean bash ipython lab vlab notebook test tensorboard tabs push info verbose

build:
	echo "Building $(TAG) image..."
	$(DOCKER) build -t $(TAG) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
							  --build-arg CUDA_VERSION=$(CUDA_VERSION) \
							  --build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
							  --build-arg NB_UID=$(UID) \
							  -f $(DOCKER_FILE) .

base:
	echo "Building $@ image..."
	$(DOCKER) build -t mmrl/dl-base \
					--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
					--build-arg CUDA_VERSION=$(CUDA_VERSION) \
					--build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
					--build-arg NB_UID=$(UID) \
					-f base/$(DOCKER_FILE) .

keras pytorch: base
	echo "Building $@ image..."
	$(DOCKER) build -t mmrl/dl-$@ -f $@/$(DOCKER_FILE) .

prune:
	$(DOCKER) system prune -f

nuke:
	$(DOCKER) system prune --volumes

clean: prune
	git pull
	$(DOCKER) build -t $(TAG) \
					--no-cache \
					--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
					--build-arg CUDA_VERSION=$(CUDA_VERSION) \
					--build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
					--build-arg NB_UID=$(UID) \
					-f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -it --init \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  -p 6006:6006 \
				  $(TAG) bash

ipython: build
	$(DOCKER) run -it --init --name $(TAG)-ipy \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  $(TAG) ipython

lab: build
	$(DOCKER) run -it --init --name $(TAG)-lab \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  -p 6006:6006 \
				  -p $(HOST_PORT):8888 \
				  $(TAG)

vlab: build
	$(DOCKER) run -it --init \
				  -v $(VOLUME):/work \
				  -p $(HOST_PORT):8888 \
				  $(TAG)

notebook: build
	$(DOCKER) run -it --init --name $(TAG)-nb \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  -p $(HOST_PORT):8888 \
				  $(TAG) jupyter notebook --port=8888 --ip=0.0.0.0 --notebook-dir='/work/notebooks'

test: build
	$(DOCKER) run -it --init \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  $(TAG) py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it --init \
				  -v $(LOGS):/work/logs \
				  -p 0.0.0.0:6006:6006 \
				  $(TAG) tensorboard --logdir=/work/logs

tabs: build
	$(DOCKER) run -d --name dl-tbd \
				  -v $(LOGS):/work/logs \
				  -p 0.0.0.0:6006:6006 \
				  $(TAG) tensorboard --logdir=/work/logs
	$(DOCKER) run -it --init --name dl-lab \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  -p $(HOST_PORT):8888 \
				  $(TAG)

push: build
	# $(DOCKER) tag $(TAG) $(NEWTAG)
	$(DOCKER) push $(TAG)

info:
	lsb_release -a
	$(DOCKER) -v
	$(DOCKER) run -it --rm $(TAG) nvidia-smi

verbose: info
	$(DOCKER) system info