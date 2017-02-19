#lang racket

(require db
         "utils.rkt")

(define (get-connection config)
  (mysql-connect #:server (hash-ref config 'server )
                 #:port 3306
                 #:database (hash-ref config 'database)
                 #:user (hash-ref config 'username)
                 #:password (hash-ref config 'password)))


(define usage
  "Arguments: <config-file> <query-file>")

(define (runner args)
  (let* ([config-file
          (vector-ref args 0)]
         [query-file
          (vector-ref args 1)]
         [conf (load-config config-file)]
         [conn (get-connection conf)]
         [query (file->string query-file)]
         [result (query-value conn query)])
    (print result)))

(define (main)
  (let ([cli-args
         (current-command-line-arguments)])
    (if (> 0 (vector-length cli-args))
        (println (usage))
        (runner cli-args))))

(main)
