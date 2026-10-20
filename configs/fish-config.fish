if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
    if type -q fastfetch
        fastfetch
    end
    if type -q oh-my-posh
        oh-my-posh init fish --config ~/.config/oh-my-posh/nizar-simple.omp.json | source
    end
end
