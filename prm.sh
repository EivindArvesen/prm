#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

COPY="Written by Eivind Arvesen, 2015."
VERSION=0.1.0

prm_dir=$HOME/.prm


if [ ! -d "$prm_dir" ]; then
    mkdir -p "$prm_dir"
fi

case "$1" in
    add)
        # Add project
        if [[ $2 ]]; then
            if [[ -d $prm_dir/$2 ]]; then
                echo "Project $2 already exists"
                # exit
            else
                mkdir -p $prm_dir/$2
                printf '#!/usr/bin/env bash\n\n# This script will run when STARTING the project "$2"\n# Here you might want to cd into your project directory, activate virtualenvs, etc.\n\n' > $prm_dir/$2/start.sh
                printf '#!/usr/bin/env bash\n\n# This script will run when STOPPING the project "$2"\n# Here you might want to deactivate virtualenvs, clean up temporary files, etc.\n\n' > $prm_dir/$2/stop.sh
                $EDITOR $prm_dir/$2/start.sh && $EDITOR $prm_dir/$2/stop.sh
                echo "Added project $2"
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    edit)
        # Edit project
        if [[ $2 ]]; then
            if [[ -d $prm_dir/$2 ]]; then
                $EDITOR $prm_dir/$2/start.sh && $EDITOR $prm_dir/$2/stop.sh
                echo "Edited project $2"
            else
                echo "$2: No such project"
                # exit
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    list)
        # List projects
        if [[ ! `find $prm_dir -type d | wc -l` -gt 1 ]]; then
            echo "No projects exist"
        else
            cd $prm_dir/
            echo -e "\000$(ls -d *)"
            cd - >/dev/null 2>&1
        fi
        ;;
    remove)
        # Remove project
        if [[ $2 ]]; then
            if [[ -e $prm_dir/.active.d ]] && [[ $(cat $prm_dir/.active.d) == $2 ]]; then
                echo "Stop project $2 before trying to remove it"
            else
                if [[ -d $prm_dir/$2 ]]; then
                    rm -rf "$prm_dir/$2/"
                    echo "Removed project $2"
                else
                    echo "$2: No such project"
                    # exit
                fi
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    rename)
        # Rename project
        if [[ -e $prm_dir/.active.d ]] && [[ $(cat $prm_dir/.active.d) == $2 ]]; then
            echo "Stop project $2 before trying to rename it"
        else
            if [[ $2 ]]; then
                if [[ ! -d $prm_dir/$2 ]]; then
                    echo "$2: No such project"
                else
                    if [[ $3 ]]; then
                        if [[ -d $prm_dir/$3 ]]; then
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
        if [[ $2 ]]; then
            if [[ -d $prm_dir/$2 ]]; then
                if [[ -e $prm_dir/.active.d ]] && [[ $(cat $prm_dir/.active.d) == $2 ]]; then
                    echo "Project $2 is already active"
                else
                    if [[ ! -e $prm_dir/.path.d ]]; then
                        pwd > $prm_dir/.path.d
                    fi
                    if [[ -e $prm_dir/.active.d ]]; then
                        . $prm_dir/$(cat $prm_dir/.active.d)/stop.sh
                    fi
                    echo $2 > $prm_dir/.active.d
                    if [[ ! -e $prm_dir/.prompt.d ]]; then
                        echo $PS1 > $prm_dir/.prompt.d
                        export PS1="[$2] $PS1"
                    else
                        export PS1="[$2] $(cat $prm_dir/.prompt.d)"
                    fi
                    echo "Starting project $2"
                    . $prm_dir/$2/start.sh
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
        if [[ -e $prm_dir/.active.d ]]; then
            . $prm_dir/$(cat $prm_dir/.active.d)/stop.sh
            echo "Stopping project $(cat $prm_dir/.active.d)"
            rm $prm_dir/.active.d
            cd $(cat $prm_dir/.path.d)
            rm $prm_dir/.path.d
            export PS1=$(cat $prm_dir/.prompt.d)
            rm $prm_dir/.prompt.d
        else
            echo "No active project"
            # exit
        fi
        ;;
    -h|--help)
        # Help-Screen
        echo "Usage: prm [options] ..."
        echo "Options:"
        echo "  add <project name>       Add project."
        echo "  edit <project name>      Edit project."
        echo "  list                     List all projects."
        echo "  remove <project name>    Remove project."
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
