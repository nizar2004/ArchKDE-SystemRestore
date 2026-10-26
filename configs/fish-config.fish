if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
    if type -q fastfetch
        fastfetch
    end
    if type -q oh-my-posh
        set -l omp_theme "$HOME/.config/oh-my-posh/nizar-simple.omp.json"
        if test -f "$omp_theme"
            oh-my-posh init fish --config "$omp_theme" | source
        else
            oh-my-posh init fish | source
        end
    end
end
