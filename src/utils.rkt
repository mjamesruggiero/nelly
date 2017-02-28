#lang racket

(require racket/file)

(provide load-config
         matches-regex?)

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

(define (matches-regex? rx elem)
  (regexp-match? (regexp rx) (string-downcase elem)))
