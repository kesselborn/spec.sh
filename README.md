# spec.sh

```
           _______..______    _______   ______        _______. __    __
          /       ||   _  \  |   ____| /      |      /       ||  |  |  |
         |   (----`|  |_)  | |  |__   |  ,----'     |   (----`|  |__|  |
          \   \    |   ___/  |   __|  |  |           \   \    |   __   |
      .----)   |   |  |      |  |____ |  `----.__.----)   |   |  |  |  |
      |_______/    | _|      |_______| \______(__)_______/    |__|  |__|
```

A mini sh test framework that produces `go test` compatible output.

# usage

The basic usage is as follows:

```bash
source spec.sh
include external-test.sh # include files implement tests

# all functions starting with 'it_' will be executed
it_should_pass() {
  assert_eq 0 0
  assert_eq "foo" "foo"
  assert_neq "x" "y"

  assert_true "ls /tmp"
  assert_false "ls /non-existant-dir"

  assert_match "hallo" "ll"
  assert_nmatch "hallo" "xx"
}

it_should_fail() {
  assert_true "ls /non-existant-dir"
}

run_tests
```

For all features, see (and execute) [tests.sh](./tests.sh) for passing tests and [failing-tests.sh](./failing-tests.sh) for failing tests

Have a look at [some sample output](#sample-output)

## options

  - `TESTS`: if you just want to execute some specific tests, set the `TESTS` env var to an [_extended_ regexp](https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html):

    ```bash
    # execute tests that match exactly "it_should_match_string" or match the substring "execute_external_tests"
    TESTS="(^it_should_match_string$|execute_external_tests)" ./tests.sh

    # execute all tests that contain the word "string" in their name
    TESTS="string" ./tests.sh
    ```

  - `INCLUDES`: if you include several test files but temporarily only want to execute tests from one (or more) specific files (works the same as TESTS)

  - `VERBOSE`: usually, test output is logged to a temporary file and only printed to `stdout` if an error occurred. If you want to have verbose output to `stdout`, set `VERBOSE`:

    ```bash
    VERBOSE=1 ./tests.sh
    ```

  - `FAIL_FAST`: set fail fast to exit immediately after the first test failed:

    ```bash
    FAIL_FAST=1 ./tests.sh
    ```

  - `NO_ANSI_COLOR`: don't add ansi color codes to output

    ```bash
    NO_ANSI_COLOR=1 ./tests.sh
    ```

  - `RERUN_FAILED_FROM`: run all tests which failed in the provided log file

    ```bash
    ./tests.sh > log1

    # rerun all tests that failed (don't redirect into the same log file -- this will rerun all tests)
    RERUN_FAILED_FROM=log1 ./tests.sh > log2
    ```

  - `SHARD`: runs only every nth test by using mod + offset logic (e.g. SHARD=2+1); in order to shard your tests in three runs, execute

    ```bash
    SHARD=3+0 ./tests.sh &   \
      SHARD=3+1 ./tests.sh & \
      SHARD=3+2 ./tests.sh & \
    ```

- `CONCURRENT`: run X tests concurrently in the same process (as opposed to using `SHARD`, which executes tests in separate processes)

  ```bash
  CONCURRENT=3 ./tests.sh  # always run 3 tests concurrently
  ```

  

# junit output

Running tests on a system that can consume junit output? Convert the test output to junit output follows:

```bash
./tests.sh         > testreport.log
./failing-tests.sh > failing-testreport.log

go get -u github.com/jstemmer/go-junit-report

cat testreport.log         | go-junit-report -package-name "passing-tests" > junit-report.xml
cat failing-testreport.log | go-junit-report -package-name 'failing-tests' > junit-failing-report.xml
```

no go installed but docker handy?

```bash
./tests.sh         > testreport.log
./failing-tests.sh > failing-testreport.log

docker run -v ${PWD}:${PWD} -w ${PWD} golang bash -xc "\
  go get -u github.com/jstemmer/go-junit-report && \
  cat testreport.log         | go-junit-report -package-name 'passing-tests' > junit-passing-report.xml && \
  cat failing-testreport.log | go-junit-report -package-name 'failing-tests' > junit-failing-report.xml"
```

# sample output

See [example_output](./example_output) directory for testing output (normal output + junit output)
