#!/usr/bin/env bats

load common

setup() {
    # Make prm internals available in tests
    prm > /dev/null 2>&1
}

teardown() {
    unset prm
}

@test "global variables" {
    [ "${COPY}" ]
    [ "${VERSION}" ]
    [ "${SOURCE}" ]
}

@test "return_error function without code" {
    run return_error
    [ "$status" -eq 1 ]
}

@test "return_error function with code without message" {
    run return_error 2
    [ "$status" -eq 2 ]
}

@test "return_error function with code and message" {
    run return_error 1 'test'
    [ "$status" -eq 1 ]
    [ "$output" = "test" ]
}
