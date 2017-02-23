#lang racket

(require rackunit
         racket/list
         rackunit/text-ui
         "csv.rkt")

(define test-row
  (list "Safari" "500" "25" "10" "0.6"))

(define test-csv
  "test.csv")

(define csv-tests
  (test-suite
   "Tests for csv.rkt"

   (test-case
       "Browser stat can be produced from row"
     (let ([expected-stat (browser-stat "Safari" 500 25 10 0.6)])
       (check-equal? (row->browser-stat test-row) expected-stat)))

   (test-case
       "Chart point can be generated from CSV row"
     (let ([expected-point (chart-point "Safari" "0.6")])
       (check-equal? (row->point test-row 0 4) expected-point)))

   (test-case
       "CSV can read rows into chart points"
     (let* ([expected-point (chart-point "Firefox" "0.2")]
            [label-col 0]
            [value-col 4]
            [points (csv->points test-csv label-col value-col)])
       (check-equal? (last points) expected-point)))))

(run-tests csv-tests)
