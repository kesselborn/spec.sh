#!/bin/sh

# the exit code will be equal to the number of failed tests

source spec.sh

after_all() {
  echo "hihihi ... I am last"
}

it_should_support_defer_even_on_fails() {
  echo "hallo" > out
  defer rm out   # this will be executed when the test is finished or if any of the asserts fails

  assert_true "test -e out"
}

# 1
it_should_assert_command() {
  # assert_true with one argument will execute the string and pass if the result is 0
  assert_true "ls /xxxtmp"
}

# 2
it_should_assert_command_with_description() {
  assert_true "ls /xxxtmp" "assert_true with a description"
}

# 3
it_should_negate_assert_match_correctly() {
  assert_nmatch "hallo" "ll"
}

# 4
it_should_compare_exit_code() {
  false

  # make sure that the return code is 0 ... or 1 or something different
  assert_eq 0 0
  assert_eq 0 0 "0 should be 0"
  assert_eq $? 2
}

# 5
it_should_compare_string() {
  # match strings
  assert_eq "$(echo 'hallo' | tr 'l' 'x')" "haggo"
}

# 6
it_should_compare_string_with_description() {
  # pass an optional description as a third argument ... helpful when on test has many asserts
  assert_eq "$(echo 'hallo' | tr 'l' 'x')" "haggo" "transforming string should work"
}

# 7
it_should_match_regexp() {
  sleep 0.3
  # use 'assert_match' to match against an _extended_ regexp (https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html)
  assert_match "aaa:88X09" "aaa:[0-9]{5}"
}

# 8
it_should_negate_assert_correctly() {
  assert_false "ls /" "this test should fail"
}

# 9
it_should_negate_assert_eq_correctly() {
  assert_neq 1 1
}

# 10
it_should_reflect_exit_code() {
  return 3
}


run_tests
