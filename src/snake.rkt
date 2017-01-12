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
