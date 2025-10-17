# OpenWrt Builder

[![build-boxkit](https://github.com/Ogglord/openwrt-builder/actions/workflows/build-boxkit.yml/badge.svg)](https://github.com/Ogglord/openwrt-builder/actions/workflows/build-boxkit.yml)
[![release-please](https://github.com/Ogglord/openwrt-builder/actions/workflows/release-please.yml/badge.svg?event=push)](https://github.com/Ogglord/openwrt-builder/actions/workflows/release-please.yml)

A containerized build environment for OpenWrt that simplifies the compilation process using Docker/Podman through Distrobox or Toolbox. This project provides a pre-configured Ubuntu-based container with all necessary build dependencies and helper scripts to streamline the OpenWrt compilation process.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Helper Scripts](#helper-scripts)
  - [Quick Start Guide](#quick-start-guide)
  - [Using distrobox.ini](#using-distroboxini)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Further Reading](#further-reading)

## Features
- Pre-configured Ubuntu-based build environment
- Integrated LLVM toolchain support
- Helper scripts for common build operations
- Compatible with both Distrobox and Toolbox
- Automatic home directory mounting
- Fish shell support

## Prerequisites
- Docker (recommended) or Podman installed
- A compatible host OS:
  - Any Linux distribution
  - Windows with WSL2
  - macOS (experimental, via `brew install distrobox`)
- Sufficient disk space (at least 50GB recommended)
- Minimum 8GB RAM recommended

## Installation

### 1. Install Distrobox or Toolbox

For Distrobox (recommended):
```bash
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
```
See [Distrobox installation options](https://github.com/89luca89/distrobox/?tab=readme-ov-file#installation) for alternatives.

### 2. Create and Enter the Container

#### Using Distrobox:
```bash
distrobox create -i ghcr.io/ogglord/openwrt-builder -n openwrt
distrobox enter openwrt
```

#### Using Toolbox:
```bash
toolbox create -i ghcr.io/ogglord/openwrt-builder -c openwrt
toolbox enter openwrt
```

## Usage

### Helper Scripts
The container includes several helper scripts to simplify the build process:

- `owrt-build`: Automates the complete build process including feed updates and LLVM configuration
- `owrt-llvm-config`: Injects the necessary LLVM toolchain paths into .config
- `owrt-update`: Updates the helper scripts from latest git
- `owrt-log-filter`: Filters make output for better readability

### Quick Start Guide

Follow these steps inside the container:

```bash
# Switch to fish shell (recommended)
chsh -s /usr/bin/fish
fish

# Set up build directory
mkdir ~/repos && cd ~/repos
git clone https://github.com/pesa1234/openwrt.git
cd openwrt
# list the last 10 branches
git for-each-ref --sort=-committerdate --count=10 refs/heads refs/remotes --format='%(committerdate:short) %(refname:short)'
git checkout <branch_name>
git pull

# Get initial config
wget https://raw.githubusercontent.com/pesa1234/MT6000_cust_build/refs/heads/main/config_file/.config

# Customize your build
make menuconfig

# Build everything, including feeds etc using helper script
owrt-build all

# Or build manually:
./scripts/feeds update -a
./scripts/feeds install -a
owrt-llvm-config
make -j$(nproc) defconfig download clean world
```

### Using distrobox.ini

For easier container management, you can use a distrobox.ini file:

1. Download the template:
```bash
wget https://raw.githubusercontent.com/Ogglord/openwrt-builder/refs/heads/main/distrobox.ini
```

2. Create and enter the container in the same directory:
```bash
distrobox assemble create && distrobox enter builder
```

Example distrobox.ini:
```ini
[builder]
hostname=builder
image=ghcr.io/ogglord/openwrt-builder
init=false
nvidia=false
pull=true
root=false
replace=true
start_now=true
#additional_packages=""
```

## Troubleshooting

### Common Issues

1. **Build Fails with Memory Error**
   - Increase available memory or enable swap
   - Reduce parallel jobs with `make -j1`

2. **LLVM Configuration Issues**
   - Run `owrt-llvm-config` before building
   - Verify .config contains correct LLVM paths

3. **Container Access Issues**
   - Ensure Docker/Podman is running
   - Check user permissions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Further Reading

- [OpenWrt Build System Documentation](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
- [Distrobox Compatibility Guide](https://github.com/89luca89/distrobox/blob/main/docs/compatibility.md#host-distros)
- [OpenWrt Custom Build Reference](https://github.com/Fail-Safe/openwrt-pesa1234-build)
