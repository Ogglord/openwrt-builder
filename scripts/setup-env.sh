#!/bin/sh

LLVM_VERSION=${LLVM_VERSION:-19}
GO_VERSION=${GO_VERSION:-1.23.5} # go version
ARCH=${ARCH:-amd64} # go archicture
GO_SHA="cbcad4a6482107c7c7926df1608106c189417163428200ce357695cc7e01d091"
echo "Running setup-env.sh..."

echo "Making apt-get run quiet, except for errors using /etc/apt/apt.conf.d/99quiet"
echo "APT::Quiet \"true\";" > /etc/apt/apt.conf.d/99quiet

cat <<EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF

rm -rf /etc/apt/sources.list.d/ubuntu.sources

# Update the container and install packages
apt-get update -y -qq 
grep -v '^#' ./openwrt-builder.packages | xargs apt-get install -y -qq

## Install GO
echo "Installing GO $GO_VERSION..."
wget --quiet --ca-directory=/etc/ssl/certs/ https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz
echo "Posting checksums - only for occular inspection:"
sha256sum go${GO_VERSION}.linux-${ARCH}.tar.gz
echo $GO_SHA
echo "Extracting go${GO_VERSION}.linux-${ARCH}.tar.gz to /usr/local"
tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz
rm -f go${GO_VERSION}.linux-${ARCH}.tar.gz


## Install LLVM
echo "Installing latest llvm toolchain..."
wget --quiet --ca-directory=/etc/ssl/certs/ https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh "$LLVM_VERSION"
llvm_host_path="/usr/lib/$(ls /usr/lib/ | grep llvm | sort -r | head -1 | cut -d' ' -f11)" \
    && echo "export LLVM_HOST_PATH=$llvm_host_path" >> /etc/bash.bashrc

# Symlink distrobox shims
./distrobox-shims.sh

# Clean up unnecessary files to reduce image size
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -f /setup-env.sh
rm -f /distrobox-shims.sh
rm -f /openwrt-builder.packages