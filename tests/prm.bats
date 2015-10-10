#!/usr/bin/env bats

load common

@test "running prm in a subshell (not sourcing) prints an error" {
    # bash prm.sh
    run bash ./prm.sh
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
}

@test "active option lists nothing when nothing is active" {
    # prm active
    run prm active
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "active option lists active projects" {
    # prm active
    project_name="non-existing-dummy-project"
    touch "$prm_dir/.active-$$.tmp"
    echo "$project_name" > "$prm_dir/.active-$$.tmp"
    [ -e "$prm_dir/.active-$$.tmp" ]
    cat "$prm_dir/.active-$$.tmp"
    run mkdir "$prm_dir/$project_name"
    run prm active
    [ "$status" -eq 0 ]
    [ "$output" = "$$    $project_name" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "add" {
    # prm add <project name>
    skip
}

@test "copy" {
    # prm copy <old> <new>
    skip
}

@test "edit" {
    # prm edit <project name>
    skip
}

@test "list" {
    # prm list
    skip
}

@test "remove" {
    # prm remove <project name>
    skip
}

@test "rename" {
    # prm rename <old> <new>
    skip
}

@test "start" {
    # prm start <project name>
    skip
}

@test "stop" {
    # prm stop
    skip
}

@test "help" {
    # prm -h --help
    run prm -h
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    run prm --version
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}

@test "version" {
    # prm -v --version
    run prm -v
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    run prm --version
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}

@test "bare run prints help screen" {
    # prm
    run prm
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}

@test "illegal option prints error screen" {
    # prm
    run prm illegal
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
}
