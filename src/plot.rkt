#lang racket

(require plot
         plot/no-gui)

(provide hist-file)

(define (hist-file series file-path)
  (plot
   (list
    (discrete-histogram series))
   #:out-file file-path))
