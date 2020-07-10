help:
	@cat Makefile

# Define build variables
STEM?=mmrl/dl
TAG?=latest
BASE_TAG?=latest
PYTHON_VERSION?=3.8
CUDA_VERSION?=10.1
CUDNN_VERSION?=7
TENSORFLOW_VERSION?=2.2
TF_MODELS_VERSION?=master
PYTORCH_VERSION?=1.5
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
SCRIPTS_PATH?="/work/scripts"
TEMP_PATH?="/work/temp"
TEST=tests/

all: base build tensorflow pytorch

.PHONY: help all base build tensorflow pytorch prune nuke clean bash ipython lab notebook test tensorboard tabs push release info verbose

# build: IMAGE := $(STEM):$(TAG)
ifndef IMAGE
ifdef TAG
IMAGE := $(STEM):$(TAG)
else
IMAGE := $(STEM)
endif
endif
build:
	echo "Building $(IMAGE) image..."
	echo "PYTHON_VERSION=$(PYTHON_VERSION)"
	echo "CUDA_VERSION=$(CUDA_VERSION)"
	echo "CUDNN_VERSION=$(CUDNN_VERSION)"
	echo "TENSORFLOW_VERSION=$(TENSORFLOW_VERSION)"
	echo "PYTORCH_VERSION=$(PYTORCH_VERSION)"
	$(DOCKER) build -t $(IMAGE) \
					--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
					--build-arg CUDA_VERSION=$(CUDA_VERSION) \
					--build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
					--build-arg NB_UID=$(UID) \
					--build-arg TENSORFLOW_VERSION=$(TENSORFLOW_VERSION) \
					--build-arg TF_MODELS_VERSION=$(TF_MODELS_VERSION) \
					--build-arg PYTORCH_VERSION=$(PYTORCH_VERSION) \
					-f $(DOCKER_FILE) .
	$(DOCKER) tag $(IMAGE) $(STEM):latest

# base:
# 	echo "Building $@ image..."
# 	$(DOCKER) build -t mmrl/dl-base \
# 					--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
# 					--build-arg CUDA_VERSION=$(CUDA_VERSION) \
# 					--build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
# 					--build-arg NB_UID=$(UID) \
# 					-f base/$(DOCKER_FILE) $@

# tensorflow pytorch: base
# 	echo "Building $@ image..."
# 	$(DOCKER) build -t mmrl/dl-$@ -f $@/$(DOCKER_FILE) $@

base: BUILD_ARGS := --build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
					--build-arg CUDA_VERSION=$(CUDA_VERSION) \
					--build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
					--build-arg NB_UID=$(UID)
base: IMAGE := $(STEM)-base:$(CUDA_VERSION)
tensorflow: BUILD_ARGS := --build-arg TAG=$(BASE_TAG) \
						--build-arg TENSORFLOW_VERSION=$(TENSORFLOW_VERSION) \
						--build-arg TF_MODELS_VERSION=$(TF_MODELS_VERSION)
tensorflow: IMAGE := $(STEM)-tensorflow:$(TENSORFLOW_VERSION)
pytorch: BUILD_ARGS := --build-arg TAG=$(BASE_TAG) \
						--build-arg PYTORCH_VERSION=$(PYTORCH_VERSION)
pytorch: IMAGE := $(STEM)-pytorch:$(PYTORCH_VERSION)
tensorflow pytorch: base
base tensorflow pytorch:
	echo "Building $@ image..."
	$(DOCKER) build -t $(IMAGE) $(BUILD_ARGS) -f $@/$(DOCKER_FILE) .
	# $(DOCKER) build -t $(IMAGE) $(BUILD_ARGS) -f $@/$(DOCKER_FILE) $@
	# $(DOCKER) build -t mmrl/dl-$@ $(BUILD_ARGS) -f $@/$(DOCKER_FILE) $@
	# $(DOCKER) build -t mmrl/dl-$@ \
	# 				--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	# 				--build-arg CUDA_VERSION=$(CUDA_VERSION) \
	# 				--build-arg CUDNN_VERSION=$(CUDNN_VERSION) \
	# 				--build-arg NB_UID=$(UID) \
	# 				-f $@/$(DOCKER_FILE) $@

