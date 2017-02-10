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

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;     charts
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define (time-series-bars list label title)
  (plot
   (discrete-histogram list
                       #:label label
                       #:color 2 #:line-color 2)
   #:title title))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;     commands
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define usage
  "Arguments: <csv-file>")

(define (runner args)
  (let* ([file-path
          (vector-ref args 0)]
         [conf (load-config file-path)])
    (println conf)))

(define (main)
  (let ([cli-args
         (current-command-line-arguments)])
    (if (> 0 (vector-length cli-args))
        (println (usage))
        (runner cli-args))))

(define (load-config config-path)
  (let [(eval-ns  (make-base-namespace))
        (params   (make-hash))]
    (let [(settings (file->list config-path))]
      (for [(name:value settings)]
        (let* [; extract the 'name' symbol
               (n (car name:value))
               ; evaluate the 'value' expression
               (v (cdr name:value))
               (v (eval (quasiquote (,@v)) eval-ns))]
          (hash-set! params n v))))
    params))

(main)
