#===============================================================================
# Default User Options
#===============================================================================

# Build-time arguments
BASE_TAG     ?= latest
GCC_VERSION  ?= 9.2.0
GCC_OPTIONS  ?= "--enable-languages=c,c++ --disable-multilib --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl --target=x86_64-alpine-linux-musl --disable-libsanitizer --disable-libatomic --disable-libitm"

# Image name
DOCKER_IMAGE ?= leavesask/gcc
DOCKER_TAG   := $(GCC_VERSION)

#===============================================================================
# Variables and objects
#===============================================================================

# Append a suffix to the tag if the version number of GCC
# is specified
ifneq ($(BASE_TAG),latest)
    DOCKER_TAG = $(DOCKER_TAG)-alpine-$(BASE_TAG)
endif

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
                 --build-arg BASE_TAG=$(BASE_TAG) \
                 --build-arg GCC_VERSION=$(GCC_VERSION) \
                 --build-arg GCC_OPTIONS=$(GCC_OPTIONS) \
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
