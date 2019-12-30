# stage 1: build GCC
ARG BASE_TAG=latest
FROM alpine:${BASE_TAG} AS builder

USER root

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
              mpfr-dev \
              musl \
              wget \
              which

# the following instructions are organized to utilize docker caching
# stage 1.1: download gcc source
ARG GCC_VERSION="9.2.0"
ENV GCC_VERSION=${GCC_VERSION}
ENV GCC_TARBALL="gcc-${GCC_VERSION}.tar.gz"
ENV GCC_BUILD_DIR="/tmp/build_dir"

WORKDIR /tmp
RUN set -eux; \
      \
      mkdir ${GCC_BUILD_DIR}; \
      \
      wget "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/${GCC_TARBALL}"; \
      tar -zxf ${GCC_TARBALL}
      # \
      # download dependencies with official script
      # cd gcc-${GCC_VERSION}; \
      # ./contrib/download_prerequisites

# stage 1.2: configure and install gcc
ARG GCC_OPTIONS="--enable-languages=c,c++ --disable-multilib --build=x86_64-alpine-linux-musl --host=x86_64-alpine-linux-musl --target=x86_64-alpine-linux-musl --disable-libsanitizer --disable-libatomic --disable-libitm"
ENV GCC_OPTIONS=${GCC_OPTIONS}
ENV GCC_PREFIX="/opt/gcc/${GCC_VERSION}"

WORKDIR ${GCC_BUILD_DIR}
RUN set -eux; \
      \
      ../gcc-${GCC_VERSION}/configure \
                  --prefix=${GCC_PREFIX} \
                  ${GCC_OPTIONS}; \
      \
      make -j $(nproc) profiledbootstrap; \
      make install-strip

# stage 1.3: clean installation files
WORKDIR /tmp
RUN rm -rf gcc-${GCC_VERSION} ${GCC_TARBALL} ${GCC_BUILD_DIR}


# stage 2: build the runtime environment
ARG BASE_TAG
FROM alpine:${BASE_TAG}

LABEL maintainer="Wang An <wangan.cs@gmail.com>"

USER root

# install basic tools
# note that the versions of the packages could vary between
# different tags of Alpine
RUN set -eu; \
      \
      sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
             /etc/apk/repositories; \
      apk add --no-cache \
              binutils \
              gmp \
              isl \
              libc-dev \
              mpc1 \
              mpfr4

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


# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="GCC docker image" \
      org.label-schema.description="A lightweight image for GCC" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.schema-version="1.0"
