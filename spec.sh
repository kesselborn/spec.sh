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
test -z "$NO_ANSI_COLOR" || unset IS_TTY
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

  local timer=$(start_timer)
  for f in $(printf "${functions}" | grep -o "before_all") \
           $(printf "${functions}" | grep "^it_" | grep -E "${TESTS:-.}") \
           $(printf "${functions}" | grep -o "after_all")
  do
    run_test $f
  done
  duration=$(stop_timer ${timer})

  if [ ${failed_tests_cnt} -eq 0 ]; then
    printf "PASS\nok	${1:-$0}	%.2fs\n" ${duration}
  else
    printf "FAIL\nexit status %d\nFAIL	${1:-$0}	%.2fs\n" ${failed_tests_cnt} ${duration}
  fi

  exit ${failed_tests_cnt}
}

start_timer() {
  local file=$(mktemp)
  (mkfifo ${file}.sync; time -p cat ${file}.sync) 2>&1 | grep real | sed 's/real//' > ${file} &
  echo ${file}
}

stop_timer() {
  local file=$1
  printf "" > ${file}.sync
  duration=$(cat ${file})
  rm ${file}.sync ${file}
  echo ${duration}
}


run_test() {
  local function=$1
  local log=$(mktemp)

  local timer=$(start_timer)
  printf "=== RUN ${function}\n"
  test "${VERBOSE}" = "1" && ( set -x; ${function} ) 2>&1 | sed 's/^/	/g' |  tee -a ${log} \
                          || ( set -x; ${function} ) 2>&1 | sed 's/^/	/g' >>        ${log}
  result=$?
  duration=$(stop_timer ${timer})

  if [ ${result} -eq 0 ]; then
    printf -- "--- PASS: %s (%.2fs)\n" ${function} ${duration}
  elif [ ${result} -eq 222 ]; then
    printf -- "--- SKIP: %s (%.2fs)\n" ${function} ${duration}
  else
    printf -- "--- FAIL: %s (%.2fs)\n" ${function} ${duration}
    test "${VERBOSE}" = "1" || cat ${log}
    printf "\terror code: %d\n\terror occured in ${IS_TTY:+\033[1;38;40m}%s${IS_TTY:+\033[m}\n" ${result} "${function}"
    let "failed_tests_cnt++"
    test "${function}" = "before_all" -o "$FAIL_FAST" = "1" && { after_all; exit 1; }
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
      printf "${IS_TTY:+\033[1;37;41m}failed expectation:${IS_TTY:+\033[m} ${IS_TTY:+\033[1;38;40m}${description} ${IS_TTY:+\033[m}\n"
      exit 1
    else
      printf "######################################## PASSED TEST: ${description} \n"
    fi
  ) || exit 1
}

