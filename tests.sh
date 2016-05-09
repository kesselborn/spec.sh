#!/bin/sh

# if you just want to execute some specific tests, set the TESTS env var to an _extended_ regexp (https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html)
#
#     # execute tests that matches exactly "it_should_match_string" or match the substring "execute_external_tests"
#     TESTS="(^it_should_match_string$|execute_external_tests)" ./tests.sh
#
#     # execute all tests that contain the word "string" in their name
#     TESTS="string" ./tests.sh
#
# usually, test output is logged to a file, if you additionally want verbose output, set env var VERBOSE:
#
#     VERBOSE=1 ./tests.sh
#
# if you want to abort all tests when one test fails, set FAIL_FAST:
#
#     FAIL_FAST=1 ./tests.sh

source spec.sh
include external-test.sh

# you can put tests in other files, just include them
# for f in test_*.sh; do include $f; done

# execute commands before running any test
before_all() {
  true
}

# execute command when all tests have beend executed
after_all() {
  true
}

# all functions starting with 'it_' will be executed in an unspecified order
it_should_execute_command() {
  # assert with one argument will execute the string and pass if the result is 0
  sleep 0.2
  assert "ls /tmp"
}

it_should_match_exit_code() {
  # check return code or other integers
  true
  assert $? 0

  false
  assert $? 1
}

it_should_match_string() {
  # match strings
  assert "foo" "foo"

  foo="$(echo 'hallo' | tr 'l' 'x')"
  assert "${foo}" "haxxo"
}

it_should_match_string_with_description() {
  # pass an optional description as a third argument ... helpful when a test function has many asserts
  assert "$(echo 'hallo' | tr 'l' 'x')" "haxxo" "transforming string should work"
}

it_should_match_regexp() {
  # use 'assert_match' to match against an _extended_ regexp (https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html)
  assert_match "aaa:88909" "aaa:[0-9]{5}"
}

it_should_be_possible_to_skip_a_test() {
  # you can skip a test ... it will be marked as skipped in the test output
  SKIP_TEST
}

# this always needs to be last
run_tests
