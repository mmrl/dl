help:
	@cat Makefile

DATA?="${HOME}/data"
RESULTS?="${HOME}/results"
UID?=1000
HOST_PORT?=8888
GPU?=0
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) nvidia-docker
TAG?=mmrl/dl
PYTHON_VERSION?=3.6
CUDA_VERSION?=10.0
CUDNN_VERSION?=7
TEST=tests/
SRC?=$(shell dirname `pwd`)
LOGS?="${HOME}/logs"

build:
	$(DOCKER) build -t $(TAG) --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

prune:
	$(DOCKER) system prune -f

nuke:
	$(DOCKER) system prune --volumes

clean: prune
	git pull
	$(DOCKER) build -t $(TAG) --no-cache --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results -p 6006:6006 $(TAG) bash

ipython: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results $(TAG) ipython

lab: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results -p $(HOST_PORT):8888 $(TAG)

notebook: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results -p $(HOST_PORT):8888 $(TAG) jupyter notebook --port=8888 --ip=0.0.0.0

test: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results $(TAG) py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it -v $(RESULTS):/work/results -v $(LOGS):/work/logs -p 0.0.0.0:6006:6006 $(TAG) tensorboard --logdir=/logs

info: build
	$(DOCKER) system info
	$(DOCKER) run -it --rm $(TAG) nvidia-smi
