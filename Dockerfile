FROM ubuntu:20.04

COPY archs /archs
COPY build.sh /build.sh
ENV TZ=Europe/Copenhagen
ENV WORKDIR=/build
ARG DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt update && \
    apt -y install git make wget g++ gcc cpp \
                   binutils ninja-build nasm flex \
                   bison byacc libtirpc-dev python \
                   cmake scons && \
    git clone https://github.com/richfelker/musl-cross-make.git && \
    cd musl-cross-make && \
    /build.sh && \
    cd .. && \
    rm -rf /var/lib/apt/lists/* musl-cross-make
WORKDIR ${WORKDIR}
