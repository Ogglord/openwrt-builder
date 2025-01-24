#!/usr/bin/env fish
# Run MOTD for interactive shells
if status is-interactive
    set_color --bold green
    echo "Welcome!"
    set_color normal
    echo "--"
    set_color --bold yellow
    echo -n "Use ´buildo´"
    set_color normal
    echo " to invoke the OpenWrt build helper"
    set_color --bold yellow
    echo -n "Use ´llvm-fix´"
    set_color normal
    echo " to update the .config to use the LLVM toolchain"
    echo "--"
    set_color --bold blue
    echo "Note: Both tools must be run from root of the source folder"
    set_color normal
    echo "###################################################################"
end


