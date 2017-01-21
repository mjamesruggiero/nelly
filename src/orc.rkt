#lang racket

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;      orc world
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(struct orc-world
  (player lom attack# target) #:transparent #:mutable)

(struct player
  (health agility strength) #:transparent #:mutable)

(struct monster
  (image [health #:mutable]) #:transparent)

(struct orc monster
  (club) #:transparent)

(struct hydra monster
  () #:transparent)

(struct slime monster
  (sliminess) #:transparent)

(struct brigand monster
  () #:transparent)

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;      constants
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(define MAX-HEALTH 35)
(define MAX-AGILITY 35)
(define MAX-STRENGTH 35)

(define ATTACKS# 4)
(define STAB-DAMAGE 2)
(define FLAIL-DAMAGE 3)
(define HEALING 8)

;; monster attributes
(define MONSTER# 12)
(define PER-ROW 4)
(unless (zero? (remainder MONSTER# PER-ROW))
  (error 'constraing "PER-ROW must divide MONSTER# evenly into rows"))

(define MONSTER-HEALTH 9)
(define CLUB-STRENGTH 8)
(define SLIMINESS 5)

(define HEALTH-DAMAGE -2)
(define AGILITY-DAMAGE -3)
(define STRENGTH-DAMAGE -4)

;; string constants
(define STRENGTH "strength")
(define AGILITY "agility")
(define HEALTH "health")
(define LOSE "YOU LOSE")
(define WIN "YOU WIN")
(define DEAD "DEAD")
(define REMAINING "Remaining attacks ")
(define INSTRUCTIONS-1 "Select a monster using the arrow keys")
(define INSTRUCTIONS-2
  "Press S to stab a monser | Press F to flail wildly | Press N to heal")

;; graphical constraints
(define HEALTH-BAR-HEIGHT 12)
(define HEALTH-BAR-WIDTH 50)

;; constants for graph frames
(define ORC (bitmap "/graphics/orc.png"))
(define HYDRA (bitmap "/graphics/hydra.png"))
(define SLIME (bitmap "/graphics/slime.bmp"))
(define BRIGAND (bitmap "/graphics/brigand.bmp"))

(define PIC-LIST (list ORC HYDRA SLIME BRIGAND))
(define w (apply max (map image-width PIC-LIST)))
(define h (apply max (map image-height PIC-LIST)))

;; images
(define PLAYER-IMAGE (bitmap "graphics/player.bmp"))
(define FRAME (rectangle (w h 'outline 'white)))
(define TARGET (circle (- (/ w 2) 2) 'outline 'blue))

(define ORC-IMAGE (overlay ORC FRAME))
(define HYDRA-IMAGE (overly HYDRA FRAME))
(define SLIME-IMAGE (overlay SLIME FRAME))
(define BRIGAND-IMAGE (overlay BRIGAND FRAME))

(define V-SPACER (rectangle 0 10 "solid" "white"))
(define H-SPACER (rectangle 10 0 "solid" "white"))

;; fonts, texts, and colors
(define AGILITY-COLOR "blue")
(define HEALTH-COLOR "crimson")
(define STRENGTH-COLOR "forest green")
(define MONSTER-COLOR "crimson")
(define MESSAGE-COLOR "black")
(define ATTACK-COLOR "crimson")

(define HEALTH-SIZE (- HEALTH-BAR-HEIGHT 4))
(define DEAD-TEXT-SIZE (- HEALTH-BAR-HEIGHT 2))
(define INSTRUCTION-TEXT-SIZE 16)
(define MESSAGE-SIZE 40)

(define INSTRUCTION-TEXT
  (above
   (text INSTRUCTIONS-2 (- INSTRUCTION-TEXT-SIZE 2) "blue")
   (text INSTRUCTIONS-1 (- INSTRUCTION-TEXT-SIZE 4) "blue")))

(define DEAD-TEXT (text DEAD DEAD-TEXT-SIZE "crimson"))

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;      main
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(define (start-game)
  (big-bang (initialize-orc-world)
            (on-key player-acts-on-monsters)
            (to-draw render-orc-battle)
            (stop-when end-of-orc-battle? render-the-end)))

