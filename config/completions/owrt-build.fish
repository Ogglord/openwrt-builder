# Completions for owrt-build and the alias ´build´
complete -c owrt-build -f
complete -c build -f

# Mode completions with descriptions for both commands
for cmd in owrt-build build
    complete -c $cmd -n "__fish_use_subcommand" -a "all" -d "Update feeds, download and build"
    complete -c $cmd -n "__fish_use_subcommand" -a "world" -d "Build only"
    complete -c $cmd -n "__fish_use_subcommand" -a "debug" -d "Build single thread with verbose output"
    complete -c $cmd -n "__fish_use_subcommand" -a "feeds" -d "Update and install feeds only"
    complete -c $cmd -n "__fish_use_subcommand" -a "update" -d "Self-update helper executables"
end