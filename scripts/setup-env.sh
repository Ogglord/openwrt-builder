#!/bin/sh
echo "Running setup-env.sh..."

cat <<EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF

rm -rf /etc/apt/sources.list.d/ubuntu.sources

# Update the container and install packages
apt-get update -y
grep -v '^#' ./openwrt-builder.packages | xargs apt-get install -y 

## Install GO
wget --ca-directory=/etc/ssl/certs/ https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz \
rm -f go${GO_VERSION}.linux-arm64.tar.gz

# Symlink distrobox shims
./distrobox-shims.sh
