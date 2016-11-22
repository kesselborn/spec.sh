update-example-files:
	NO_ANSI_COLOR=1 ./tests.sh         > testreport.log
	-NO_ANSI_COLOR=1 ./failing-tests.sh > failing-testreport.log
	go get -u github.com/jstemmer/go-junit-report
	cat testreport.log         | go-junit-report > junit-report.xml
	cat failing-testreport.log | go-junit-report > junit-failing-report.xml

	mv *.log *.xml example_output

