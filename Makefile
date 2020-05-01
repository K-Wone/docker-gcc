#===============================================================================
# Default User Options
#===============================================================================

# Build-time arguments
SPACK_IMAGE   ?= spack/ubuntu-bionic
SPACK_VERSION ?= 0.14
GCC_VERSION   ?= 9.2.0

# Image name
DOCKER_IMAGE ?= leavesask/gcc
DOCKER_TAG   := $(GCC_VERSION)

#===============================================================================
# Variables and objects
#===============================================================================

BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_URL=$(shell git config --get remote.origin.url)

# Get the latest commit
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

#===============================================================================
# Targets to Build
#===============================================================================

.PHONY : docker_build docker_push output

default: build
build: docker_build output
release: docker_build docker_push output

docker_build:
	# Build Docker image
	docker build \
                 --build-arg SPACK_IMAGE=$(SPACK_IMAGE) \
                 --build-arg SPACK_VERSION=$(SPACK_VERSION) \
                 --build-arg GCC_VERSION=$(GCC_VERSION) \
                 --build-arg BUILD_DATE=$(BUILD_DATE) \
                 --build-arg VCS_URL=$(VCS_URL) \
                 --build-arg VCS_REF=$(GIT_COMMIT) \
                 -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Tag image as latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

output:
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)
