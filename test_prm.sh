#!/usr/bin/env bash

# Copyright (c) 2015 Eivind Arvesen. All Rights Reserved.

# Make prm as normally run available
prm() {
    source ./prm.sh "$@"
}

# BEFORE ALL TESTS:
oneTimeSetUp() {
    prm > /dev/null 2>&1
    # everything in prm is now available in tests
}

# AFTER ALL TESTS:
#oneTimeTearDown()

# BEFORE EACH TEST:
# setUp()

# AFTER EACH TEST:
# tearDown()

testGlobalVariables() {
    assertNotNull "${COPY}"
    assertNotNull "${VERSION}"
    assertNotNull "${SOURCE}"
}

testReturnError() {
    `return_error 1`
    assertEquals "return_error does not return 1" \
        1 "$?"
    `return_error 1 'test'`
    assertEquals "return_error does not return 1 when given message" \
        1 "$?"
    assertEquals "return_error does not return correct message" \
        'test' "`return_error 1 'test'`"
}

# for zsh compatibility
#setopt shwordsplit

if [ "$CI" == true -a "$TRAVIS" == true ];then
. shunit2-2.1.6/src/shunit2
else
    #printf "Not on Travis CI\n\n"
    if [ ! "$(basename "${0//-/}")" == "shunit2" ]; then
        #echo "Run test locally via 'shunit2 test_prm.sh'"
        shunit2 "$0"
    fi
fi
