#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

COPY="Written by Eivind Arvesen, 2015."
VERSION=0.6.0
SOURCE="prm MUST be sourced - not run in a subshell.\ni.e. '. ./prm'\n"

function return_error() {
    # Print error message and return error code
    if [ "$2" ]; then
        echo "$2"
    fi
    if [ "$1" ]; then
        return "$1"
    else
        return 1
    fi
}

# Test if prm is run in subshell or sourced
if [ "$(basename "${0//-/}")" = "prm.sh" ]; then
    return_error 1 "$(printf "$SOURCE")"
    exit
fi

prm_dir="${PRM_DIR:-$HOME/.prm}"

if [ ! -d "$prm_dir/.common" ]; then
    # Create deepest directory needed (including its parents)
    mkdir -p "$prm_dir/.common"
fi

if [[ $(basename "$SHELL") = zsh ]]; then
    prompt_var=RPROMPT
else
    prompt_var=PS1
fi

function prm_load() {
    # Loader-function to enable reusable components in projects
    if [ "$1" ]; then
        if [ -f "$prm_dir/.common/$1.sh" ]; then
            . "$prm_dir/.common/$1.sh"
        else
            return_error 1 "Could not load user script $1"
        fi
    else
        return_error 1 "No script to load named"
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
    printf "Remember that $SOURCE"
}

function prm_usage() {
    # Usage-sentence
    echo "usage: prm <option> [<args>] ..."
}

function check_editor() {
    # Checking if editor-variable is set
    if [ -z "$EDITOR" ]; then
        echo "\$EDITOR is not set."
        echo "You will not be able to add, copy or edit projects."
        return 1
    fi
}

function set_prompt_start() {
    # Change prompt to include name of active prm project
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
    # Revert prompt to what it was before prm was activated
    eval "export $prompt_var"
    eval $prompt_var="'$(cat "$prm_dir/.prompt-$$.tmp")'"
}

function check_project_name() {
    # Verify that project name is not blacklisted (reserved)
    #prompt, path, active, common
    case "$1" in
        .*|*.tmp)
            echo "$1: Illegal name"
            return 1
    esac
}

function edit_scripts() {
    # Open project start- and stop- scripts in $EDITOR
    if [ $CI ] && [ $prm_bats_test_cygwin ]; then
        uname="CYGWIN_NT-5.2-WOW64"
    else
        uname=$(uname -s)
    fi
    case "$uname" in
        CYGWIN*|MINGW32*|MSYS*)
            #Cygwin
            $EDITOR `cygpath.exe -d "$prm_dir/$1/start.sh"` && $EDITOR `cygpath.exe -d "$prm_dir/$1/stop.sh"`
            ;;
        *)
            #OS X/Linux/BSD/etc.
            $EDITOR "$prm_dir/$1/start.sh" && $EDITOR "$prm_dir/$1/stop.sh"
            ;;
    esac
}

