# added by Ogglord
# Source bash environment files - 
if status is-interactive
    # Source /etc/profile for environment variables
    if test -f /etc/profile
        bass source /etc/profile
    end
    
    # Source /etc/bashrc if it exists
    #if test -f /etc/bashrc
    #    bass source /etc/bashrc
    #end

    ## show motd
   /etc/fish/motd.fish

    function fish_prompt
            ## modify the default 
            set -g __fish_git_prompt_showupstream auto
            set current_dir (basename (pwd))
            set gitprompt (fish_git_prompt)
            echo "📦[$USER@$CONTAINER_ID $current_dir] $gitprompt> "
    end
end
