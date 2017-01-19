#lang racket

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

(define MAX-HEALTH 35)
(define MAX-AGILITY 35)
(define MAX-STRENGTH 35)

(define ATTACKS# 4)
(define STAB-DAMAGE 2)
(define FLAIL-DAMAGE 3)
(define HEALING 8)
