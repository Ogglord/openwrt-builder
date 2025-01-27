#!/bin/bash
set -eo pipefail

# Error handling
trap 'echo "Error on line $LINENO"' ERR

# Debug environment variables
echo "Environment variables:"
echo "GO_VERSION=${GO_VERSION}"
echo "LLVM_VERSION=${LLVM_VERSION}"
echo "ARCH=${ARCH}"

# Ensure variables have defaults if not set
: "${LLVM_VERSION:=19}"
: "${GO_VERSION:=1.23.5}"
: "${ARCH:=amd64}"

# Configure APT and install packages
echo "APT::Quiet \"true\";" > /etc/apt/apt.conf.d/99quiet
cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF
rm -rf /etc/apt/sources.list.d/ubuntu.sources
apt-get update -y -qq 
grep -v '^#' ./openwrt-builder.packages | xargs apt-get install -y -qq
touch /.packages_installed

# Install GO
wget --quiet --ca-directory=/etc/ssl/certs/ https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz
rm -f go${GO_VERSION}.linux-${ARCH}.tar.gz
echo "export PATH=\"\$PATH:/usr/local/go/bin\"" >> /etc/profile
touch /.go_installed

# Install LLVM
wget --quiet --ca-directory=/etc/ssl/certs/ https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh "$LLVM_VERSION" > /dev/null
llvm_host_path="/usr/lib/$(ls /usr/lib/ | grep llvm | sort -r | head -1 | cut -d' ' -f11)"
echo "export LLVM_HOST_PATH=$llvm_host_path" >> /etc/profile
touch /.llvm_installed

# Setup Distrobox and tmux
./distrobox-shims.sh
touch /.shims_installed
echo "export TMUX_TMPDIR=/var/tmp" >> /etc/profile

# Install just
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/bin

# Configure system settings
sed -i 's/obscure yescrypt/minlen=2 nullok/' /etc/pam.d/common-password

# Cleanup
apt-get clean > /dev/null
rm -rf /var/lib/apt/lists/* 
