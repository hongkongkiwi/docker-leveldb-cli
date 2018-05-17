FROM alpine:3.7

MAINTAINER Andy Savage <andy@savage.hk>

LABEL org.label-schema.name="leveldb" \
      org.label-schema.description="Docker Image to provide LevelDB cli" \
      org.label-schema.vcs-url="https://github.com/hongkongkiwi/docker-leveldb-cli" \
      org.label-schema.license="MIT"

# URLS for stuff to install during build
ARG LEVELDB_REPO='https://github.com/0x00a/ldb.git'

# install dependencies
RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
 && echo "@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
 && echo "@edgetesting http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 # Add community repo
 && apk update \
 && apk add --upgrade apk-tools@edge \
 # Install these as a group so they are easy to remove
 && apk add musl-dev@edge musl@edge musl-utils@edge \
 && apk add --no-cache --virtual .build-dependencies \
        git make g++ gcc snappy-dev cmake@edge yaml-dev \
        ca-certificates \
 && apk add --no-cache \
        snappy yaml

# LevelDB for Shell
RUN echo "Installing LevelDB" \
 # Fix an issue if this dir does not exist
 && mkdir -p "/usr/share/man/man1" \
 && git clone -q "${LEVELDB_REPO}" "/tmp/ldb" \
 && cd "/tmp/ldb" \
 && make && make install \
 && echo "Cleaning Up"

RUN apk del --purge .build-dependencies cmake musl-dev \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/*

ENTRYPOINT ["ldb"]
