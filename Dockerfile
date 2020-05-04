# Build GCC with latest spack
ARG SPACK_IMAGE="spack/ubuntu-bionic"
ARG SPACK_VERSION="0.14"
FROM ${SPACK_IMAGE}:${SPACK_VERSION}

LABEL maintainer="Wang An <wangan.cs@gmail.com>"

USER root

ARG EXTRA_SPECS="target=skylake"
ENV EXTRA_SPECS=${EXTRA_SPECS}
ARG GCC_VERSION="9.2.0"
ENV GCC_VERSION=${GCC_VERSION}

# install GCC
RUN set -eu; \
      \
      spack install gcc@${GCC_VERSION} $EXTRA_SPECS; \
      spack clean -a; \
      spack load gcc@${GCC_VERSION}; \
      spack compiler add

# setup development environment
ENV ENV_FILE="/root/setup-env.sh"
RUN set -e; \
      \
      echo "#!/bin/env bash" > $ENV_FILE; \
      echo "source /opt/spack/share/spack/setup-env.sh" >> $ENV_FILE; \
      echo "spack load gcc@$GCC_VERSION" >> $ENV_FILE

# reset the entrypoint
ENTRYPOINT []
CMD ["/bin/bash"]


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
