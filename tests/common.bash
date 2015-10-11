#!/usr/bin/env bash

prm() {
    # Make prm available as normally run
    source ./prm.sh "$@"
}

teardown() {
    echo "STATUS: $status"
    echo "OUTPUT: $output"
}

PRM_DIR="./tmp-prm-home"
prm_dir="${PRM_DIR:-$HOME/.prm}"
prm_bats_tests=true

# https://github.com/sstephenson/bats
#
# Complicated run's should be performed like so:
#   run bash -c "echo 'foo bar baz' | cut -d' ' -f2"
#
# Ouput outside of tests should redirect to stderr like so:
#   >&2
# in order not to mess up (TAP stream) output
