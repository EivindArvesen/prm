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
    run mkdir "$prm_dir/$project_name"
    run prm active
    [ "$status" -eq 0 ]
    [ "$output" = "$$    $project_name" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "add option fails when no argument is given" {
    # prm add <project name>
    run prm add
    [ "$status" -eq 1 ]
    [ "$output" = "No name given" ]
}

@test "add option fails when project exists" {
    # prm add <project name>
    project_name="test-prj"
    mkdir -p "$prm_dir/$project_name"
    run prm add $project_name
    [ "$status" -eq 1 ]
    [ "$output" != "" ]
    rm -rf "$prm_dir/$project_name"
}

@test "add option with arg adds project" {
    # prm add <project name>
    project_name="test-prj"
    run prm add $project_name
    [ "$status" -eq 0 ]
    [ "$output" = "Added project $project_name" ]
    rm -rf "$prm_dir/$project_name"
}

@test "add option with arg adds project under Cygwin (Mock)" {
    # prm add <project name>
    prm_use_cygpath=true
    project_name="test-prj"
    run prm add $project_name
    [ "$status" -eq 0 ]
    [ $(echo "${lines[0]}" | grep "cygpath.exe: command not found") ]
    [ $(echo "${lines[1]}" | grep "cygpath.exe: command not found") ]
    [ "${lines[2]}" = "Added project $project_name" ]
    rm -rf "$prm_dir/$project_name"
    unset $prm_use_cygpath
}

@test "add option with several args adds several projects" {
    # prm add <project name>
    project_name1="prj1"
    project_name2="prj2"
    run prm add $project_name1 $project_name2
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    [ "${lines[0]}" = "Added project $project_name1" ]
    [ "${lines[1]}" = "Added project $project_name2" ]
    rm -rf "$prm_dir/$project_name1" "$prm_dir/$project_name2"
}

@test "copy fails when old project does not exist" {
    # prm copy <old> <new>
    prj=does-not-exist
    run prm copy $prj new-prj
    [ "$status" -eq 1 ]
    [ "$output" = "$prj: No such project" ]
}

@test "copy fails when new project already exists" {
    # prm copy <old> <new>
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    run prm copy $project_name $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "Project $project_name already exists" ]
    rm -rf "$prm_dir/$project_name"
}

@test "copy succeeds if old project exists" {
    # prm copy <old> <new>
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh"
    run prm copy $project_name new-prj hidden
    [ "$status" -eq 0 ]
    [ "$output" = "Copied project $project_name to new-prj" ]
    rm -rf "$prm_dir/$project_name" "$prm_dir/new-prj"
}

@test "edit option succeeds if project exists under Cygwin (Mock)" {
    # prm copy <old> <new>
    prm_use_cygpath=true
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh"
    run prm copy $project_name new-prj hidden
    [ "$status" -eq 0 ]
    [ $(echo "${lines[0]}" | grep "cygpath.exe: command not found") ]
    [ $(echo "${lines[1]}" | grep "cygpath.exe: command not found") ]
    [ "${lines[2]}" = "Copied project $project_name to new-prj" ]
    rm -rf "$prm_dir/$project_name" "$prm_dir/new-prj"
    unset $prm_use_cygpath
}

@test "copy option fails when no new name is given" {
    # prm add <project name>
    project_name="test-prj"
    mkdir -p "$prm_dir/$project_name"
    run prm copy $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "No new name given" ]
    rm -rf "$prm_dir/$project_name"
}

@test "copy option fails when no name is given" {
    # prm add <project name>
    run prm copy
    [ "$status" -eq 1 ]
    [ "$output" = "No name given" ]
}

@test "edit option succeeds if project exists" {
    # prm edit <project name>
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh"
    run prm edit $project_name
    [ "$status" -eq 0 ]
    [ "$output" = "Edited project $project_name" ]
    rm -rf "$prm_dir/$project_name"
}

