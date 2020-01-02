FROM docker:18.09.9 as static-docker-source

FROM google/cloud-sdk:274.0.0-alpine

# Metadata
LABEL maintainer="Evil Martians <admin@evilmartians.com>"

ARG KUBE_LATEST_VERSION="v1.15.4"
ARG KUBECTL_SHA256="78984c5387108c9cf2b20b427cf3eac2cc202a87703b6db80e9d21e2ab326099"

ARG HELM_VERSION="v2.16.1"
ARG HELM_SHA256="7eebaaa2da4734242bbcdced62cc32ba8c7164a18792c8acdf16c77abffce202"
ARG HELM_ARCHIVE="helm-${HELM_VERSION}-linux-amd64.tar.gz"
ARG HELM_URL="https://get.helm.sh/${HELM_ARCHIVE}"

COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker

RUN apk add --update ca-certificates \
    && apk add --update -t deps curl \
    && apk add bash \
    && curl -L https://storage.googleapis.com/kubernetes-release/release/$KUBE_LATEST_VERSION/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && echo "${KUBECTL_SHA256}  /usr/local/bin/kubectl" | sha256sum -c \
    && chmod +x /usr/local/bin/kubectl \
    && curl -L "${HELM_URL}" -o "/tmp/${HELM_ARCHIVE}" \
    && tar -zxvf /tmp/${HELM_ARCHIVE} -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && echo "${HELM_SHA256}  /usr/local/bin/helm" | sha256sum -c \
    && apk del --purge deps \
    && rm /var/cache/apk/* \
    && rm -rf /tmp/*

WORKDIR /root

CMD ["/bin/sh"]
