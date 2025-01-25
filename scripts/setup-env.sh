#!/bin/bash
set -e
set -o pipefail

# Error handling
CURRENT_PHASE="0"
handle_error() {
    echo "ERROR: Script failed during Phase ${CURRENT_PHASE}"
    exit 1
}
trap 'handle_error' ERR

LLVM_VERSION=${LLVM_VERSION:-19}
GO_VERSION=${GO_VERSION:-1.23.5} # go version
ARCH=${ARCH:-amd64} # go archicture
GO_SHA="cbcad4a6482107c7c7926df1608106c189417163428200ce357695cc7e01d091"
echo "Running setup-env.sh..."

# Phase 1: Configure APT
CURRENT_PHASE="1 - APT Configuration"
echo "Phase ${CURRENT_PHASE}"
echo "APT::Quiet \"true\";" > /etc/apt/apt.conf.d/99quiet

cat <<EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF

rm -rf /etc/apt/sources.list.d/ubuntu.sources

# Phase 2: Update and Install Packages
CURRENT_PHASE="2 - Package Installation"
echo "Phase ${CURRENT_PHASE}"
apt-get update -y -qq 
grep -v '^#' ./openwrt-builder.packages | xargs apt-get install -y -qq
touch /.packages_installed

# Phase 3: Install GO
CURRENT_PHASE="3 - GO Installation"
#echo "SKIPPED"
echo "Phase ${CURRENT_PHASE}"
echo "Installing GO $GO_VERSION..."
wget --quiet --ca-directory=/etc/ssl/certs/ https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz
#echo "Posting checksums - only for occular inspection:"
#sha256sum go${GO_VERSION}.linux-${ARCH}.tar.gz
#echo $GO_SHA
echo "Extracting go${GO_VERSION}.linux-${ARCH}.tar.gz to /usr/local"
tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz
touch /.go_installed
rm -f go${GO_VERSION}.linux-${ARCH}.tar.gz
echo "export PATH=\"$PATH:/usr/local/go/bin\"" >> /etc/profile


# Phase 4: Install LLVM
CURRENT_PHASE="4 - LLVM Installation"
echo "Phase ${CURRENT_PHASE}"
echo "Installing latest llvm toolchain..."
wget --quiet --ca-directory=/etc/ssl/certs/ https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh "$LLVM_VERSION" > /dev/null
touch /.llvm_installed
llvm_host_path="/usr/lib/$(ls /usr/lib/ | grep llvm | sort -r | head -1 | cut -d' ' -f11)" \
    && echo "export LLVM_HOST_PATH=$llvm_host_path" >> /etc/profile
echo "LLVM_HOST_PATH added to /etc/profile"

# Phase 5: Setup Distrobox Shims
CURRENT_PHASE="5 - Distrobox Shims"
echo "Phase ${CURRENT_PHASE}"
./distrobox-shims.sh
touch /.shims_installed

# Phase 6: Allow for multiple tmux (https://github.com/89luca89/distrobox/issues/824)
CURRENT_PHASE="6 - Tmux workaround"
echo "Phase ${CURRENT_PHASE}"
echo "export TMUX_TMPDIR=/var/tmp" >> /etc/profile

# Phase 7: Cleanup
CURRENT_PHASE="7 - Cleanup"
echo "Phase ${CURRENT_PHASE}"
apt-get clean > /dev/null
rm -rf /var/lib/apt/lists/*
rm -f /setup-env.sh
rm -f /distrobox-shims.sh
rm -f /openwrt-builder.packages
