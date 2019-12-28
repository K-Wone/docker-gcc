# stage 1: build GCC
ARG BASE_VERSION=latest
FROM alpine:${BASE_VERSION} AS builder

# install basic buiding tools
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              build-base \
              isl-dev \
              linux-headers \
              make \
              mpc1-dev \
              musl \
              wget \
              which

# define environment variables for building GCC
ARG GCC_VERSION
ENV GCC_VERSION=${GCC_VERSION:-"9.2.0"}
ARG GCC_PREFIX
ENV GCC_PREFIX=${GCC_PREFIX:-"/opt/gcc/${GCC_VERSION}"}
ARG GCC_OPTIONS
ENV GCC_OPTIONS=${GCC_OPTIONS:-"--enable-languages=c,c++ --disable-multilib --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl --target=x86_64-alpine-linux-musl --disable-libsanitizer --disable-libatomic --disable-libitm --enable-bootstrap"}

ENV GCC_TARBALL="gcc-${GCC_VERSION}.tar.gz"

# build and install gcc
WORKDIR /tmp
RUN set -eux; \
      \
      wget "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/${GCC_TARBALL}"; \
      tar -zxf ${GCC_TARBALL}; \
      mkdir build_dir; \
      \
      cd gcc-${GCC_VERSION}; \
      ./contrib/download_prerequisites; \
      \
      cd ../build_dir; \
      ../gcc-${GCC_VERSION}/configure \
                  --prefix=${GCC_PREFIX} \
                  ${GCC_OPTIONS} \
      ;\
      make -j $(nproc) profiledbootstrap; \
      make install-strip; \
      rm -rf gcc-${GCC_VERSION} ${GCC_TARBALL} build_dir


# stage 2: build the runtime environment
ARG BASE_VERSION
FROM alpine:${BASE_VERSION}

# install basic tools
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              binutils \
              libc-dev

# define environment variables
ARG GCC_VERSION="9.2.0"
ENV GCC_PATH="/opt/gcc/${GCC_VERSION}"

# copy artifacts from stage 1
COPY --from=builder ${GCC_PATH} ${GCC_PATH}

# set environment variables for users
ENV PATH="${GCC_PATH}/bin:${PATH}"
ENV CPATH="${GCC_PATH}/include:${CPATH}"
ENV LIBRARY_PATH="${GCC_PATH}/lib64:${GCC_PATH}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${GCC_PATH}/lib64:${GCC_PATH}/lib:${LD_LIBRARY_PATH}"

WORKDIR /tmp
