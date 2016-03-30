# Copyright (C) 2015-2016 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.


# This is a mini bash test framework that outputs the test like go test does
# For usage see files tests.sh and failing-tests.sh and execute them to see
# bashspec in action

function run_test() {
  local function=$1

  echo "=== RUN ${function}"
  local start=$(date "+%s")
  (
    exec > /tmp/${function}.testlog 2>&1
    set -x
    ${function}
  )
  result=$?

  if [ ${result} -eq 0 ]
  then
    printf -- "--- PASS: %s (%.2fs)\n" ${function} $(( $(date "+%s") - ${start} ))
  elif [ ${result} -eq 255 ]
  then
    printf -- "--- SKIP: %s (%.2fs)\n" ${function} $(( $(date "+%s") - ${start} ))
  else
    printf -- "--- FAIL: %s (%.2fs)\n" ${function} $(( $(date "+%s") - ${start} ))
    cat /tmp/${function}.testlog | sed 's/^/	/g'
    printf "\terror code: %d\n" ${result}
    echo "error occured in ${function}"
    compgen -A function | grep -o after_all && after_all
  fi
}

function SKIP_TEST() {
  exit 255
}

function assert~() {
  echo $1 | grep -E -m1 -o "$2" | head -n1 | grep -E "$2"
  assert 0 $? "checking '$1' to match '$2'"
}

function assert() {
  result=$1
  expected=$2
  description=$3

  # we just want a command to succeed
  if [ -z "${expected}" ]
  then
    ${result}
    result=$?
    expected=0
    description="expecting command '$1' to succeed"
  fi

  if [ "${result}" != "${expected}" ]
  then
    if [ -n "${description}" ]
    then
      echo -e "\033[1;38;40m${description}\033[m"
    fi
    echo -e "error: in test ${current_test} \033[1;38;40mexpected '${result}' to be '${expected}'\033[m"
    exit 1
  else
    set +x
    echo "######################################## PASSED TEST: ${description:-${result} == ${expected}} "
    set -x
  fi
}

function run_tests() {
  # call setup function if present
  function_list=$(compgen -A function | grep -o before_all)

  # add all functions starting with 'it_' to  the function list
  function_list="${function_list} $(compgen -A function | grep "^it_" | grep "${TESTS:-.}")"

  # call tear down function if present
  function_list="${function_list} $(compgen -A function | grep -o after_all)"

  for f in ${function_list}
  do
    current_test=$f
    run_test $f
  done
}
