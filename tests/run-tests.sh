#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

test_folder="./tests"

for shell_folder in "$test_folder/"*; do
    [ -d "$shell_folder" ] || continue
    shells="$shells $(basename "$shell_folder")"
done

cat <<EOF
#------------------------------------------------------------------------------
# System data
#

# test run info
shells: ${shells}
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

for shell_folder in "$test_folder/"*; do
    [ -d "$shell_folder" ] || continue
    shell=$(basename "$shell_folder")
    cat <<EOF

#------------------------------------------------------------------------------
# Running the test suite with ${shell}
# $("${shell}" --version)
#
EOF
echo
    for test_file in "$shell_folder/"*; do
        echo "Executing the $(basename $test_file) test file ---"
        bats $test_file
        echo
    done
done
