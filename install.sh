#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: install.sh must be run as root (try: sudo ./install.sh)" >&2
    exit 1
fi

install -m 755 "${SCRIPT_DIR}/rdma-tcpdump" "${INSTALL_DIR}/rdma-tcpdump"
echo "Installed rdma-tcpdump to ${INSTALL_DIR}/rdma-tcpdump"
