help:
	@cat Makefile

DATA?="${HOME}/data"
UID?=1000
GPU?=0
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) nvidia-docker
BACKEND=tensorflow
PYTHON_VERSION?=3.6
CUDA_VERSION?=10.0
CUDNN_VERSION?=7
TEST=tests/
SRC?=$(shell dirname `pwd`)
LOGS?="${HOME}/logs"

build:
	$(DOCKER) build -t mmrl/dl --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

prune:
	$(DOCKER) system prune -f

nuke:
	$(DOCKER) system prune --volumes

clean: prune
	$(DOCKER) build -t mmrl/dl --no-cache --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -it -v $(SRC):/workspace/src -v $(DATA):/workspace/data --env KERAS_BACKEND=$(BACKEND) mmrl/dl bash

ipython: build
	$(DOCKER) run -it -v $(SRC):/workspace/src -v $(DATA):/workspace/data --env KERAS_BACKEND=$(BACKEND) mmrl/dl ipython

lab: build
	$(DOCKER) run -it -v $(SRC):/workspace/src -v $(DATA):/workspace/data --net=host --env KERAS_BACKEND=$(BACKEND) mmrl/dl

notebook: build
	$(DOCKER) run -it -v $(SRC):/workspace/src -v $(DATA):/workspace/data --net=host --env KERAS_BACKEND=$(BACKEND) mmrl/dl jupyter notebook --port=8888 --ip=0.0.0.0

test: build
	$(DOCKER) run -it -v $(SRC):/workspace/src -v $(DATA):/workspace/data --env KERAS_BACKEND=$(BACKEND) mmrl/dl py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it -v $(SRC):/workspace/src -v $(DATA):/workspace/data -v $(LOGS):/workspace/logs -p 0.0.0.0:6006:6006 --env KERAS_BACKEND=$(BACKEND) mmrl/dl tensorboard --logdir=/logs

info:
	$(DOCKER) system info