prune:
	$(DOCKER) system prune -f

nuke:
	$(DOCKER) system prune --volumes

clean: prune
	git pull
	$(DOCKER) build -t $(IMAGE) \
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
ifdef SCRIPTS
MOUNTS += -v $(SCRIPTS):$(SCRIPTS_PATH)
endif
ifdef TEMP
MOUNTS += -v $(TEMP):$(TEMP_PATH)
endif

# Define Jupyter port
PORTS := -p $(HOST_PORT):8888

run:
	@echo $(MOUNTS)

# bash ipython: PORTS += -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS)
# $(PORTS)
bash ipython: build
	$(DOCKER) run -it --init --name $(notdir $(STEM))-$@ $(MOUNTS) $(IMAGE) $@

# The flag --cap-add=CAP_SYS_ADMIN is needed to avoid CUPTI_ERROR_INSUFFICIENT_PRIVILEGES
# when using the profiler (through tensorboard). This should be resolved in CUDA 11 / TF 2.4
# See: https://github.com/tensorflow/profiler/issues/63
# If that fails, try `--privileged=true`: https://github.com/tensorflow/tensorflow/issues/35860
# https://developer.nvidia.com/nvidia-development-tools-solutions-err-nvgpuctrperm-cupti
# This will likely be fixed in TF 2.4 / CUDA 11

# To disable the build dependency use `make lab -o build ...`
lab: PORTS += -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS)
lab: build
	$(DOCKER) run -it --init --rm --cap-add=CAP_SYS_ADMIN --name $(subst /,_,$(STEM))-lab $(MOUNTS) $(PORTS) $(IMAGE)

notebook: PORTS += -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS)
notebook: build
	$(DOCKER) run -it --init --cap-add=CAP_SYS_ADMIN --name $(subst /,_,$(STEM))-nb $(MOUNTS) $(PORTS) $(IMAGE) \
			jupyter notebook --port=8888 --ip=0.0.0.0 --notebook-dir=$(NOTEBOOKS_PATH)

test: build
	$(DOCKER) run -it --init \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  $(IMAGE) py.test $(TEST)

tensorboard: build
	$(DOCKER) run -it --init $(MOUNTS) -p 0.0.0.0:$(TB_HOST_PORTS):$(TB_PORTS) $(IMAGE) tensorboard --logdir=$(LOGS_PATH)

tabs: build
	# $(DOCKER) run -d --name $(subst /,_,$(STEM))-tbd $(MOUNTS) -p 0.0.0.0:6006:6006 $(IMAGE) tensorboard --logdir=$(LOGS_PATH)
	$(DOCKER) run -d --name $(subst /,_,$(STEM))-tbd \
				  -v $(LOGS):$(LOGS_PATH) \
				  -p 0.0.0.0:6006:6006 \
				  $(IMAGE) tensorboard --logdir=$(LOGS_PATH)
	# $(LOGS) may need to be a volume to share between containers
	$(DOCKER) run -it --init --cap-add=CAP_SYS_ADMIN --name $(subst /,_,$(STEM))-lab \
				  -v $(LOGS):$(LOGS_PATH) \
				  -v $(SRC):/work/code \
				  -v $(DATA):/work/data \
				  -v $(RESULTS):/work/results \
				  -p $(HOST_PORT):8888 \
				  $(IMAGE)

push: # build
	# $(DOCKER) tag $(TAG) $(NEWTAG)
	$(DOCKER) push $(IMAGE)

release: build push

info:
	@echo "Mounts: $(MOUNTS)"
	@echo "Ports: $(PORTS)"
	lsb_release -a
	$(DOCKER) -v
	$(DOCKER) run -it --rm $(IMAGE) nvidia-smi

verbose: info
	$(DOCKER) system info
