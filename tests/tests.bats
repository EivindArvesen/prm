#!/usr/bin/env bats
#
# https://github.com/sstephenson/bats

prm() {
    # Make prm available as normally run
    source ./prm.sh "$@"
}

setup() {
    # Make prm internals available in tests
    prm > /dev/null 2>&1
}

teardown() {
    unset prm
}

@test "bare run" {
    run prm #>&2
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}

@test "global variables" {
    [ "${COPY}" ]
    [ "${VERSION}" ]
    [ "${SOURCE}" ]
}

@test "return_error function" {
    run return_error 1
    [ "$status" -eq 1 ]

    run return_error 1 'test'
    [ "$status" -eq 1 ]
    [ "$output" = "test" ]
}
