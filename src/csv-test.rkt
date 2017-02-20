#lang racket

(require rackunit
         "csv.rkt")

(test-begin
  (let ([row (list "Safari" "500" "25" "10" "0.6")]
        [expected (browser-stat "Safari" 500 25 10 0.6)])
    (check-equal? (row->browser-stat row) expected)))
