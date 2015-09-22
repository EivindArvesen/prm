#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

COPY="Written by Eivind Arvesen, 2015."
VERSION=0.2.0

prm_dir="${PRM_DIR:-$HOME/.prm}"

if [ ! -d "$prm_dir" ]; then
    mkdir -p "$prm_dir"
fi

if [[ $(basename "$SHELL") == zsh ]]; then
    prompt_var=RPROMPT
else
    prompt_var=PS1
fi


function set_prompt_start() {
if [ ! -e "$prm_dir/.prompt-$$.tmp" ]; then
    cur_prompt=""
    eval "cur_prompt=\$$prompt_var"

    echo "$cur_prompt" > "$prm_dir/.prompt-$$.tmp"

    eval "export $prompt_var"
    eval $prompt_var="'[$1] $cur_prompt'"
else
    eval "export $prompt_var"
    eval $prompt_var="'[$1] $(cat "$prm_dir/.prompt-$$.tmp")'"
fi
}

function set_prompt_finish() {
eval "export $prompt_var"
eval $prompt_var="'$(cat "$prm_dir/.prompt-$$.tmp")'"
}

case "$1" in
    active)
        # List active project "instances"
        cd "$prm_dir"
        while IFS= read -r -d '' instance; do
            pid=${instance%.*}
            pid=${pid##*-}
            if (ps -p "$pid" > /dev/null); then
                echo "$pid    $(cat "$instance")"
            fi
        done < <(find . -maxdepth 1 -name '.active*' -print0 -quit)
        cd - >/dev/null 2>&1
        ;;
    add)
        # Add project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -d "$prm_dir/$argument" ]; then
                    echo "Project $argument already exists"
                    # exit
                else
                    mkdir -p "$prm_dir/$argument"
                    printf "#!/usr/bin/env bash\n\n# This script will run when STARTING the project \"%s\"\n# Here you might want to cd into your project directory, activate virtualenvs, etc.\n\n" "$argument" > "$prm_dir/$argument/start.sh"
                    printf "#!/usr/bin/env bash\n\n# This script will run when STOPPING the project \"%s\"\n# Here you might want to deactivate virtualenvs, clean up temporary files, etc.\n\n" "$argument" > "$prm_dir/$argument/stop.sh"
                    $EDITOR "$prm_dir/$argument/start.sh" && $EDITOR "$prm_dir/$argument/stop.sh"
                    echo "Added project $argument"
                fi
            done
        else
            echo "No name given"
            # exit
        fi
        ;;
    copy)
        # Copy project
        if [ "$2" ]; then
            if [ ! -d "$prm_dir/$2" ]; then
                echo "$2: No such project"
            else
                if [ "$3" ]; then
                    if [ -d "$prm_dir/$3" ]; then
                        echo "Project $3 already exists"
                    else
                        cp -r "$prm_dir/$2" "$prm_dir/$3"
                        sed -i -e "s/\"$2\"/\"$3\"/g" $prm_dir/$3/*.sh
                        $EDITOR "$prm_dir/$argument/start.sh" && $EDITOR "$prm_dir/$argument/stop.sh"
                        echo "Copied project $2 to $3"
                    fi
                else
                    echo "No new name given"
                fi
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    edit)
        # Edit project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -d "$prm_dir/$argument" ]; then
                    $EDITOR "$prm_dir/$argument/start.sh" && $EDITOR "$prm_dir/$argument/stop.sh"
                    echo "Edited project $argument"
                else
                    echo "$argument: No such project"
                    # exit
                fi
            done
        else
            echo "No name given"
            # exit
        fi
        ;;
    list)
        # List projects
        if [ ! "$(find "$prm_dir" -type d | wc -l)" -gt 1 ]; then
            echo "No projects exist"
        else
            cd "$prm_dir/"
            for active in ./*; do
                basename "$active"
            done
            cd - >/dev/null 2>&1
        fi
        ;;
    remove)
        # Remove project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -e "$prm_dir/.active-$$.tmp" ] && [ "$(cat "$prm_dir/.active-$$.tmp")" == "$argument" ]; then
                    echo "Stop project $argument before trying to remove it"
                else
                    if [ -d "$prm_dir/$argument" ]; then
                        rm -rf "${prm_dir:?}/$argument/"
                        echo "Removed project $argument"
                    else
                        echo "$argument: No such project"
                        # exit
                    fi
                fi
            done
        else
            echo "No name given"
            # exit
        fi
        ;;
    rename)
        # Rename project
        if [ -e "$prm_dir/.active-$$.tmp" ] && [ "$(cat "$prm_dir/.active-$$.tmp")" == "$2" ]; then
            echo "Stop project $2 before trying to rename it"
        else
            if [ "$2" ]; then
                if [ ! -d "$prm_dir/$2" ]; then
                    echo "$2: No such project"
                else
                    if [ "$3" ]; then
                        if [ -d "$prm_dir/$3" ]; then
                            echo "Project $3 already exists"
                        else
                            mv "$prm_dir/$2" "$prm_dir/$3"
                            echo "Renamed project $2 $3"
                        fi
                    else
                        echo "No new name given"
                    fi
                fi
            else
                echo "No name given"
                # exit
            fi
        fi
        ;;
    start)
        # Start project
        if [ "$2" ]; then
            if [ -d "$prm_dir/$2" ]; then
                if [ -e "$prm_dir/.active-$$.tmp" ] && [ "$(cat "$prm_dir/.active-$$.tmp")" == "$2" ]; then
                    echo "Project $2 is already active"
                else
                    if [ ! -e "$prm_dir/.path-$$.tmp" ]; then
                        pwd > "$prm_dir/.path-$$.tmp"
                    fi
                    if [ -e "$prm_dir/.active-$$.tmp" ]; then
                        . "$prm_dir/$(cat "$prm_dir/.active-$$.tmp")/stop.sh"
                    fi
                    echo "$2" > "$prm_dir/.active-$$.tmp"
                    set_prompt_start "$2"
                    echo "Starting project $2"
                    . "$prm_dir/$2/start.sh"
                fi
            else
                echo "$2: No such project"
                # exit
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    stop)
        # Stop project
        if [ -e "$prm_dir/.active-$$.tmp" ]; then
            . "$prm_dir/$(cat "$prm_dir/.active-$$.tmp")/stop.sh"
            echo "Stopping project $(cat "$prm_dir/.active-$$.tmp")"
            rm -f "$prm_dir/.active-$$.tmp"
            cd "$(cat "$prm_dir/.path-$$.tmp")"
            rm -f "$prm_dir/.path-$$.tmp"
            set_prompt_finish
            rm -f "$prm_dir/.prompt-$$.tmp"
        else
            echo "No active project"
            # exit
        fi
        ;;
    -h|--help)
        # Help-Screen
        echo "Usage: prm [options] ..."
        echo "Options:"
        echo "  active                   List active project instances."
        echo "  add <project name>       Add project(s)."
        echo "  copy <old> <new>         Copy project."
        echo "  edit <project name>      Edit project(s)."
        echo "  list                     List all projects."
        echo "  remove <project name>    Remove project(s)."
        echo "  rename <old> <new>       Rename project."
        echo "  start <project name>     Start project."
        echo "  stop                     Stop active project."
        echo "  -h --help                Display this information."
        echo "  -v --version             Display version info."
        echo ""
        echo "Please report bugs at https://github.com/eivind88/prm"
        echo "Remember that prm MUST be sourced - not run in a subshell."
        echo "I.e. '. ./prm'"
        # exit
        ;;
    -v|--version)
        # Version-Screen
        echo "prm $VERSION."
        echo "$COPY"
        # exit
        ;;
    *)
        # Error-Screen
        echo "prm: illegal option -- $1"
        echo "usage: prm [options] ..."
        # exit
        ;;
esac

# Clean dead project "instances"
cd "$prm_dir"
if [ -n "$(find . -maxdepth 1 -name '.active*' -print -quit)" ]; then
    for instance in .active*; do
        pid=${instance%.*}
        pid=${pid##*-}

        if (! ps -p "$pid" > /dev/null); then
            rm -f "$prm_dir/.active-$pid.tmp" "$prm_dir/.path-$pid.tmp" "$prm_dir/.prompt-$pid.tmp"
        fi
    done
fi
cd - >/dev/null 2>&1
