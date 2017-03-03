#lang racket

(require racket/string
         "csv.rkt"
         "plot.rkt")

(define (usage)
  "amazon.rkt <CSV-FILEPATH>")

(define (amazon-rows filepath)
  (let* ([rws (rows filepath)]
         [header (get-repaired-header (car rws))])
    (printf (format "Header is ~a\n" header))))

(define (runner args)
  (printf (format "You passed args: ~a\n" args))
  (amazon-rows (vector-ref args 0)))

(define (main)
  (let ([cli-args
         (current-command-line-arguments)])
    (if (< 2 (vector-length cli-args))
        (usage)
        (runner cli-args))))

(main)
