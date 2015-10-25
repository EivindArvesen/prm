#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

current_shell=$(ps -p $$ | awk '{print $4}' | tail -n 1)

if [ $(echo "$current_shell" | grep "bash") ]; then
    if [ $(uname -s) = "Darwin" ]; then
        if [ $(brew info bash-completion | tail -n 1 | sed -e 's/^[[:space:]]*//') ]; then
            bash_completions="$HOME/.bash_completion"
        fi

    else
        if [ $(pkg-config --variable=completionsdir bash-completion) ]; then
            bash_completions="$HOME/.bash_completion"
        fi
    fi

    if [ -z "$bash_completions" ]; then
        bash_completions='/etc/bash_completion.d'
    fi

    # if [ ! -d "$bash_completions" ]; then
    #     mkdir -p "$bash_completions"
    # fi

    cat "completions/complete.bash" > "$bash_completions"
    #cp -f "completions/complete.bash" "$bash_completions/prm"

    source "$bash_completions" #/prm

elif [ $(echo $current_shell | grep "zsh") ]; then
    echo "zsh support is not yet implemented"
    #source "$zsh_completions"/prm

else
    echo "Shell $current_shell is not supported"
fi


# def deploy_completions():
#     completions = {'complete.bash': Path('/etc/bash_completion.d/pew'),
#         'complete.zsh': Path('/usr/local/share/zsh/site-functions/_pew')}
#     for comp, dest in completions.items():
#         if not dest.parent.exists():
#             dest.parent.mkdir(parents=True)
#         shutil.copy(str(pew_site / 'shell_config' / comp), str(dest))
