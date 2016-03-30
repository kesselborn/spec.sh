# bashspec

A mini bash test framework that uses go test output

# usage

See and execute [tests.sh](./tests.sh) for passing tests and [failing-tests.sh](./failing-tests.sh) for failing tests

# junit output

Running tests on a system that can consume junit output? Convert the test output to junit output follows:

    ./tests.sh | tee testreport.log
    ./failing-tests.sh | tee failing-testreport.log
    go get -u github.com/jstemmer/go-junit-report
    cat testreport.log | go-junit-report -package-name "my-package" > junit-report.xml

no go installed but docker handy?

    ./tests.sh | tee testreport.log
    ./failing-tests.sh | tee failing-testreport.log
    docker run -v ${PWD}:${PWD} -w ${PWD} golang bash -xc "\
      go get -u github.com/jstemmer/go-junit-report && \
      cat testreport.log | go-junit-report -package-name 'my-package' > junit-passing-report.xml && \
      cat failing-testreport.log | go-junit-report -package-name 'failing-tests' > junit-failing-report.xml"


