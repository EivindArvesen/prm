#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

current_shell=$(ps -p $$ | awk '{print $4}' | tail -n 1)


if [ $(echo "$current_shell" | grep "bash") ]; then
    if [ $(uname -s) = "Darwin" ]; then
        if [ $(brew info bash-completion | tail -n 1 | sed -e 's/^[[:space:]]*//') ]; then
            bash_completions=$(brew info bash-completion | tail -n 1 | sed -e 's/^[[:space:]]*//')
        fi

    else
        if [ $(pkg-config --variable=completionsdir bash-completion) ]; then
            bash_completions=$(pkg-config --variable=completionsdir bash-completion)
        fi
    fi

    if [ -z "$bash_completions" ]; then
        if [ -d '/etc/bash_completion.d' ]; then
            bash_completions='/etc/bash_completion.d'
        else
            bash_completions="$HOME/.bash_completion"
        fi
    fi

    if [ bash_completions == "$HOME/.bash_completion" ]; then
        cat "completions/complete.bash" >> "$bash_completions"
    else
        yes | cp -rf "completions/complete.bash" "$bash_completions/prm"
        #chmod 755 "$bash_completions/prm"
        #source "$bash_completions/prm" #/prm
    fi


elif [ $(echo $current_shell | grep "zsh") ]; then
    echo "zsh support is not yet implemented"
    #source "$zsh_completions"/prm
    zsh_completions="/usr/local/share/zsh/site-functions"
    cp -rf "completions/complete.zsh" "$zsh_completions/_prm"


else
    echo "Shell $current_shell is not supported"
fi
