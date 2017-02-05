#lang racket

(require csv-reading)

(define usage
  (println "Arguments: <csv-file>"))

(define csv-reader
  (make-csv-reader-maker
   '((separator-chars            #\,)
     (strip-leading-whitespace?  . #t)
     (strip-trailing-whitespace? . #t))))

(define (next-row csv-filepath)
  (csv-reader (open-input-file csv-filepath)))

(define (rows csv-filepath)
  (csv->list (csv-reader (open-input-file csv-filepath))))

(define (print-rows rows)
  (for ([r rows])
    (println r)))

(define (runner args)
  (let* ([file-path
          (vector-ref args 0)]
         [rows (rows file-path)])
    (print-rows rows)))

(define (main)
  (let ([cli-args
         (current-command-line-arguments)])
    (if (> 1 (vector-length cli-args))
        (usage)
        (runner cli-args))))

(main)