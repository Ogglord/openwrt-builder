# openwrt-builder

## What is OpenWrt-Builder ?
It's a docker container built to be used with distrobox or toolbox and ultimately compile OpenWrt.

[Distrobox](https://github.com/89luca89/distrobox/) is a command-line tool that enables you to use any Linux distribution inside your terminal through containerization. It's a powerful tool that uses docker or podman to execute the container.

For this purpose I have a custom OCI container that contains the build dependencies as well as an helper script 'buildo' that performs saves me from typing a lot of repetetive commands.

## How to build OpenWrt ?

### 1. Install the either distrobox or toolbox. 

Make sure you have docker or podman installed.

```bash
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
```
or read [here](https://github.com/89luca89/distrobox/?tab=readme-ov-file#installation) for more installation options.

### 2. Create and enter the container
If you use distrobox:

    distrobox create -i ghcr.io/ogglord/openwrt-builder -n openwrt
    distrobox enter openwrt
    
If you use toolbox:

    toolbox create -i ghcr.io/ogglord/openwrt-builder -c openwrt
    toolbox enter openwrt

### 3. Build

Do not copy this, run it line by line yourself

```bash
# I recommend using fish inside the distrobox
$: chsh -s /usr/bin/fish
$: fish
$: mkdir ~/repos && cd ~/repos
$: git clone https://github.com/pesa1234/openwrt.git
$: cd openwrt
$: git checkout <branch_name>
$: git pull
$: wget https://raw.githubusercontent.com/pesa1234/MT6000_cust_build/refs/heads/main/config_file/.config
# add your packages etc
$: make menuconfig
# use buildo for a single all-in-one-command
$: buildo full
# or do the steps yourselves
$: ./scripts/feeds update -a
$: ./scripts/feeds install -a
$: make -j$(nproc) defconfig download clean world
```
