#!/bin/sh

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
  # assert_true with one argument will execute the string and pass if the result is 0
  assert_true "ls /tmp"
  assert_true "ls /tmp" "it can contain a description as well"
}

it_should_show_correct_duration() {
  sleep 0.2
}

# defer statements get executed in reversed order. If you need to do complex operations
# including pipes and redirections create a wrapper function
it_should_support_defer() {
  echo "hallo" > out
  defer "rm out"   # this will be executed when the test is finished or if any of the asserts fails
  defer "echo 'I will be executed second'"
  defer "echo 'I will be executed first'"

  assert_true "test -e out"
  assert_eq 0 0
}

it_should_compare_exit_code() {
  # check return code or other integers
  true
  assert_eq $? 0

  false
  assert_eq $? 1
}

it_should_compare_string() {
  # match strings
  assert_eq "foo" "foo"

  foo="$(echo 'hallo' | tr 'l' 'x')"
  assert_eq "${foo}" "haxxo"
}

it_should_compare_string_with_description() {
  # pass an optional description as a third argument ... helpful when a test function has many asserts
  assert_eq "$(echo 'hallo' | tr 'l' 'x')" "haxxo" "transforming string should work"
}

it_should_match_regexp() {
  # use 'assert_match' to match against an _extended_ regexp (https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html)
  assert_match "aaa:88909" "aaa:[0-9]{5}"
}

# it's possible to negate all assert statements by setting NEGATE=1
it_should_negate_correctly() {
  assert_false "ls /asdfagasdfadsga"
  assert_neq 1 0
  assert_nmatch "hallo" "xx"
}

it_should_be_possible_to_skip_a_test() {
  # you can skip a test ... it will be marked as skipped in the test output
  SKIP_TEST "only works in January"
}

it_should_have_correct_number_of_failing_tests() {
  ./failing-tests.sh
  assert_eq "$?" "10"
  assert_false "test -e out"
}

# this always needs to be last ... if you pass a parameter, this will be the class name of your tests
# leaving it out will use the file name of the tests
run_tests passing-tests
