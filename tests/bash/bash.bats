#!/usr/bin/env bats


@test "runnable bash" {
  run bash -c "exit"
  [ $status -eq 0 ]
  [ "$(strings <<< $output)" = "" ]
}
