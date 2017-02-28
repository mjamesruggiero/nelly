#lang racket

(require rackunit
         rackunit/text-ui
         "utils.rkt")

(define utils-tests
  (test-suite
   "Test for utils.rkt"

   (test-case
       "Can take a string, match its downcase to a regex"
       (check-not-false (matches-regex? "fool.+" "FooLish")))))

(run-tests utils-tests)
