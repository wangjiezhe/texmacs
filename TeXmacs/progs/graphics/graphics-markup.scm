
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : graphics-markup.scm
;; DESCRIPTION : extra graphical macros
;; COPYRIGHT   : (C) 2012  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (graphics graphics-markup)
  (:use (graphics graphics-drd)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of graphical macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (ca*r x) (if (pair? x) (ca*r (car x)) x))

(tm-define-macro (define-graphics head . l)
  (receive (opts body) (list-break l not-define-option?)
    `(begin
       (set! gr-tags-user (cons ',(ca*r head) gr-tags-user))
       (tm-define ,head ,@opts (:secure #t) ,@body))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Useful subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (tm-point? p) (tm-func? p 'point 2))
(tm-define (tm-x p) (tm-ref p 0))
(tm-define (tm-y p) (tm-ref p 1))

(tm-define (tm->number t)
  (if (tm-atomic? t) (string->number (tm->string t)) 0))

(tm-define (number->tm x)
  (number->string x))

(tm-define (point->complex p)
  (make-rectangular (tm->number (tm-x p)) (tm->number (tm-y p))))

(tm-define (complex->point z)
  `(point ,(number->tm (real-part z)) ,(number->tm (imag-part z))))

(tm-define (graphics-transform fun g)
  (cond ((tm-point? g) (fun g))
        ((tm-atomic? g) g)
        (else (cons (tm-car g)
                    (map (cut graphics-transform fun <>)
                         (tm-children g))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-graphics (rectangle P1 P2)
  (let* ((p1 (if (tm-point? P1) P1 '(point "0" "0")))
         (p2 (if (tm-point? P2) P2 p1)))
    `(cline ,p1 (point ,(tm-x p2) ,(tm-y p1))
            ,p2 (point ,(tm-x p1) ,(tm-y p2)))))

(define-graphics (circle C P)
  (let* ((c  (if (tm-point? C) C '(point "0" "0")))
         (p  (if (tm-point? P) P c))
         (cx (tm-x c)) (cy (tm-y c))
         (px (tm-x p)) (py (tm-y p))
         (dx `(minus ,px ,cx)) (dy `(minus ,py ,cy))
         (q1 `(point (minus ,cx ,dx) (minus ,cy ,dy)))
         (q2 `(point (minus ,cx ,dy) (plus ,cy ,dx))))
    `(superpose (with "point-style" "none" ,c) (carc ,p ,q1 ,q2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electrical diagrams
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ((rescale z0 dz) p)
  (complex->point (+ z0 (* dz (point->complex p)))))

(tm-define (electrical im scale p1 p2 p3)
  (let* ((z1 (if (tm-point? p1) (point->complex p1) 0))
         (z2 (if (tm-point? p2) (point->complex p2) z1))
         (z3 (if (tm-point? p3) (point->complex p3) z2))
         (dz (- z2 z1))
         (l  (magnitude dz))
         (d1 (if (= dz 0) 0 (abs (* l (imag-part (/ (- z3 z1) dz))))))
         (d2 (/ (min l (/ d1 scale)) 2))
         (u  (if (= dz 0) 0 (* d2 (/ dz l))))
         (vm (/ (+ z1 z2) 2))
         (v1 (- vm u))
         (v2 (+ vm u))
         (rescaler (rescale v1 (- v2 v1))))
    `(superpose
      (line ,p1 ,(complex->point v1))
      ,(graphics-transform rescaler im)
      (line ,(complex->point v2) ,p2)
      (with "point-style" "none" ,p3))))

(define (std-condensator)
  `(superpose
     (line (point "0" "-2") (point "0" "2"))
     (line (point "1" "-2") (point "1" "2"))))

(define-graphics (condensator p1 p2 p3)
  (electrical (std-condensator) 2 p1 p2 p3))

(define (std-diode)
  `(superpose
     (cline (point "0" "-0.5") (point "1" "0") (point "0" "0.5"))
     (line (point "1" "-0.5") (point "1" "0.5"))))

(define-graphics (diode p1 p2 p3)
  (electrical (std-diode) 0.5 p1 p2 p3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Triangle with text inside
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (graphics-incomplete? obj)
  (:require (tm-is? obj 'triangle-with-text))
  ;;(display* "incomplete? " obj " -> " (< (tm-arity obj) 3) "\n")
  (< (tm-arity obj) 3))

(tm-define (graphics-complete? obj)
  (:require (tm-is? obj 'triangle-with-text))
  ;;(display* "complete? " obj " -> " (>= (tm-arity obj) 3) "\n")
  (>= (tm-arity obj) 3))

(tm-define (graphics-complete obj)
  (:require (tm-is? obj 'triangle-with-text))
  (if (> (tm-arity obj) 3)
      (list obj #f)
      (list (append obj (list '(text-at "?" (point "0" "0")))) (list 3 2 0))))

(define-graphics (triangle-with-text P1 P2 P3 T)
  ;;(display* "twt " P1 ", " P2 ", " P3 ", " T "\n")
  (let* ((p1 (if (tm-point? P1) P1 '(point "0" "0")))
         (p2 (if (tm-point? P2) P2 p1))
         (p3 (if (tm-point? P3) P3 p2))
         (t  (if (tm-is? T 'uninit) '(text-at "?" (point "0" "0")) T))
         (z1 (point->complex p1))
         (z2 (point->complex p2))
         (z3 (point->complex p3))
         (p  (complex->point (/ (+ z1 z2 z3) 3))))
    `(superpose
       (cline ,p1 ,p2 ,p3)
       (with "text-at-halign" "center" "text-at-valign" "center"
         (text-at ,(tm-ref t 0) ,p)))))