@test "edit option succeeds if project exists under Cygwin (Mock)" {
    # prm edit <project name>
    prm_use_cygpath=true
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh"
    run prm edit $project_name
    [ "$status" -eq 0 ]
    [ $(echo "${lines[0]}" | grep "cygpath.exe: command not found") ]
    [ $(echo "${lines[1]}" | grep "cygpath.exe: command not found") ]
    [ "${lines[2]}" = "Edited project $project_name" ]
    rm -rf "$prm_dir/$project_name"
    unset $prm_use_cygpath
}

@test "edit option succeeds if several project exist" {
    # prm add <project name>
    project_name1="prj1"
    project_name2="prj2"
    mkdir -p "$prm_dir/$project_name1" "$prm_dir/$project_name2"
    touch "$prm_dir/$project_name1/start.sh" "$prm_dir/$project_name1/stop.sh"
    touch "$prm_dir/$project_name2/start.sh" "$prm_dir/$project_name2/stop.sh"
    run prm edit $project_name1 $project_name2
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    [ "${lines[0]}" = "Edited project $project_name1" ]
    [ "${lines[1]}" = "Edited project $project_name2" ]
    rm -rf "$prm_dir/$project_name1" "$prm_dir/$project_name2"
}

@test "edit option fails if project does not exists" {
    # prm edit <project name>
    project_name=exists
    run prm edit $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "$project_name: No such project" ]
}

@test "edit option fails when no name is given" {
    # prm edit <project name>
    run prm edit
    [ "$status" -eq 1 ]
    [ "$output" = "No name given" ]
}

@test "list option fails when no projects exist" {
    # prm list
    run prm list
    [ "$status" -eq 1 ]
    [ "$output" = "No projects exist" ]
}

@test "list option succeeds when a project exists" {
    # prm list
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh"
    run prm list
    [ "$status" -eq 0 ]
    [ "$output" = "$project_name" ]
    rm -rf "$prm_dir/$project_name"
}

@test "list option succeeds when several projects exist" {
    # prm list
    project_name1="prj1"
    project_name2="prj2"
    mkdir -p "$prm_dir/$project_name1" "$prm_dir/$project_name2"
    touch "$prm_dir/$project_name1/start.sh" "$prm_dir/$project_name1/stop.sh"
    touch "$prm_dir/$project_name2/start.sh" "$prm_dir/$project_name2/stop.sh"
    run prm list
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    [ "${lines[0]}" = "$project_name1" ]
    [ "${lines[1]}" = "$project_name2" ]
    rm -rf "$prm_dir/$project_name1" "$prm_dir/$project_name2"
}

@test "remove option fails if argument project is currently active" {
    # prm remove <project name>
    project_name="dummy-project"
    touch "$prm_dir/.active-$$.tmp"
    echo "$project_name" > "$prm_dir/.active-$$.tmp"
    [ -e "$prm_dir/.active-$$.tmp" ]
    run mkdir "$prm_dir/$project_name"
    run prm remove $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "Stop project $project_name before trying to remove it" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "remove option succeeds if argument project exists" {
    # prm remove <project name>
    project_name="non-existing-dummy-project"
    mkdir "$prm_dir/$project_name"
    run prm remove $project_name
    [ "$status" -eq 0 ]
    [ "$output" = "Removed project $project_name" ]
}

@test "remove option succeeds if argument projects exists" {
    # prm remove <project name>
    project_name1="prj1"
    project_name2="prj2"
    mkdir "$prm_dir/$project_name1" "$prm_dir/$project_name2"
    run prm remove $project_name1 $project_name2
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    [ "${lines[0]}" = "Removed project $project_name1" ]
    [ "${lines[1]}" = "Removed project $project_name2" ]
}

@test "remove option fails if argument project does not exist" {
    # prm remove <project name>
    project_name="non-existing-project"
    run prm remove $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "$project_name: No such project" ]
}

@test "remove option fails if no argument is given" {
    # prm remove <project name>
    run prm remove
    [ "$status" -eq 1 ]
    [ "$output" = "No name given" ]
}

