#lang racket

(require csv-reading
         racket/match
         racket/file
         plot
         plot/no-gui)

(provide chart-point
         csv->points
         rows
         row->point)


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

(struct chart-point
  (label value) #:transparent)

(define (row->point row label-index value-index)
  (let ([l (list-ref row label-index)]
        [v (string->number (list-ref row value-index))])
    (chart-point l v)))

(define (csv->points label-column value-column csv)
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
