#!/usr/bin/env bats

setup() {
  NODEBREW_DIR=$HOME/.nodebrew
  RBENV_DIR=$HOME/.rbenv
}

@test "runnable zsh" {
  DIR=$(cd "${BATS_TEST_DIRNAME}/../"; pwd)
  export ZDOTDIR=$BATS_TMPDIR/zsh-test
  ln -sf $ZDOTDIR $DIR
  run zsh -i -l -c "exit"
  [ $status -eq 0 ]
  [ "$(strings <<< $output)" = "" ]
}

@test "runnable bash" {
  run bash
  [ $status -eq 0 ]
  [ "$(strings <<< $output)" = "" ]
}
