#lang racket

(require racket/string
         "csv.rkt"
         "plot.rkt"
         "utils.rkt")

(define (usage)
  "amazon.rkt <CSV-FILEPATH>")

(define (fix-header hdr)
  (map
   (lambda (s)
     (kill-unwanted-strings s))
   hdr))

(define (amazon-rows filepath)
  (let* ([rws (rows filepath)]
         [header (fix-header (car rws))])
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
