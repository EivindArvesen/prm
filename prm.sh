#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

COPY="Written by Eivind Arvesen, 2015."
VERSION=0.0.1

DIR=$HOME/.prm

#set -e
#function cleanup {
#  #STOP
#  exit
#}
#$trap cleanup # exit

if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
fi

case "$1" in
    add)
        # Add project
        if [[ $2 ]]; then
            if [[ -d $DIR/$2 ]]; then
                echo "Project $2 already exists"
                # exit
            else
                mkdir -p $DIR/$2
                printf '#!/usr/bin/env bash\n\n# This script will run when STARTING the project "$2"\n\n# Here you might want to cd into your project directory, activate virtualenvs, etc.\n\n' > $DIR/$2/start.sh
                printf '#!/usr/bin/env bash\n\n# This script will run when STOPPING the project "$2"\n\n# Here you might want to deactivate virtualenvs, clean up temporary files, etc.\n\n' > $DIR/$2/stop.sh
                $EDITOR $DIR/$2/start.sh && $EDITOR $DIR/$2/stop.sh
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    edit)
        # Edit project
        if [[ $2 ]]; then
            if [[ -d $DIR/$2 ]]; then
                $EDITOR $DIR/$2/start.sh && $EDITOR $DIR/$2/stop.sh
            else
                echo "No such project"
                # exit
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    list)
        # List projects
        if [[ ! `find $DIR -type d | wc -l` -gt 1 ]]; then
            echo "No projects exist"
        else
            cd $DIR/
            ls -d *
            cd - >/dev/null 2>&1
        fi
        ;;
    remove)
        # Remove project
        if [[ $2 ]]; then
            if [[ -d $DIR/$2 ]]; then
                rm -rf "$DIR/$2/"
                echo "Removed $2"
            else
                echo "No such project"
                # exit
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    start)
        # Start project
        if [[ $2 ]]; then
            if [[ -e $DIR/active.d ]]; then
                . $DIR/$(cat $DIR/active.d)/stop.sh
            fi
            if [[ ! -e $DIR/path.d ]]; then
                 pwd > $DIR/path.d
            fi
            echo $2 > $DIR/active.d
            if [[ -d $DIR/$2 ]]; then
                echo "Starting project $2"
                . $DIR/$2/start.sh
            else
                echo "No such project"
                # exit
            fi
        else
            echo "No name given"
            # exit
        fi
        ;;
    stop)
        # Stop project
        if [[ -e $DIR/active.d ]]; then
            . $DIR/$(cat $DIR/active.d)/stop.sh
            echo "Stopping project $(cat $DIR/active.d)"
            rm $DIR/active.d
            cd $(cat $DIR/path.d)
            rm $DIR/path.d
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
        echo "  start <project name>     Start project."
        echo "  stop                     Stop active project."
        echo "  -h --help                Display this information."
        echo "  -v --version             Display version info."
        echo ""
        echo "Please report bugs at https://github.com/eivind88/prm"
        echo ""
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
