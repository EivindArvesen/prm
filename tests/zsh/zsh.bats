#!/usr/bin/env bats


@test "runnable zsh" {
  DIR=$(cd "${BATS_TEST_DIRNAME}/../"; pwd)
  #export ZDOTDIR=$BATS_TMPDIR/zsh-test
  #ln -sf $ZDOTDIR $DIR
  run zsh -i -l -c "exit"
  [ $status -eq 0 ]
  [ "$(strings <<< $output)" = "" ]
}
