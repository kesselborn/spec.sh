# spec.sh

A mini sh test framework that produces `go test` compatible output.

# usage

See and execute [tests.sh](./tests.sh) for passing tests and [failing-tests.sh](./failing-tests.sh) for failing tests

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