@test "rename option fails when argument project is active" {
    # prm rename <old> <new>
    project_name="dummy-project"
    touch "$prm_dir/.active-$$.tmp"
    echo "$project_name" > "$prm_dir/.active-$$.tmp"
    run mkdir "$prm_dir/$project_name"
    run prm rename $project_name new_stuff
    [ "$status" -eq 1 ]
    [ "$output" = "Stop project $project_name before trying to rename it" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "rename option fails when argument project does not exist" {
    # prm rename <old> <new>
    run prm rename no_stuff
    [ "$status" -eq 1 ]
    [ "$output" = "no_stuff: No such project" ]
}

@test "rename option fails if project with new name already exists" {
    # prm rename <old> <new>
    project_name=exists
    mkdir -p "$prm_dir/$project_name"
    run prm rename $project_name $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "Project $project_name already exists" ]
    rm -rf "$prm_dir/$project_name"
}

@test "rename option succeeds if project argument exists" {
    # prm rename <old> <new>
    project_name=prjct
    mkdir -p "$prm_dir/$project_name"
    run prm rename $project_name new_name
    [ "$status" -eq 0 ]
    [ "$output" = "Renamed project $project_name new_name" ]
    rm -rf "$prm_dir/new_name"
}

@test "rename option fails when no new name is given" {
    # prm rename <old> <new>
    project_name=prjcts
    mkdir -p "$prm_dir/$project_name"
    run prm rename $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "No new name given" ]
    rm -rf "$prm_dir/$project_name"
}

@test "rename option fails when no name argument is given" {
    # prm rename <old> <new>
    run prm rename
    [ "$status" -eq 1 ]
    [ "$output" = "No name given" ]
}

@test "start option fails if argument project is already active" {
    # prm start <project name>
    project_name="dummy-project"
    touch "$prm_dir/.active-$$.tmp"
    echo "$project_name" > "$prm_dir/.active-$$.tmp"
    run mkdir "$prm_dir/$project_name"
    run prm start $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "Project $project_name is already active" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "start option fails if argument project has no scripts" {
    # prm start <project name>
    project_name="dummy-prj"
    run mkdir "$prm_dir/$project_name"
    run prm start $project_name
    [ "$status" -eq 1 ]
    [ "$output" = "Cannot start project $project_name: Project has no scripts" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "start option succeeds if argument project exists" {
    # prm start <project name>
    project_name="dummy-project"
    run mkdir "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh"
    run prm start $project_name
    [ "$status" -eq 0 ]
    [ "$output" = "Starting project $project_name" ]
    rm -rf "$prm_dir/.active-$$.tmp" "$prm_dir/$project_name"
}

@test "start option fails if argument project does not exist" {
    # prm start <project name>
    prjct="does-not-exist"
    run prm start $prjct
    [ "$status" -eq 1 ]
    [ "$output" = "$prjct: No such project" ]
}

@test "start option fails if no argument is given" {
    # prm start <project name>
    run prm start
    [ "$status" -eq 1 ]
    [ "$output" = "No name given" ]
}

@test "stop option succeeds when there is an active project" {
    # prm stop
    project_name="dummy-project"
    run mkdir "$prm_dir/$project_name"
    touch "$prm_dir/$project_name/start.sh" "$prm_dir/$project_name/stop.sh" "$prm_dir/.active-$$.tmp"
    echo "$project_name" > "$prm_dir/.active-$$.tmp"
    run prm stop
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    rm -rf "$prm_dir/$project_name"
}

@test "stop option prints error when active project does not have stop script" {
    # prm stop
    project_name="dummy"
    run mkdir "$prm_dir/$project_name"
    touch "$prm_dir/.active-$$.tmp"
    echo "$project_name" > "$prm_dir/.active-$$.tmp"
    run prm stop
    [ "$output" != "Cannot stop project $project_name: Project has no stop script" ]
    rm -rf "$prm_dir/$project_name" "$prm_dir/.active-$$.tmp"
}

@test "stop option fails if there is no active project" {
    # prm stop
    run prm stop
    [ "$status" -eq 1 ]
    [ "$output" = "No active project" ]
}

@test "help option prints help screen" {
    # prm -h --help
    run prm -h
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
    run prm --help
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}

@test "version option prints version" {
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
