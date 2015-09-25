#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

COPY="Written by Eivind Arvesen, 2015."
VERSION=0.2.0

prm_dir="${PRM_DIR:-$HOME/.prm}"

if [ ! -d "$prm_dir/.common" ]; then
    # Create deepest directory needed (including its parents)
    mkdir -p "$prm_dir/.common"
fi

if [[ $(basename "$SHELL") == zsh ]]; then
    prompt_var=RPROMPT
else
    prompt_var=PS1
fi

function prm_load() {
    # Loader-function to enable reusable components in projects
    if [ -f "$prm_dir/.common/$1.sh" ]; then
        . "$prm_dir/.common/$1.sh"
    else
        echo "Could not load user script $1"
    fi
}

function prm_help() {
    # Help-Screen
    prm_usage
    echo ""
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
}

function prm_usage() {
     # Usage-sentence
    echo "usage: prm <option> [<args>] ..."
}

function check_editor() {
    if [ -z "$EDITOR" ]; then
        echo "\$EDITOR is not set."
        echo "You will not be able to add, copy or edit projects."
        return 1
    fi
}

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
                else
                    check_editor || return
                    mkdir -p "$prm_dir/$argument"
                    printf "#!/usr/bin/env bash\n\n# This script will run when STARTING the project \"%s\"\n# Here you might want to cd into your project directory, activate virtualenvs, etc.\n\n# The currently active project is available via \$PRM_ACTIVE_PROJECT\n# Command line arguments can be used, \$3 would be the first argument after your project name.\n\n" "$argument" > "$prm_dir/$argument/start.sh"
                    printf "#!/usr/bin/env bash\n\n# This script will run when STOPPING the project \"%s\"\n# Here you might want to deactivate virtualenvs, clean up temporary files, etc.\n\n# The currently active project is available via \$PRM_ACTIVE_PROJECT\n# Command line arguments can be used, \$3 would be the first argument after your project name.\n\n" "$argument" > "$prm_dir/$argument/stop.sh"
                    $EDITOR "$prm_dir/$argument/start.sh" && $EDITOR "$prm_dir/$argument/stop.sh"
                    echo "Added project $argument"
                fi
            done
        else
            echo "No name given"
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
                        check_editor || return
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
        fi
        ;;
    edit)
        # Edit project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -d "$prm_dir/$argument" ]; then
                    check_editor || return
                    $EDITOR "$prm_dir/$argument/start.sh" && $EDITOR "$prm_dir/$argument/stop.sh"
                    echo "Edited project $argument"
                else
                    echo "$argument: No such project"
                fi
            done
        else
            echo "No name given"
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
                    fi
                fi
            done
        else
            echo "No name given"
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
                        PRM_ACTIVE_PROJECT=""
                    fi
                    echo "$2" > "$prm_dir/.active-$$.tmp"
                    set_prompt_start "$2"
                    echo "Starting project $2"
                    . "$prm_dir/$2/start.sh"
                    PRM_ACTIVE_PROJECT=$2
                fi
            else
                echo "$2: No such project"
            fi
        else
            echo "No name given"
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
            PRM_ACTIVE_PROJECT=""
        else
            echo "No active project"
        fi
        ;;
    -h|--help)
        # Help-Screen
        prm_help
        ;;
    -v|--version)
        # Version-Screen
        echo "prm $VERSION."
        echo "$COPY"
        ;;
    *)
        if [ -z "$1" ]; then
            # Bare command
            prm_help
        else
            # Error-Screen
            echo "prm: illegal option -- $1 (see \"prm --help\" for help)"
            prm_usage
        fi
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
