#lang racket

(require json)

;; id
;; incident_number
;; summary
;; service.name
(struct incident
  (id number summary service created-at status priority) #:transparent)

(define (incident-node->incident i)
  (let*
      ([incident-number (hash-ref i'incident_number)]
       [id (hash-ref i'id)]
       [summary (hash-ref i 'summary)]
       [service (hash-ref (hash-ref i 'service) 'summary)]
       [created-at (hash-ref i 'created_at)]
       [status (hash-ref i 'status)]
       [priority (hash-ref (hash-ref i 'priority) 'summary)])
    (incident id incident-number summary service created-at status priority)))

(module+ test
  (require rackunit rackunit/text-ui)

  (define TEST-FILE
    "incidents.json")

  (define PAYLOAD
    (call-with-input-file TEST-FILE read-json))

  (define INCIDENTS
    (hash-ref PAYLOAD 'incidents))

  (define PARSED
    (map incident-node->incident INCIDENTS))

  (check-equal? (car PARSED)
                (incident "PT4KHLK"
                          1234
                          "[#1234] The server is on fire."
                          "My Mail Service"
                          "2015-10-06T21:30:42Z"
                          "resolved"
                          "P2"))

  (check-equal? (length PARSED) 1))
