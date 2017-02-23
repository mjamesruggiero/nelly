#lang racket

(require csv-reading
         racket/match
         racket/file
         plot
         plot/no-gui)

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;     csvs
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

(struct chart-point
  (label value) #:transparent)

(define (row->point row label-index value-index)
  (let ([l (list-ref row label-index)]
        [v (list-ref row value-index)])
    (chart-point l v)))

(define (csv->points csv label-column value-column)
  (let ([without-header (cdr (rows csv))])
    (for/list ([r without-header])
      (row->point r label-column value-column))))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;     charts
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define (time-series-bars list label title)
  (plot
   (discrete-histogram list
                       #:label label
                       #:color 2 #:line-color 2)
   #:title title))
