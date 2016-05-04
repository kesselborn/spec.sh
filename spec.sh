# Copyright (C) 2015-2016 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

# This is a mini shell test framework that outputs the test like go test does
# For usage see files tests.sh and failing-tests.sh and execute them to see
# spec.sh in action

test ! -t || IS_TTY=true
failed_tests_cnt=0
set -o pipefail

# use 'include <file>' to split tests over several files
include() {
  __SPEC_SH_INCLUDES="${__SPEC_SH_INCLUDES} $1"
  source $1
}

# run the tests
run_tests() {
  local functions=$(grep -Eho "(^it_[a-zA-Z_]*|^before_all|^after_all)" $0 ${__SPEC_SH_INCLUDES})

  for f in $(printf "${functions}" | grep -o "before_all") \
           $(printf "${functions}" | grep "^it_" | grep -E "${TESTS:-.}") \
           $(printf "${functions}" | grep -o "after_all")
  do
    run_test $f
  done

  exit ${failed_tests_cnt}
}

run_test() {
  local function=$1
  local log=$(mktemp)

  # this is the only dash compatible way to get sub-second time I found
  (mkfifo ${log}.sync; time -p cat ${log}.sync) 2>&1 | grep real | sed 's/real/	duration/' >> ${log} &
  printf "=== RUN ${function}\n"
  test "${VERBOSE}" = "1" && ( set -x; ${function} ) 2>&1 | sed 's/^/	/g' | tee ${log} \
                          || ( set -x; ${function} ) 2>&1 | sed 's/^/	/g' >     ${log}
  result=$?
  printf "" > ${log}.sync && rm ${log}.sync

  duration=$(tail -n1 ${log} | grep duration | cut -f2 -d" ")

  if [ ${result} -eq 0 ]; then
    printf -- "--- PASS: %s (%.2fs)\n" ${function} ${duration}
  elif [ ${result} -eq 222 ]; then
    printf -- "--- SKIP: %s (%.2fs)\n" ${function} ${duration}
  else
    printf -- "--- FAIL: %s (%.2fs)\n" ${function} ${duration}
    test "${VERBOSE}" = "1" || cat ${log}
    printf "\terror code: %d\n\terror occured in ${IS_TTY:+\033[1;38;40}m%s${IS_TTY:+\033[m}\n" ${result} "${function}"
    let "failed_tests_cnt++"
  fi
  rm ${log}
}

SKIP_TEST() {
  exit 222
}

assert_match() {
  printf "$1" | grep -E -m1 -o "$2" | head -n1 | grep -E "$2"
  assert $? 0 "checking '$1' to match /$2/"
}

# two possible ways to call:
# assert "<command that should succeed>"
# assert "<got>" "<expected>" ["<description>"]
assert() {
  if [ -z "$2" ]; then
    $1 # execute first parameter
    got=$?
    expected=0
    description="expecting command '$1' to succeed"
  else
    got=$1
    expected=$2
    description=$3
  fi

  (set +x
    description="${description}${description:+ (}'${got}' == '${expected}'${description:+)}"
    if [ "${got}" != "${expected}" ]; then
      printf "failed expectation: ${IS_TTY:+\033[1;38;40}m${description} ${IS_TTY:+\033[m}\n"
      exit 1
    else
      printf "######################################## PASSED TEST: ${description} \n"
    fi
  )
}

