#lang racket

(require racket/tcp)

(define (serve port-no)
  (define listener (tcp-listen port-no 5 #t))
  (define (loop)
    (accept-and-handle listener)
    (loop))
  (define t (thread loop))
  (lambda ()
    (kill-thread t)
    (tcp-close listener)))


(define (accept-and-handle listener)
  (define-values (in out) (tcp-accept listener))
  (handle in out)
  (close-input-port in)
  (close-output-port out))

(define (handle in out)
  ;; discard request header (up to blank line)
  (print in)
  (regexp-match #rx"(\r\n|^)\r\n" in)
  ;; send reply
  (display "HTTP/1.0 200 Okay\r\n" out)
  (display "Server: k\r\nContent-type: text/html\r\n\r\n" out)
  (display "<html><body>Hello, world!</body></html>" out))

;; (define stop
;;   (serve 8081))

;; (stop)
