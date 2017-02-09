#lang racket

(require csv-reading
         racket/match
         plot
         plot/no-gui)

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
  (csv->list (csv-reader
              (open-input-file csv-filepath))))

(define (print-rows rows)
  (let ([skpping-header (cdr rows)])
    (for ([r skpping-header])
      (println (row->browser-stat r)))))

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

(struct browser-stat
  (browser
   total-requests
   cookies
   dsp-matched
   coverage-rate) #:transparent)

(define (row->browser-stat row)
  (let* ([browser (car row)]
         [nums (map string->number (cdr row))])
    (match nums
      [(list req cookies matched rate)
       (browser-stat browser req cookies matched rate)])))

(define test-list
  (list
   #("08-Feb" 1)
   #("07-Feb" 3)
   #("06-Feb" 9)
   #("05-Feb" 6)
   #("04-Feb" 6)
   #("03-Feb" 6)
   #("02-Feb" 6)))

(define time-series-bars (list label title)
  (plot
   (discrete-histogram list
                       #:label "Fake values"
                       #:color 2 #:line-color 2)
   #:title title))
