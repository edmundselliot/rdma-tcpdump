# RDMA tcpdump

Capture RDMA/InfiniBand traffic with tcpdump, packaged in Docker.

## Quick Start

```sh
# Clone and install
git clone https://github.com/edmundselliot/rdma-tcpdump.git
cd rdma-tcpdump
sudo ./install.sh

# List available RDMA devices
rdma-tcpdump -D | grep mlx

# Capture traffic on an RDMA device
rdma-tcpdump -ni mlx5_0
```

## Usage

All arguments are passed directly to tcpdump:

```sh
rdma-tcpdump [tcpdump options]
```

### Options

| Flag | Description |
|------|-------------|
| `--rebuild` | Force rebuild the Docker image |
| `--help` | Show help message |

### Examples

```sh
# List all capture devices
rdma-tcpdump -D

# Capture on mlx5_0 with verbose output
rdma-tcpdump -ni mlx5_0 -v

# Capture and write to file
rdma-tcpdump -ni mlx5_0 -w capture.pcap

# Force rebuild (e.g. after updating)
rdma-tcpdump --rebuild -D
```

## Uninstall

```sh
sudo rm /usr/local/bin/rdma-tcpdump
```
