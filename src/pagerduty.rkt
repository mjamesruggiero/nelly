#lang racket

(require json)

(struct incident
  (id
   number
   summary
   service
   created-at
   status
   priority) #:transparent)

(define (incident-node->incident i)
  (let*
      ([number (hash-ref i'incident_number)]
       [id (hash-ref i'id)]
       [summary (hash-ref i 'summary)]
       [service (hash-ref (hash-ref i 'service) 'summary)]
       [created-at (hash-ref i 'created_at)]
       [status (hash-ref i 'status)]
       [priority (hash-ref (hash-ref i 'priority) 'summary)])
    (incident id
              number
              summary
              service
              created-at
              status
              priority)))

(struct log-entry
  (type
   created-at))

(define (get-type entry)
  (case (log-entry-type entry)
  [("trigger_log_entry") 'log-entry]
  [("resolve_log_entry") 'resolution]
  [else 'other]))

(module+ test
  (require rackunit rackunit/text-ui)

  ;; incidents can be parsed
  (define TEST-INCIDENTS-FILE
    "incidents.json")

  (define INCIDENTS-PAYLOAD
    (call-with-input-file TEST-INCIDENTS-FILE read-json))

  (define INCIDENTS
    (hash-ref INCIDENTS-PAYLOAD 'incidents))

  (define INCIDENTS-PARSED
    (map incident-node->incident INCIDENTS))

  (check-equal? (car INCIDENTS-PARSED)
                (incident "PT4KHLK"
                          1234
                          "[#1234] The server is on fire."
                          "My Mail Service"
                          "2015-10-06T21:30:42Z"
                          "resolved"
                          "P2"))

  (check-equal? (length INCIDENTS-PARSED) 1)

  ;; log entries can be parsed
  (define TEST-LOG-ENTRIES-FILE
    "log-entries.json")

  (define LOG-ENTRIES-PAYLOAD
    (call-with-input-file TEST-LOG-ENTRIES-FILE read-json))


  ;; can map log entries to types
  (check-equal? (get-type (log-entry
                           "trigger_log_entry"
                           "2015-10-06T21:30:42Z"))
                'log-entry)

  (check-equal? (get-type (log-entry
                           "resolve_log_entry"
                           "2015-10-06T21:30:42Z"))
                'resolution)

  (check-equal? (get-type (log-entry
                           "unknown"
                           "2015-10-06T21:30:42Z"))
                'other)
  )
