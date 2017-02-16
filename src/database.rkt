#lang racket

(require db
         "utils.rkt")

(define (get-connection config)
  (mysql-connect #:server (hash-ref config 'server )
                 #:port 3306
                 #:database (hash-ref config 'database)
                 #:user (hash-ref config 'username)
                 #:password (hash-ref config 'password)))


(define (read-query path)
  (file->string path))

(define (get-query config)
  (read-query
   (hash-ref config 'query-file)))

(define usage
  "Arguments: <config-file> <query-file>")

(define (test-runner args)
  (let* (
         [config-file-path (vector-ref args 0)]
         [query-file-path (vector-ref args 1)]
         [conf (load-config config-file-path)]
         [query (read-query query-file-path)]
         [result (string-append "we would have run this query: " query)])
    (print result)))

(define (runner args)
  (let* ([file-path
          (vector-ref args 0)]
         [conf (load-config file-path)]
         [conn (get-connection conf)]
         [query (get-query conf)]
         [result (query-value conn query)])
    (print result)))

(define (main)
  (let ([cli-args
         (current-command-line-arguments)])
    (if (> 0 (vector-length cli-args))
        (println (usage))
        (test-runner cli-args))))

(main)
