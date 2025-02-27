# added by Ogglord
# Source bash environment files - 
if status is-interactive
    # Source /etc/profile for environment variables
    if test -f /etc/profile
        bass source /etc/profile
    end

    alias just='just --justfile /etc/just/justfile --unstable --working-directory .'
    alias build='/usr/local/bin/owrt-build'

    function fish_prompt
            ## modify the default 
            set -g __fish_git_prompt_showupstream auto
            set current_dir (basename (pwd))
            set gitprompt (fish_git_prompt)
            echo "📦[$USER@builder $current_dir] $gitprompt> "
    end

    function fish_greeting
        set_color --bold green
        echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
        echo "  Welcome to openwrt-builder  "
        echo "''''''''''''''''''''''''''''''"
        set_color normal
        echo "--"
        set_color --bold yellow
        echo -n "Use ´build´ or ´owrt-build´"
        set_color normal
        echo " to invoke the OpenWrt build helper"
        set_color --bold yellow
        echo -n "Write ´owrt-llvm-config´"
        set_color normal
        echo " to update the .config to use the LLVM toolchain if you use regular make directly"
        echo "--"
        set_color normal
        echo "Note: Both tools must be run from the source folder"
        set_color --bold green
        echo "################################"
        set_color normal
    end
end
