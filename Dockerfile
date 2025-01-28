ARG UBUNTU_VERSION=24.04
FROM quay.io/toolbx/ubuntu-toolbox:${UBUNTU_VERSION}

ARG DEBIAN_FRONTEND="noninteractive"
ARG GO_VERSION=1.22.5
ARG ARCH=amd64
ARG GIT_BRANCH="main"
ENV GO_VERSION=${GO_VERSION}
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}
ENV ARCH=${ARCH}
ENV GIT_BRANCH=${GIT_BRANCH}

LABEL com.github.containers.toolbox="true" \
    usage="This image is meant to be used with the toolbox or distrobox command" \
    summary="This is an environment aimed at building OpenWRT images" \
    maintainer="oag@proton.me" \
    branch="${GIT_BRANCH}"

# Copy files to their final destinations
COPY ./scripts/buildtime/ /
COPY ./packages/openwrt-builder.packages /
COPY ./scripts/runtime/owrt-update /
COPY ./update-manifest.json /

# Set permissions and run setup script, install runtime helpers and finally cleanup
RUN chmod +x /container-setup.sh /distrobox-shims.sh /owrt-update && \
    GO_VERSION=${GO_VERSION} DEBIAN_FRONTEND=${DEBIAN_FRONTEND} ARCH=${ARCH} /container-setup.sh && \
    GIT_BRANCH=${GIT_BRANCH} OWRT_UPDATE_TEMP=1 /owrt-update && \
    rm /container-setup.sh /distrobox-shims.sh /owrt-update /openwrt-builder.packages

# Copy fish config, justfile, bass plugin as final step
#RUN chmod 644 /etc/fish/functions/__bass.py /etc/fish/functions/bass.fish && \
    
