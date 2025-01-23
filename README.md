# openwrt-builder

## What is OpenWrt-Builder ?

## Using the custom images

We use the default boxkit image as an example to show you how to create a distrobox/toolbox container using a custom image.

If you use distrobox:

    distrobox create -i ghcr.io/ublue-os/boxkit -n boxkit
    distrobox enter boxkit
    
If you use toolbox:

    toolbox create -i ghcr.io/ublue-os/boxkit -c boxkit
    toolbox enter boxkit
