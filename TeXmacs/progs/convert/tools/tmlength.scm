
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : tmlength.scm
;; DESCRIPTION : manipulation of texmacs length values
;; COPYRIGHT   : (C) 2002  David Allouche
;;
;; This software falls under the GNU general public license and comes WITHOUT
;; ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (convert tools tmlength)
  (:export
    tmlength tmlength-null? tmlength?
    tmlength-value tmlength-unit tmlength-value+unit
    string->tmlength tmlength->string))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Length components.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(drd-group tmlength-units%
  unit cm mm in pt spc spc- spc+ fn fn- fn+ fn* fn*- fn*+ ln sep px par pag)

(define (tmlength-unit? x)
  (drd-in? x tmlength-units%))

(define tmlength-value? number?)

(define (tmlength-check-value x)
  (if (not (tmlength-value? x))
      (error "bad length value:" x)))

(define (tmlength-check-unit x)
  (if (not (tmlength-unit? x))
      (error "bad length unit:" x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic length
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define tmlength
  ;; (:type ... how to write that?
  (:synopsis "Create a tmlength object given its value and unit components.")
  (case-lambda
    (() '())
    ((n unit)
     (tmlength-check-value n)
     (tmlength-check-unit unit)
     (list n unit))))

(tm-define (tmlength-null? x)
  (:type (forall T (-> T bool)))
  (:synopsis "Is @x a null tmlength (zero value, unspecified unit)?")
  (null? x))

(tm-define (tmlength? x)
  (:type (forall T (-> T bool)))
  (:synopsis "Is @x a, possible null, tmlength?")
  (or (tmlength-null? x)
      (and (list? x) (= 2 (length x))
	   (tmlength-value? (first x)) (tmlength-unit? (second x)))))

(tm-define (tmlength-value tmlen)
  (:type (-> tmlength number))
  (:synopsis "Get the value part of @tmlen.")
  (if (tmlength-null? tmlen) 0 (first tmlen)))

(tm-define (tmlength-unit tmlen)
  (:type (-> tmlength symbol))
  (:synopsis "Get the unit part of @tmlen.")
  (if (tmlength-null? tmlen) #f (second tmlen)))

(tm-define (tmlength-value+unit tmlen)
  (:type (-> tmlength (cross tmlength-value tmlength-unit)))
  (:synopsis "Fundamental tmlength deconstructor.")
  (:returns (1 "value part of @tmlen")
	    (2 "unit part of @tmlen"))
  (if (tmlength-null? tmlen)
      (values 0 #f)
      (values (first tmlen) (second tmlen))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Conversions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Should be replaced by code conforming to SRFI-13 and SRFI-14.
(define (char-decimal? c) (or (char-numeric? c) (char-in-string? c "-.")))
(define (string-span s pred)
  (receive (head tail) (list-break (string->list s) (compose not pred))
    (values (list->string head) (list->string tail))))

(tm-define (string->tmlength s)
  (:type (-> string tmlength))
  (:synopsis "Create a tmlength object from its string representation.")
  (receive
      (value-str unit-str)
      (string-span (do ((ss s (string-tail ss 2)))
		       ((not (string-starts? ss "--")) ss))
		   char-decimal?)
    (let ((value (if (string-null? value-str)
		     0 (string->number value-str)))
	  (unit (if (string-null? unit-str)
		    #f (string->symbol unit-str))))
      (cond ((and (not unit) (not (zero? value))) #f)
	    ((not unit) (tmlength))
	    ((not (tmlength-unit? unit)) #f)
	    (else (tmlength value unit))))))

(tm-define (tmlength->string tmlen)
  (:type (-> tmlength string))
  (:synopsis "Produce the string representation of a tmlength object.")
  (if (tmlength-null? tmlen) ""
      (receive (value unit) (tmlength-value+unit tmlen)
        (string-append (number->string value) (symbol->string unit)))))
