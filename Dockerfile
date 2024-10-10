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
    rdma-core \
    rdmacm-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for building tcpdump and libpcap
RUN mkdir /tcpdumpbuild
WORKDIR /tcpdumpbuild

# Clone the tcpdump and libpcap repositories
RUN git clone https://github.com/the-tcpdump-group/tcpdump.git && \
    git clone https://github.com/the-tcpdump-group/libpcap.git

# Clear PKG_CONFIG_PATH to avoid conflicts with DPDK
ENV PKG_CONFIG_PATH=""

# Build libpcap with RDMA support
WORKDIR /tcpdumpbuild/libpcap
RUN ./autogen.sh && \
    ./configure --enable-rdma=yes && \
    make

ENV PKG_CONFIG_PATH="/tcpdumpbuild/libpcap"

# Build tcpdump
WORKDIR /tcpdumpbuild/tcpdump
RUN ./autogen.sh && \
    ./configure && \
    make

# Set the entrypoint
ENTRYPOINT ["/bin/bash"]
WORKDIR /tcpdumpbuild/tcpdump
