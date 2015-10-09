#!/usr/bin/env bats

load common

setup() {
    # Make prm internals available in tests
    prm > /dev/null 2>&1
}

teardown() {
    unset prm
}

@test "running prm in a subshell (not sourcing) prints an error" {
    # bash prm.sh
    run bash ./prm.sh
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
}

@test "bare run" {
    # prm
    run prm
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}
