# spec.sh

A mini sh test framework that produces `go test` compatible output.

# usage

The basic usage is as follows:

    source spec.sh
    include external-test.sh # include files implement tests

    # all functions starting with 'it_' will be executed
    it_should_pass() {
      assert 0 0
    }

    it_should_fail() {
      assert "ls /non-existant-dir"
    }

    run_tests

For all features, see (and execute) [tests.sh](./tests.sh) for passing tests and [failing-tests.sh](./failing-tests.sh) for failing tests

## options

  - `TESTS`: if you just want to execute some specific tests, set the `TESTS` env var to an [_extended_ regexp](https://www.gnu.org/software/sed/manual/html_node/Extended-regexps.html):

        # execute tests that match exactly "it_should_match_string" or match the substring "execute_external_tests"
        TESTS="(^it_should_match_string$|execute_external_tests)" ./tests.sh

        # execute all tests that contain the word "string" in their name
        TESTS="string" ./tests.sh

  - `INCLUDES`: if you include several test files but temporarily only want to execute tests from one (or more) specific files (works the same as TESTS)

  - `VERBOSE`: usually, test output is logged to a temporary file and only printed to `stdout` if an error occurred. If you want to have verbose output to `stdout`, set `VERBOSE`:

        VERBOSE=1 ./tests.sh

  - `FAIL_FAST`: set fail fast to exit immediately after the first test failed:

        FAIL_FAST=1 ./tests.sh

  - `NO_ANSI_COLOR`: don't add ansi color codes to output

        NO_ANSI_COLOR=1 ./tests.sh


# junit output

Running tests on a system that can consume junit output? Convert the test output to junit output follows:

    ./tests.sh         > testreport.log
    ./failing-tests.sh > failing-testreport.log

    go get -u github.com/jstemmer/go-junit-report

    cat testreport.log         | go-junit-report -package-name "passing-tests" > junit-report.xml
    cat failing-testreport.log | go-junit-report -package-name 'failing-tests' > junit-failing-report.xml

no go installed but docker handy?

    ./tests.sh         > testreport.log
    ./failing-tests.sh > failing-testreport.log

    docker run -v ${PWD}:${PWD} -w ${PWD} golang bash -xc "\
      go get -u github.com/jstemmer/go-junit-report && \
      cat testreport.log         | go-junit-report -package-name 'passing-tests' > junit-passing-report.xml && \
      cat failing-testreport.log | go-junit-report -package-name 'failing-tests' > junit-failing-report.xml"

# sample output

See [example_output](./example_output) directory for testing output (normal output + junit output)