function cleanup() {
    # Clean dead project "instances"
    cd "$prm_dir" >/dev/null 2>&1 || return_error 1 "Directory $prm_dir does not exist."
    if [ -n "$(find . -maxdepth 1 -name '.active*' -print -quit)" ]; then
        for instance in .active*; do
            pid=${instance%.*}
            pid=${pid##*-}

            if (! ps -p "$pid" > /dev/null); then
                rm -f "$prm_dir/.active-$pid.tmp" "$prm_dir/.path-$pid.tmp" "$prm_dir/.prompt-$pid.tmp"
            fi
        done
    fi
    cd - >/dev/null 2>&1 || return_error 1 "Previous directory not available."
}

case "$1" in
    # Test args
    active)
        # List active project "instances"
        cd "$prm_dir" >/dev/null 2>&1 || return_error 1 "Directory $prm_dir does not exist."
        while IFS= read -r -d '' instance; do
            pid=${instance%.*}
            pid=${pid##*-}
            if (ps -p "$pid" > /dev/null); then
                echo "$pid    $(cat "$instance")"
            fi
        done < <(find . -maxdepth 1 -name '.active*' -print0 -quit)
        cd - >/dev/null 2>&1 || return_error 1 "Previous directory not available."
        ;;
    add)
        # Add project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -d "$prm_dir/$argument" ]; then
                    return_error 1 "Project $argument already exists"
                    return 1
                else
                    check_project_name "$argument" || return
                    check_editor || return
                    mkdir -p "$prm_dir/$argument"
                    printf "#!/usr/bin/env bash\n\n# This script will run when STARTING the project \"%s\"\n# Here you might want to cd into your project directory, activate virtualenvs, etc.\n\n# The currently active project is available via \$PRM_ACTIVE_PROJECT\n# Command line arguments can be used, \$3 would be the first argument after your project name.\n\n" "$argument" > "$prm_dir/$argument/start.sh"
                    printf "#!/usr/bin/env bash\n\n# This script will run when STOPPING the project \"%s\"\n# Here you might want to deactivate virtualenvs, clean up temporary files, etc.\n\n# The currently active project is available via \$PRM_ACTIVE_PROJECT\n# Command line arguments can be used, \$3 would be the first argument after your project name.\n\n" "$argument" > "$prm_dir/$argument/stop.sh"
                    edit_scripts $argument
                    echo "Added project $argument"
                fi
            done
        else
            return_error 1 "No name given"
            return 1
        fi
        ;;
    copy)
        # Copy project
        if [ "$2" ]; then
            if [ ! -d "$prm_dir/$2" ]; then
                return_error 1 "$2: No such project"
                return 1
            else
                if [ "$3" ]; then
                    if [ -d "$prm_dir/$3" ]; then
                        return_error 1 "Project $3 already exists"
                        return 1
                    else
                        check_project_name "$3" || return
                        check_editor || return
                        cp -r "$prm_dir/$2" "$prm_dir/$3"
                        sed -i -e "s/\"$2\"/\"$3\"/g" $prm_dir/$3/*.sh
                        edit_scripts $3
                        echo "Copied project $2 to $3"
                    fi
                else
                    return_error 1 "No new name given"
                    return 1
                fi
            fi
        else
            return_error 1 "No name given"
            return 1
        fi
        ;;
    edit)
        # Edit project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -d "$prm_dir/$argument" ]; then
                    check_editor || return
                    edit_scripts $argument
                    echo "Edited project $argument"
                else
                    return_error 1 "$argument: No such project"
                    return 1
                fi
            done
        else
            return_error 1 "No name given"
            return 1
        fi
        ;;
    list)
        # List projects
        if [ ! "$(find "$prm_dir" -type d | wc -l)" -gt 2 ]; then
            return_error 1 "No projects exist"
            return 1
        else
            cd "$prm_dir/" >/dev/null 2>&1 || return_error 1 "Directory $prm_dir does not exist."
            for active in ./*; do
                basename "$active"
            done
            cd - >/dev/null 2>&1 || return_error 1 "Previous directory not available."
        fi
        ;;
    remove)
        # Remove project
        if [ "$2" ]; then
            for argument in "${@:2}"; do
                if [ -e "$prm_dir/.active-$$.tmp" ] && [ "$(cat "$prm_dir/.active-$$.tmp")" == "$argument" ]; then
                    return_error 1 "Stop project $argument before trying to remove it"
                    return 1
                else
                    if [ -d "$prm_dir/$argument" ]; then
                        rm -rf "${prm_dir:?}/$argument/"
                        echo "Removed project $argument"
                    else
                        return_error 1 "$argument: No such project"
                        return 1
                    fi
                fi
            done
        else
            return_error 1 "No name given"
            return 1
        fi
        ;;
    rename)
        # Rename project
        if [ -e "$prm_dir/.active-$$.tmp" ] && [ "$(cat "$prm_dir/.active-$$.tmp")" == "$2" ]; then
            return_error 1 "Stop project $2 before trying to rename it"
            return 1
        else
            if [ "$2" ]; then
                if [ ! -d "$prm_dir/$2" ]; then
                    return_error 1 "$2: No such project"
                    return 1
                else
                    if [ "$3" ]; then
                        if [ -d "$prm_dir/$3" ]; then
                            return_error 1 "Project $3 already exists"
                            return 1
                        else
                            mv "$prm_dir/$2" "$prm_dir/$3"
                            echo "Renamed project $2 $3"
                        fi
                    else
                        return_error 1 "No new name given"
                        return 1
                    fi
                fi
            else
                return_error 1 "No name given"
                return 1
            fi
        fi
        ;;
    start)
        # Start project
        if [ "$2" ]; then
            if [ -d "$prm_dir/$2" ]; then
                if [ -e "$prm_dir/.active-$$.tmp" ] && [ "$(cat "$prm_dir/.active-$$.tmp")" == "$2" ]; then
                    return_error 1 "Project $2 is already active"
                    return 1
                else
                    if [ ! -e "$prm_dir/.path-$$.tmp" ]; then
                        pwd > "$prm_dir/.path-$$.tmp"
                    fi
                    if [ -e "$prm_dir/.active-$$.tmp" ]; then
                        . "$prm_dir/$(cat "$prm_dir/.active-$$.tmp")/stop.sh"
                        PRM_ACTIVE_PROJECT=""
                    fi
                    if [ -e "$prm_dir/$2/start.sh" ] && [ -e "$prm_dir/$2/stop.sh" ]; then
                        echo "$2" > "$prm_dir/.active-$$.tmp"
                        set_prompt_start "$2"
                        echo "Starting project $2"
                        . "$prm_dir/$2/start.sh"
                        PRM_ACTIVE_PROJECT=$2
                    else
                        return_error 1 "Cannot start project $2: Project has no scripts"
                        return 1
                    fi
                fi
            else
                return_error 1 "$2: No such project"
                return 1
            fi
        else
            return_error 1 "No name given"
            return 1
        fi
        ;;
    stop)
        # Stop project
        if [ -e "$prm_dir/.active-$$.tmp" ]; then
            . "$prm_dir/$(cat "$prm_dir/.active-$$.tmp")/stop.sh" || return_error 1 "Cannot stop project $project_name: Project has no stop script"
            echo "Stopping project $(cat "$prm_dir/.active-$$.tmp")"
            rm -f "$prm_dir/.active-$$.tmp"
            cd "$(cat "$prm_dir/.path-$$.tmp")" >/dev/null 2>&1 || return_error 1 "Could not change directory to original path."
            rm -f "$prm_dir/.path-$$.tmp"
            set_prompt_finish
            rm -f "$prm_dir/.prompt-$$.tmp"
            PRM_ACTIVE_PROJECT=""
        else
            return_error 1 "No active project"
            return 1
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
        # Anything else
        if [ -z "$1" ]; then
            # Bare command
            prm_help
        else
            # Error-Screen
            return_error 1 "prm: illegal option -- $1 (see \"prm --help\" for help)"
            prm_usage
            return 1
        fi
        ;;
esac

cleanup
