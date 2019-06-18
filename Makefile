update-example-files:
	./tests.sh         > testreport.log
	- ./failing-tests.sh > failing-testreport.log
	which ${shell go env GOPATH}/bin/go-junit-report || go get -u github.com/jstemmer/go-junit-report
	cat testreport.log | ${shell go env GOPATH}/bin/go-junit-report > junit-report.xml
	cat failing-testreport.log | ${shell go env GOPATH}/bin/go-junit-report > junit-failing-report.xml

	./junit2html *.xml > example_output/testreport.html

	mv *.log *.xml example_output

