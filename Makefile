help:
	@cat Makefile

DATA?="${HOME}/data"
RESULTS?="${HOME}/results"
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
	git pull
	$(DOCKER) build -t mmrl/dl --no-cache --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) --build-arg NB_UID=$(UID) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results --env KERAS_BACKEND=$(BACKEND) mmrl/dl bash

ipython: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results --env KERAS_BACKEND=$(BACKEND) mmrl/dl ipython

lab: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results --net=host --env KERAS_BACKEND=$(BACKEND) mmrl/dl

notebook: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results --net=host --env KERAS_BACKEND=$(BACKEND) mmrl/dl jupyter notebook --port=8888 --ip=0.0.0.0

test: build
	$(DOCKER) run -it -v $(SRC):/work/src -v $(DATA):/work/data -v $(RESULTS):/work/results --env KERAS_BACKEND=$(BACKEND) mmrl/dl py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it -v $(RESULTS):/work/results -v $(LOGS):/work/logs -p 0.0.0.0:6006:6006 --env KERAS_BACKEND=$(BACKEND) mmrl/dl tensorboard --logdir=/logs

info: build
	$(DOCKER) system info
	$(DOCKER) run -it --rm mmrl/dl nvidia-smi
