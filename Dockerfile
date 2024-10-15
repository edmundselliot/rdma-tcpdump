# Use an official Ubuntu base image
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    flex \
    bison \
    librdmacm-dev \
    librdmacm1 \
    rdmacm-utils \
    cmake \
    python3 \
    python3-pip \
    gdb \
    pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for building projects
RUN mkdir /build
WORKDIR /build

# Clone all repos
WORKDIR /build
RUN git clone https://github.com/linux-rdma/rdma-core.git && \
    git clone https://github.com/the-tcpdump-group/tcpdump.git && \
    git clone https://github.com/the-tcpdump-group/libpcap.git

# Build and install libibverbs
WORKDIR /build/rdma-core
RUN ./build.sh

# Clear PKG_CONFIG_PATH to avoid conflicts with DPDK
ENV PKG_CONFIG_PATH="/build/rdma-core/build/lib/pkgconfig"

# Build libpcap with RDMA support
WORKDIR /build/libpcap
RUN ./autogen.sh && \
    ./configure --enable-rdma=yes && \
    make

ENV PKG_CONFIG_PATH="/build/rdma-core/build/lib:/build/libpcap"

# Build tcpdump
WORKDIR /build/tcpdump
RUN ./autogen.sh && \
    ./configure && \
    make

# Set the entrypoint
ENTRYPOINT ["/bin/bash"]
WORKDIR /build/tcpdump
