[![Layers](https://images.microbadger.com/badges/image/leavesask/gcc.svg)](https://microbadger.com/images/leavesask/gcc)
[![Version](https://images.microbadger.com/badges/version/leavesask/gcc.svg)](https://hub.docker.com/repository/docker/leavesask/gcc)
[![Commit](https://images.microbadger.com/badges/commit/leavesask/gcc.svg)](https://github.com/K-Wone/docker-gcc)
[![Docker Pulls](https://img.shields.io/docker/pulls/leavesask/gcc?color=informational)](https://hub.docker.com/repository/docker/leavesask/gcc)
[![Automated Build](https://img.shields.io/docker/automated/leavesask/gcc)](https://hub.docker.com/repository/docker/leavesask/gcc)

# Supported tags

- `9.2.0`
- `8.3.0`
- `7.3.0`
- `5.5.0`

# How to use

1. [Install docker engine](https://docs.docker.com/install/)

2. Pull the image
  ```bash
  docker pull leavesask/gcc:<tag>
  ```

3. Run the image interactively
  ```bash
  docker run -it --rm leavesask/gcc:<tag>
  ```

# How to build

The base image is [spack](https://hub.docker.com/r/spack).

## make

There are a bunch of build-time arguments you can use to build the image.

It is highly recommended that you build the image with `make`.

```bash
# Build an image for GCC 9.2.0
make GCC_VERSION="9.2.0"

# Build and publish the image
make release GCC_VERSION="9.2.0"
```

Check `Makefile` for more options.

## docker build

As an alternative, you can build the image with `docker build` command.

```bash
docker build \
        --build-arg SPACK_IMAGE="spack/ubuntu-bionic" \
        --build-arg SPACK_VERSION="0.14" \
        --build-arg GCC_VERSION="9.2.0" \
        --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
        --build-arg VCS_REF=`git rev-parse --short HEAD` \
        -t my-repo/gcc:latest .
```

Arguments and their defaults are listed below.

- `GCC_VERSION`: The version of GCC supported by spack (defaults to `9.2.0`)
