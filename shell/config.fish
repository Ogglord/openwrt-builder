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
            set current_dir (basename (pwd))
            echo "📦[$USER@$CONTAINER_ID $current_dir] (fish_git_prompt)> "
    end
end
