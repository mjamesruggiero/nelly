#lang racket

(require rackunit
         rackunit/text-ui
         "csv.rkt")

(define test-row
  (list "Safari" "500" "25" "10" "0.6"))

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
       (check-equal? (row->chart-point test-row 0 4) expected-point)))))

(run-tests csv-tests)
