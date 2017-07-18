#lang racket

(require rackunit
         rackunit/text-ui
         "utils.rkt")

(define utils-tests
  (test-suite
   "Test for utils.rkt"

   (test-case
       "Can take a string, match its downcase to a regex"
     (check-not-false (matches-regex? "fool.+" "FooLish")))

  (test-case
      "Can remove parens and spaces"
    (check-equal? (kill-unwanted-strings "this (is)) annoying") "this-is-annoying"))))

(run-tests utils-tests)