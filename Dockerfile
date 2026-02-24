# Stage 1: Common build dependencies
FROM ubuntu:latest AS builder-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    flex \
    bison \
    cmake \
    python3 \
    pkg-config \
    librdmacm-dev \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Stage 2: Build rdma-core (libibverbs)
FROM builder-base AS build-rdma-core

RUN git clone --depth 1 https://github.com/linux-rdma/rdma-core.git /build/rdma-core

WORKDIR /build/rdma-core
RUN ./build.sh

# Stage 3: Build libpcap with RDMA support
FROM builder-base AS build-libpcap

COPY --from=build-rdma-core /build/rdma-core/build /build/rdma-core/build

ENV PKG_CONFIG_PATH="/build/rdma-core/build/lib/pkgconfig"

RUN git clone --depth 1 https://github.com/the-tcpdump-group/libpcap.git /build/libpcap

WORKDIR /build/libpcap
RUN ./autogen.sh && \
    ./configure --enable-rdma=yes && \
    make

# Stage 4: Build tcpdump
FROM builder-base AS build-tcpdump

COPY --from=build-rdma-core /build/rdma-core/build /build/rdma-core/build
COPY --from=build-libpcap /build/libpcap /build/libpcap

ENV PKG_CONFIG_PATH="/build/rdma-core/build/lib/pkgconfig:/build/libpcap"

RUN git clone --depth 1 https://github.com/the-tcpdump-group/tcpdump.git /build/tcpdump

WORKDIR /build/tcpdump
RUN ./autogen.sh && \
    ./configure && \
    make

# Stage 5: Minimal runtime image
FROM ubuntu:latest AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    librdmacm1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build-tcpdump /build/tcpdump/tcpdump /usr/local/bin/tcpdump
COPY --from=build-rdma-core /build/rdma-core/build/lib/ /usr/local/lib/
COPY --from=build-libpcap /build/libpcap/libpcap.so* /usr/local/lib/

# libibverbs has hardcoded paths to its config and driver plugins from the
# build tree. Copy the config dir and symlink the lib path so drivers load.
COPY --from=build-rdma-core /build/rdma-core/build/etc /build/rdma-core/build/etc
RUN ln -s /usr/local/lib /build/rdma-core/build/lib

RUN ldconfig

ENTRYPOINT ["tcpdump"]
