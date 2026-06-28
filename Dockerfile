# syntax=docker/dockerfile:1
# ChromeOS Flex is x86_64-only; always use the amd64 QEMU base.
# On Apple Silicon, run with: docker run --platform linux/amd64 ...

ARG VERSION_ARG="latest"
FROM scratch

COPY --from=qemux/qemu:7.32 / /

ARG TARGETARCH="amd64"
ARG VERSION_WSDD="1.24"

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

RUN set -eu && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        jq \
        curl \
        unzip \
        samba \
        libarchive-tools && \
    wget "https://github.com/gershnik/wsdd-native/releases/download/v${VERSION_WSDD}/wsddn_${VERSION_WSDD}_${TARGETARCH}.deb" -O /tmp/wsddn.deb -q --timeout=10 && \
    dpkg -i /tmp/wsddn.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 ./src /run/
COPY --chmod=755 ./assets /run/assets

ARG VERSION_ARG="0.00"
RUN echo "$VERSION_ARG" > /etc/version

VOLUME /storage
EXPOSE 3389 8006

ENV RAM_SIZE="4G"
ENV CPU_CORES="2"

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
