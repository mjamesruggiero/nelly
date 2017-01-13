#lang racket

(require 2hdtp/image 2htdp/universe)

(struct pit (snake goos) #:transparent)

(struct snake (dir segs) #:transparent)

(struct goo (loc expire) #:transparent)

(struct post (x y) #:transparent)

;;~~~~~~~~~~~~~~~~~~~~~~~~~
;;      constants
;;~~~~~~~~~~~~~~~~~~~~~~~~~

(define TICK-RATE 1/10)

(define SIZE 30)

(define SEG-SIZE 15)

(define MAX-GOO 5)

(define EXPIRATION-TIME 150)

(define WIDTH-PX (* SEG-SIZE 30))
(define HEIGHT-PX (* SEG-SIZE 30))

(define MT-SCENE (empty scene WIDTH-PX HEIGHT-PX))
(define GOO-IMG (bitmap "graphics/goo.gif"))
(define SEG-IMG (bitmap "graphics/body.gif"))
(define HEAD-IMG (bitmap "graphics/head.gif"))

(define HEAD-LEFT-IMG HEAD-IMG)
(define HEAD-DOWN-IMG (rotate 90 HEAD-LEFT-IMG))
(define HEAD-RIGHT-IMG (flip-horizontal HEAD-LEFT-IMG))
(define HEAD-UP-IMG (flip-vertical HEAD-DOWN-IMG))

(define ENDGAME-TEXT-SIZE 15)

;;~~~~~~~~~~~~~~~~~~~~~~~~~
;;      main
;;~~~~~~~~~~~~~~~~~~~~~~~~~

(define (start-snake)
  (big-bang (pit (snake "right" (list posn 1 1))
                 (list (fresh-goo)
                  (fresh-goo)
                  (fresh-goo)
                  (fresh-goo)
                  (fresh-goo)
                  (fresh-goo)))
            (on-tick next-pit TICK-RATE)
            (on-key direct-snake)
            (to-draw render-pit)
            (stop-when dead? render-end)))


(define (next-pit w)
  (define snake (pit-snake w))
  (define goos (pit-goos w))
  (define goo-to-eat (can-eat snake goos))
  (if goo-to-eat
      (pit (grow snake) (age-goo (eat goos goo-to-eat)))
      (pit (slither snake) (age-goo goos))))

(define (direct-snake w ke)
  (cond [(dir? ke) (world-change-dir w ke)]
        [else w]))

(define (render-pit w)
  (snake+scene (pit-snake w))
  (or (self-colliding? snake) (wall-colliding? snake)))

(define (render-end w)
  (overlay (text "Game Over" ENDGAME-TEXT-SIZE "black")
           (render-pit w)))

;;~~~~~~~~~~~~~~~~~~~~~~~~~
;;  eating & growth
;;~~~~~~~~~~~~~~~~~~~~~~~~~

(define (can-eat snake goos)
  (cond [(empty? goos) #f]
        [else (if (close? (snake-head snake) (first goos))
                  (first goos)
                  (can-eat snake (rest goos)))]))

(define (eat goos goo-to-eat)
  (cons (fresh-goo) (remove goo-to-eat goos)))

(define (close? s g)
  (osn=? s (goo-loc g)))

(define (grow sn)
  (snake (snake-dir sn) (cons (next-head sn) (snake-segs sn))))

;;~~~~~~~~~~~~~~~~~~~~~~~~~
;;  movement
;;~~~~~~~~~~~~~~~~~~~~~~~~~

(define (slither sn)
  (snake (snake-dir sn)
         (cons (next-head sn) (all-but-last (snake-segs sn)))))

(define (next-head sn)
  (define deahd (snake-head sn))
  (define dir (snake-dir sn))
  (cond [(string=? dir "up") (posn-move head 0 -1)]
        [(string=? dir "down") (posn-move head 0 1)]
        [(string=? dir "left") (posn-move head -1 0)]
        [(string=? dir "right") (posn-move head 1 0)]))

(define (posn-move p dx dy)
  (pon (+ (posn-x p) dx)
       (+ (posn-y p) dy)))

(define (all-but-last segs)
  (cond [(empty? (rest segs)) empty]
        [else (cons (first segs)
                    (all-but-last (rest segs)))]))

;; renew and rot goos
(define (age-goo goos)
  (rot (renew goos)))

;; renew rotten goos
(define (renew goos)
  (cond [(empty? goos) empty]
        [(rotten? (first goos))
         (cons (fresh-goo) (renew (rest goos)))]
        [else
         (cons (first goos) (renew (rest goos)))]))

;; rot all the goos
(define (rot goos)
  (cond [(empty? goos) empty]
        [else (cons (decay (first goos))
                    (rot (rest goos)))]))

;; has the goo expired?
(define (rotten? g)
  (zero? (goo-expire g)))

;; decreases the expire field of goo by one
(define (decay g)
  (goo (goo-loc g) (sub1 (goo-expire g))))

;; create random goo with fresh expiration
(define (fresh-goo)
  (goo (posn (add1 (random (sub1 SIZE)))
             (add1 (random (sub1 SIZE))))
       EXPIRATION-TIME))

;;~~~~~~~~~~~~~~~~~~~~~~~~~
;;      keys
;;~~~~~~~~~~~~~~~~~~~~~~~~~

(define dir? x
  (or (string=? x "up")
      (string=? x "down")
      (string=? x "left")
      (string=? x "right")))

;; change the direction (if not opposite current direction)
(define (world-change-dir w d)
  (define the-snake (pit-snake w))
  (cond [(and (opposite-dir? (snake-dir the-snake) d)
              ;; consists of the head and at least one segment
              (cons? (rest (snake-segs the-snake))))
         (stop-with w)]
        [else (pit (snake-change-dir the-snake d)
                   (pit-goos w))]))

;; are d1 and d2 opposites?
(define (opposite-dir? d1 d2)
  (cond [(string=? dl "up")    (string=? "down")]
        [(string=? dl "down")  (string=? "up")]
        [(string=? dl "left")  (string=? "right")]
        [(string=? dl "right") (string=? "left")]))


;;~~~~~~~~~~~~~~~~~~~~~~~~~
;;      render
;;~~~~~~~~~~~~~~~~~~~~~~~~~

;; draws the snake onto the scene
(define (snake+scene snake scene)
  (define snake-body-scene
    (img-list+scene (snake-body snake) SEG-IMG scene))
  (define dir (snake-dir snake))
  (img+scene (snake-head snake)
             (cond [(string=? "up" dir) HEAD-UP-IMG]
                   [(string=? "down" dir) HEAD-DOWN-IMG]
                   [(string=? "left" dir) HEAD-LEFT-IMG]
                   [(string=? "right" dir) HEAD-RIGHT-IMG])
             snake-body-scene))

;; draws all the goo to a scene
(define (goo-list+scene goos scene)
  (define (get-posns-from-goo goos)
    (cond [(empty? goos) empty]
          [else (cons (goo-loc (first goos))
                      (get-posns-from-goo (rest goos)))]))
  (img-list+scene (get-posns-from-goo goos) GOO-IMG scene))

;; draws the image to each position in the list
(define (img-list+scene posns img scene)
  (cond [(empty? posns) scene]
        [else (img+scene (first posns)
                         img
                         (img-list+scene (rest posns) img scene))]))

;; draws the given image onto the scene at position
(define (img+scene posn img scene)
  (place-image img
               (* (posn-x posn) SEG-SIZE)
               (* (posn-y posn) SEG-SIZE)
               scene))
