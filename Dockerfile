# stage 1: build GCC with latest spack
ARG SPACK_VERSION="0.14"
FROM spack/ubuntu-xenial:${SPACK_VERSION} AS builder

USER root

ARG GCC_VERSION="9.2.0"
ENV GCC_VERSION=${GCC_VERSION}

# install GCC
RUN spack install --show-log-on-error -y gcc@${GCC_VERSION}


# stage 2: build the runtime environment
ARG SPACK_VERSION
FROM spack/ubuntu-xenial:${SPACK_VERSION}

LABEL maintainer="Wang An <wangan.cs@gmail.com>"

USER root

ENV SPACK_ROOT=/opt/spack
ENV PATH=${SPACK_ROOT}/bin:$PATH

# copy artifacts from stage 1
COPY --from=builder ${SPACK_ROOT} ${SPACK_ROOT}

ARG GCC_VERSION="9.2.0"
ENV GCC_VERSION=${GCC_VERSION}

# initialize spack environment for all users
RUN set -eu; \
      \
      source ${SPACK_ROOT}/share/spack/setup-env.sh; \
      spack load gcc@${GCC_VERSION}; \
      spack compiler add

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL="https://github.com/alephpiece/docker-gcc"
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="GCC docker image" \
      org.label-schema.description="An image for GCC" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.schema-version="1.0"
