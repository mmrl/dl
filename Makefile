help:
	@cat Makefile

# Define build variables
TAG?=mmrl/dl
PYTHON_VERSION?=3.7
CUDA_VERSION?=10.0
CUDNN_VERSION?=7
UID?=1000
DOCKER_FILE=Dockerfile

# Define run variables
VOLUME?=deepnet
HOST_PORT?=8888
TB_HOST_PORTS?=6006-6015
TB_PORTS?=$(TB_HOST_PORTS)
GPU?=all
DOCKER=GPU=$(GPU) nvidia-docker
# DOCKER=docker run --gpus=$(GPU)

# Define directories within the image
CODE_PATH?="/work/code"
DATA_PATH?="/work/data"
LOGS_PATH?="/work/logs"
MODELS_PATH?="/work/models"
NOTEBOOKS_PATH?="/work/notebooks"
RESULTS_PATH?="/work/results"
TEST=tests/

all: base build keras pytorch

.PHONY: help all base build keras pytorch prune nuke clean bash ipython lab notebook test tensorboard tabs push release info verbose

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

# Make /work a volume and mount any defined subdirectories
MOUNTS := -v $(VOLUME):/work
ifdef CODE
MOUNTS += -v $(CODE):$(CODE_PATH)
endif
ifdef DATA
MOUNTS += -v $(DATA):$(DATA_PATH)
endif
ifdef LOGS
MOUNTS += -v $(LOGS):$(LOGS_PATH)
endif
ifdef MODELS
MOUNTS += -v $(MODELS):$(MODELS_PATH)
endif
ifdef NOTEBOOKS
MOUNTS += -v $(NOTEBOOKS):$(NOTEBOOKS_PATH)
endif
ifdef RESULTS
MOUNTS += -v $(RESULTS):$(RESULTS_PATH)
endif

# Define Jupyter port
PORTS := -p $(HOST_PORT):8888

run:
	@echo $(MOUNTS)

bash ipython: PORTS += -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS)
bash ipython: build
	$(DOCKER) run -it --init --name $(notdir $(TAG))-$@ $(MOUNTS) $(PORTS) $(TAG) $@

lab: PORTS += -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS)
lab: build
	$(DOCKER) run -it --init --rm --name $(subst /,_,$(TAG))-lab $(MOUNTS) $(PORTS) $(TAG)

notebook: PORTS += -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS)
notebook: build
	$(DOCKER) run -it --init --name $(subst /,_,$(TAG))-nb $(MOUNTS) $(PORTS) $(TAG) \
			jupyter notebook --port=8888 --ip=0.0.0.0 --notebook-dir=$(NOTEBOOKS_PATH)

test: build
	$(DOCKER) run -it --init \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  $(TAG) py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it --init $(MOUNTS) -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS) $(TAG) tensorboard --logdir=$(LOGS_PATH)

tabs: build
	# $(DOCKER) run -d --name $(subst /,_,$(TAG))-tbd $(MOUNTS) -p 0.0.0.0:6006:6006 $(TAG) tensorboard --logdir=$(LOGS_PATH)
	$(DOCKER) run -d --name $(subst /,_,$(TAG))-tbd \
				  -v $(LOGS):$(LOGS_PATH) \
				  -p 0.0.0.0:6006:6006 \
				  $(TAG) tensorboard --logdir=$(LOGS_PATH)
	# $(LOGS) may need to be a volume to share between containers
	$(DOCKER) run -it --init --name $(subst /,_,$(TAG))-lab \
				  -v $(LOGS):$(LOGS_PATH) \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  -p $(HOST_PORT):8888 \
				  $(TAG)

push: # build
	# $(DOCKER) tag $(TAG) $(NEWTAG)
	$(DOCKER) push $(TAG)

release: build push

info:
	@echo "Mounts: $(MOUNTS)"
	@echo "Ports: $(PORTS)"
	lsb_release -a
	$(DOCKER) -v
	$(DOCKER) run -it --rm $(TAG) nvidia-smi

verbose: info
	$(DOCKER) system info