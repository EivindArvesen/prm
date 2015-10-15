#!/usr/bin/env bats

load common

# Make prm internals available in tests
prm > /dev/null 2>&1

@test "global variables exist" {
    [ "${COPY}" ]
    [ "${VERSION}" ]
    [ "${SOURCE}" ]
}

@test "return_error function returns 1 when not given code nor message as args" {
    run return_error
    [ "$status" -eq 1 ]
}

@test "return_error function returns code given as arg when not given message" {
    run return_error 2
    [ "$status" -eq 2 ]
    [ ! "$output" ]
}

@test "return_error function returns both code and message given as args" {
    run return_error 1 'test'
    [ "$status" -eq 1 ]
    [ "$output" = "test" ]
}

@test "prm_dir exists" {
    [ "${prm_dir}" ]
}

@test "prm_dir is created" {
    [ -d "$prm_dir/.common" ]
}

@test "prompt_var is set" {
    [ "${prompt_var}" ]
}

@test "prm_load helper function fails when not given args" {
    run prm_load
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
}

@test "prm_load helper function succeeds when given arg" {
    run bash -c "echo 'echo TesT' > $prm_dir/.common/TEST.sh"
    run prm_load TEST
    [ "$status" -eq 0 ]
    [ "$output" = "TesT" ]
    run bash -c "rm $prm_dir/.common/TEST.sh "
}

@test "help-function works as expected" {
    run prm_help
    [ "$status" -eq 0 ]
    [ "$output" ]
}

@test "usage-function works as expected" {
    run prm_usage
    [ "$status" -eq 0 ]
    [ "$output" ]
}

@test "check_editor fails if editor env var is not set" {
    if [ ! -z "$EDITOR" ]; then
        OLD_EDITOR=$EDITOR
        unset -v "EDITOR"
    fi
    run check_editor
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
    [ "${lines[0]}" = "\$EDITOR is not set." ]
    if [ ! -z "$OLD_EDITOR" ]; then
        EDITOR=$OLD_EDITOR
        unset -v "OLD_EDITOR"
    fi
}

@test "check_editor succeeds if editor var is set" {
    if [ -z "$EDITOR" ]; then
        WAS_NOT_SET=true
        EDITOR="vi" # cue religious war
    fi
    run check_editor
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
    if [ "$WAS_NOT_SET" ]; then
        unset -v "EDITOR"
        unset -v "WAS_NOT_SET"
    fi
}

@test "set_prompt_start changes prompt" {
    run bash -c "echo \"\$$prompt_var\" > $prm_dir/.prompt-$$.tmp"
    run set_prompt_start "test"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
    eval $prompt_var="'$(cat "$prm_dir/.prompt-$$.tmp")'"
    run rm "$prm_dir/.prompt-$$.tmp"
}

@test "set_prompt_finish reverts to original prompt" {
    run bash -c "echo \"\$$prompt_var\" > $prm_dir/.prompt-$$.tmp"
    run set_prompt_finish
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
    run rm "$prm_dir/.prompt-$$.tmp"
}

@test "check_project_name fails if arg is blacklisted" {
    run check_project_name ".reserved"
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
    run check_project_name "reserved.tmp"
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
}

@test "check_project_name succeeds if arg is not blacklisted" {
    run check_project_name "test"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "cleanup does not clean up live project instances" {
    run bash -c "touch $prm_dir/.active-$$.tmp $prm_dir/.path-$$.tmp $prm_dir/.prompt-$$.tmp"
    run cleanup
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
    run bash -c "rm -f $prm_dir/.active-$$.tmp $prm_dir/.path-$$.tmp $prm_dir/.prompt-$$.tmp"
}

@test "cleanup cleans up dead project instances" {
    run bash -c "touch $prm_dir/.active-99999.tmp $prm_dir/.path-99999.tmp $prm_dir/.prompt-99999.tmp"
    run cleanup
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
    run bash -c "rm -f $prm_dir/.active-99999.tmp $prm_dir/.path-99999.tmp $prm_dir/.prompt-99999.tmp"
}
