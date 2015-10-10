#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

#test_folder="./tests"
test_folder=$( cd $(dirname $0) ; pwd -P )

# Remember: $CI and $TRAVIS will be set to true if running on Travis CI.

declare -a shells=(
    "bash"
    "zsh"
)
tests=$(ls -1 "$test_folder/"*.bats | wc -l)

# for shell_folder in "$test_folder/"*; do
#     [ -d "$shell_folder" ] || continue
#     shells="$shells $(basename "$shell_folder")"
# done

cat <<EOF
#------------------------------------------------------------------------------
# System data
#

# test run info
shells: ${shells[@]}
tests: ${tests}
EOF
for key in ${env}; do
    eval "echo \"${key}=\$${key}\""
done
echo

# output system data
echo "# system info"
echo "$ date"
date
echo

echo "$ uname -mprsv"
uname -mprsv

for shell in "${shells[@]}"; do
    cat <<EOF

#------------------------------------------------------------------------------
# Running the test suite with ${shell}
# $("${shell}" --version)
#
EOF
echo
    for test_file in "$test_folder/"*.bats; do
        echo "Executing the $(basename $test_file) test file ---"
        bats $test_file
        echo
    done
done
