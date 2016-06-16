#!/bin/sh

# the exit code will be equal to the number of failed tests

source spec.sh

after_all() {
  echo "hihihi ... I am last"
}

it_should_support_defer_even_on_fails() {
  echo "hallo" > out
  defer rm out   # this will be executed when the test is finished or if any of the asserts fails

  assert "test -e out"
  assert 0 1
}


it_should_execute_command() {
  # assert with one argument will execute the string and pass if the result is 0
  assert "ls /xxxtmp"
}

it_should_reflect_exit_code() {
  return 3
}

it_should_match_exit_code() {
  false

  # make sure that the return code is 0 ... or 1 or something different
  assert 0 0
  assert 0 0 "0 should be 0"
  assert $? 2
}

it_should_match_string() {
  # match strings
  assert "$(echo 'hallo' | tr 'l' 'x')" "haggo"
}

it_should_match_string_with_description() {
  # pass an optional description as a third argument ... helpful when on test has many asserts
  assert "$(echo 'hallo' | tr 'l' 'x')" "haggo" "transforming string should work"
}

it_should_match_regexp() {
  sleep 0.3
  # use 'assert_match' to match against an _extended_ regexp (https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html)
  assert_match "aaa:88X09" "aaa:[0-9]{5}"
}

it_should_have_seven_failing_tests() {
  assert 1 2
  assert 0 0
  echo "make sure it really has 7 failing tests!!!"
}

run_tests
