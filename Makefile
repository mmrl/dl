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
TAG?=mmrl/dl
PYTHON_VERSION?=3.7
CUDA_VERSION?=10.0
CUDNN_VERSION?=7
TEST=tests/
SRC?=$(shell dirname `pwd`)
LOGS?="${HOME}/logs"

all: base build keras pytorch
	# $(DOCKER) build -t mmrl/dl-keras -f keras/$(DOCKER_FILE) .
	# $(DOCKER) build -t mmrl/dl-pytorch -f pytorch/$(DOCKER_FILE) .

build:
	$(DOCKER) build -t $(TAG) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg CUDA_VERSION=$(CUDA_VERSION) --build-arg CUDNN_VERSION=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

base:
	$(DOCKER) build -t mmrl/dl-base --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg CUDA_VERSION=$(CUDA_VERSION) --build-arg CUDNN_VERSION=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f base/$(DOCKER_FILE) .

keras pytorch:
	$(DOCKER) build -t mmrl/dl-$@ -f $@/$(DOCKER_FILE) .

prune:
	$(DOCKER) system prune -f

nuke:
	$(DOCKER) system prune --volumes

clean: prune
	git pull
	$(DOCKER) build -t $(TAG) --no-cache --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg CUDA_VERSION=$(CUDA_VERSION) --build-arg CUDNN_VERSION=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -it --init -v $(SRC):/work/code -v $(DATA):/work/data -v $(RESULTS):/work/results -p 6006:6006 $(TAG) bash

ipython: build
	$(DOCKER) run --name $(TAG)-ipy -it --init -v $(SRC):/work/code -v $(DATA):/work/data -v $(RESULTS):/work/results $(TAG) ipython

lab: build
	$(DOCKER) run --name $(TAG)-lab -it --init -v $(SRC):/work/code -v $(DATA):/work/data -v $(RESULTS):/work/results -p 6006:6006 -p $(HOST_PORT):8888 $(TAG)

vlab: build
	$(DOCKER) run -it --init -v $(VOLUME):/work -p $(HOST_PORT):8888 $(TAG)

notebook: build
	$(DOCKER) run --name $(TAG)-nb -it --init -v $(SRC):/work/code -v $(DATA):/work/data -v $(RESULTS):/work/results -p $(HOST_PORT):8888 $(TAG) jupyter notebook --port=8888 --ip=0.0.0.0 --notebook-dir='/work/notebooks'

test: build
	$(DOCKER) run -it --init -v $(SRC):/work/code -v $(DATA):/work/data -v $(RESULTS):/work/results $(TAG) py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it --init -v $(LOGS):/work/logs -p 0.0.0.0:6006:6006 $(TAG) tensorboard --logdir=/work/logs

tabs: build
	$(DOCKER) run --name dl-tbd -d -v $(LOGS):/work/logs -p 0.0.0.0:6006:6006 $(TAG) tensorboard --logdir=/work/logs
	$(DOCKER) run --name dl-lab -it --init -v $(SRC):/work/code -v $(DATA):/work/data -v $(RESULTS):/work/results -p $(HOST_PORT):8888 $(TAG)

push: build
	# $(DOCKER) tag $(TAG) $(NEWTAG)
	$(DOCKER) push $(TAG)

info:
	lsb_release -a
	$(DOCKER) -v
	$(DOCKER) run -it --rm $(TAG) nvidia-smi

verbose: info
	$(DOCKER) system info