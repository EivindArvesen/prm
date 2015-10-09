#!/usr/bin/env bats

load common

setup() {
    # Make prm internals available in tests
    prm > /dev/null 2>&1
}

teardown() {
    unset prm
}

@test "bare run" {
    run prm
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}
