JSON_FILES=$(wildcard /tmp/*.json)
CSV_FILES=$(wildcard /tmp/*.csv)

test:
	@raco test src/csv-test.rkt
	@raco test src/utils-test.rkt

list:
	@awk -F: '/^[A-z]/ {print $$1}' Makefile

.PHONY : clean
clean:
		@rm -f $(JSON_FILES)
		@rm -f $(CSV_FILES)
