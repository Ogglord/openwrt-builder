# Install Fisher if not installed
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

# Install bass if not installed
if not functions -q bass
    fisher install edc/bass
end

# Source bash environment files
if status is-interactive
    # Source /etc/profile for environment variables
    if test -f /etc/profile
        bass source /etc/profile
    end
    
    # Source /etc/bashrc if it exists
    if test -f /etc/bashrc
        bass source /etc/bashrc
    end

    ## show motd
   /etc/fish/motd.fish
end
