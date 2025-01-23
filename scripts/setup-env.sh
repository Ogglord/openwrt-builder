#!/bin/sh
echo "Running setup-env.sh..."

# Symlink distrobox shims
./distrobox-shims.sh

# Update the container and install packages
apt update
grep -v '^#' ./openwrt-builder.packages | xargs apt install -y 

# Clean up unnecessary files to reduce image size
apt clean && rm -rf /var/lib/apt/lists/*