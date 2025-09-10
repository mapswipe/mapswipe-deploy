#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Error: This script must be run as root." >&2
  exit 1
fi

set -xe

# Configuration Directories
mkdir -p -m 770 /var/log/pgbackrest
chown postgres:postgres /var/log/pgbackrest
