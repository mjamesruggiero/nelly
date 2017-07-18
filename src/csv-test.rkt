#lang racket

(require rackunit
         racket/list
         racket/function
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
       "Chart point can be generated from CSV row"
     (let ([expected-point (chart-point "Safari" 0.6)])
       (check-equal? (row->point test-row 0 4) expected-point)))

   (test-case
       "Can read rows into chart points"
     (let* ([expected-point (chart-point "Firefox" 0.2)]
            [label-col 0]
            [value-col 4]
            [points (csv->points label-col value-col test-csv)])
       (check-equal? (last points) expected-point)))))

(run-tests csv-tests)