
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : graphics-env.scm
;; DESCRIPTION : routines for managing the graphical context
;; COPYRIGHT   : (C) 2001  Joris van der Hoeven
;;               (C) 2004-2007  Joris van der Hoeven and Henri Lesourd
;;
;; This software falls under the GNU general public license and comes WITHOUT
;; ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (graphics graphics-env)
  (:use (utils library cursor) (utils library tree)
	(graphics graphics-utils)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; State variables & history for the current graphics context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;NOTE: This section is OK till we find a better system for handling the GC

;; Past events
(define past-events #('() '()))
(tm-define (event-exists! o e)
  (vector-set!
     past-events 0
     (cons (list o e) (vector-ref past-events 0))))

(tm-define (event-exists? o e t)
  (define (seek-event l)
     (if (or (null? l) (npair? (car l)))
	 #f
	 (with x (car l)
	    (if (and (== (car x) o) (== (cadr x) e))
		#t
		(seek-event (cdr l)))))
  )
  (if (in? t '(0 1))
      (seek-event (vector-ref past-events t))
      #f))

(tm-define (events-clocktick)
  (vector-set! past-events 1 (vector-ref past-events 0))
  (vector-set! past-events 0 '()))

(define (events-forget)
  (set! past-events (make-vector 2))
  (vector-set! past-events 0 '())
  (vector-set! past-events 1 '()))

;; State variables
(tm-define choosing #f)
(tm-define sticky-point #f)
(tm-define leftclick-waiting #f)
(tm-define current-obj #f)
(tm-define current-point-no #f)
(tm-define current-edge-sel? #f)
(tm-define current-selection #f)
(tm-define previous-selection #f)
(tm-define subsel-no #f)
(tm-define current-x #f)
(tm-define current-y #f)
(tm-define graphics-undo-enabled #t)
(tm-define selected-objects '())
(tm-define selecting-x0 #f)
(tm-define selecting-y0 #f)
(tm-define multiselecting #f)
(tm-define current-path-under-mouse #f) ; volatile
(tm-define layer-of-last-removed-object #f)

(tm-define state-slots
  ''(graphics-action
     graphical-object
     choosing
     sticky-point
     leftclick-waiting
     current-obj
     current-point-no
     current-edge-sel?
     current-selection
     previous-selection
     subsel-no
     current-x
     current-y
     graphics-undo-enabled
     selected-objects
     selecting-x0
     selecting-y0
     multiselecting
     current-path-under-mouse))

(define-export-macro (state-len)
  `(length ,state-slots))

(tm-define (new-state)
  (make-vector (state-len)))

(define-export-macro (state-slot-ref i)
  `(- (length (memq ,i ,state-slots)) 1))

(define-export-macro (state-ref st var)
  `(vector-ref ,st (state-slot-ref ,var)))

(define-export-macro (state-set! st var val)
  `(vector-set! ,st (state-slot-ref ,var) ,val))

(tm-define (graphics-state-get)
  (with st (new-state)
    (state-set! st 'graphics-action #f)
    (state-set! st 'graphical-object (get-graphical-object))
    (state-set! st 'choosing choosing)
    (state-set! st 'sticky-point sticky-point)
    (state-set! st 'leftclick-waiting leftclick-waiting)
    (state-set! st 'current-obj current-obj)
    (state-set! st 'current-point-no current-point-no)
    (state-set! st 'current-edge-sel? current-edge-sel?)
    (state-set! st 'current-selection current-selection)
    (state-set! st 'previous-selection previous-selection)
    (state-set! st 'subsel-no subsel-no)
    (state-set! st 'current-x current-x)
    (state-set! st 'current-y current-y)
    (state-set! st 'graphics-undo-enabled graphics-undo-enabled)
    (state-set! st 'selected-objects selected-objects)
    (state-set! st 'selecting-x0 selecting-x0)
    (state-set! st 'selecting-y0 selecting-y0)
    (state-set! st 'multiselecting multiselecting)
    (state-set! st 'current-path-under-mouse current-path-under-mouse)
    st))

(tm-define (graphics-state-set st)
  (with o (state-ref st 'graphical-object)
    (if (pair? (tree->stree o))
	(set-graphical-object o)
	(create-graphical-object #f #f #f #f)))
  (set! choosing (state-ref st 'choosing))
  (set! sticky-point (state-ref st 'sticky-point))
  (set! leftclick-waiting (state-ref st 'leftclick-waiting))
  (set! current-obj (state-ref st 'current-obj))
  (set! current-point-no (state-ref st 'current-point-no))
  (set! current-edge-sel? (state-ref st 'current-edge-sel?))
  (set! current-selection (state-ref st 'current-selection))
  (set! previous-selection (state-ref st 'previous-selection))
  (set! subsel-no (state-ref st 'subsel-no))
  (set! current-x (state-ref st 'current-x))
  (set! current-y (state-ref st 'current-y))
  (set! graphics-undo-enabled (state-ref st 'graphics-undo-enabled))
  (set! selected-objects (state-ref st 'selected-objects))
  (set! selecting-x0 (state-ref st 'selecting-x0))
  (set! selecting-y0 (state-ref st 'selecting-y0))
  (set! multiselecting (state-ref st 'multiselecting))
  (set! current-path-under-mouse (state-ref st 'current-path-under-mouse)))

;; State stack
(tm-define graphics-states '())

(tm-define (graphics-states-void?)
  (null? graphics-states))

(tm-define (graphics-state-first?)
  (and (not (graphics-states-void?)) (null? (cdr graphics-states))))

(tm-define (graphics-push-state st)
  (set! graphics-states (cons st graphics-states)))

(tm-define (graphics-pop-state)
  (if (graphics-states-void?)
      (display* "(graphics-pop-state)::void(graphics-states)\n")
      (with st (car graphics-states)
	(set! graphics-states (cdr graphics-states))
	st)))

;; User interface
(tm-define graphics-first-state #f)

(tm-define (graphics-store-first action)
  (if graphics-first-state
      (display* "(graphics-store-first)::!void(graphics-store-first)\n"))
  (set! graphics-first-state (graphics-state-get))
  (state-set! graphics-first-state 'graphics-action action))

(tm-define (graphics-back-first)
  (graphics-state-set graphics-first-state)
  (set! graphics-first-state #f))

(tm-define (graphics-store-state first?)
  (if first?
      (graphics-store-first first?)
      (graphics-push-state (graphics-state-get))))

(tm-define (graphics-back-state first?)
  (if first?
      (graphics-back-first)
      (if (graphics-state-first?)
	  (undo)
	  (with st (graphics-pop-state)
	    (graphics-state-set st)
	    (if (graphics-states-void?)
		(graphics-push-state st))))))

(tm-define (graphics-reset-state)
  (create-graphical-object #f #f #f #f)
  (set! choosing #f)
  (set! sticky-point #f)
  (set! leftclick-waiting #f)
  (set! current-obj #f)
  (set! current-point-no #f)
  (set! current-edge-sel? #f)
  (set! current-selection #f)
  (set! previous-selection #f)
  (set! subsel-no #f)
  (set! current-x #f)
  (set! current-y #f)
  (set! graphics-undo-enabled #t)
  (set! selected-objects '())
  (set! selecting-x0 #f)
  (set! selecting-y0 #f)
  (set! multiselecting #f)
  (set! current-path-under-mouse #f)
  (set! layer-of-last-removed-object #f))

(tm-define (graphics-forget-states)
  (set! graphics-first-state #f)
  (set! graphics-states '())
  (events-forget))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutines for using and maintaining the current graphics context
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Graphical select
;;NOTE: This subsection is OK, except the hack for custom objects ;-(...
(define (filter-graphical-select l x y)
  (define (filter-path p)
     (define (cut-after-first-negative p) ;; NOTE: Belongs to the hack
	(with ref #f
	   (foreach-cons (x p)
	      (if (and (not ref) (< (car x) 0))
		  (set! ref x))
	   )
	   (if ref
	       (set-cdr! ref '()))
	)
	p
     )
     (with p2 (map string->number (cdr p))
       (set! p2 (cut-after-first-negative p2)) ;; NOTE: Hack
       (if (graphics-path p2) p2 #f))
  )
  (define (filter-sel e)
    (with e2 (map filter-path (cdr e))
   ;; FIXME: Hack to workaround the bad results of (graphical-select) for
   ;;   custom objects (sends back paths with negative elements).
      (if (and (>= (length e2) 1)
	       (pair? (car e2))
	       (< (cAr (car e2)) 0)
	  )
	  (set-car! e2 (rcons (cDr (car e2)) 0)))
      (if (and (>= (length e2) 2)
	       (pair? (cadr e2))
	       (< (cAr (cadr e2)) 0)
	  )
	  (set-car! (cdr e2) (rcons (cDr (cadr e2)) 0)))
      (if (and (>= (length e2) 2)
	       (== (car e2) (cadr e2))
	  )
	  (set-cdr! e2 '()))
      (if (car e2)
      (let* ((p (graphics-path (car e2)))
	     (o (if p (path->tree p) #f))
	 )
	 (if (and (compound-tree? o)
		  (eq? (tree-label o) 'with)
		  (eq? (tree-label (tree-ref o (- (tree-arity o) 1)))
		       'graphics))
	 (begin
	    (set! o #f)
	    (set-car! e2 #f)))
	 (if (and o (not (in? (tree-label o) gr-tags-all)))
          ;; Custom markup
	     (set-car! e2 (rcons p (if x (object-closest-point-pos
					    (tree->stree o) (f2s x) (f2s y))
					 0))))))
   ;; FIXME: End hack
      (if (== (car e2) #f) #f e2))
  )
  (define (remove-filtered-elts l)
    (if (pair? l)
      (if (pair? (cdr l))
	(if (== (cadr l) #f)
	    (begin
	      (set-cdr! l (cddr l))
	      (remove-filtered-elts l))
	    (remove-filtered-elts (cdr l)))
	l)
      #f)
  )
  (with l2 (cons 'tuple (map filter-sel (cdr l)))
    (remove-filtered-elts l2)
   ;(display* "res2=" (cdr l2) "\n")
    (cdr l2)))

(tm-define (graphics-select x y d)
  (with res (tree->stree (graphical-select x y))
   ;(display* "res=" res "\n")
    (filter-graphical-select res x y)))

(tm-define (graphics-select-area x1 y1 x2 y2)
  (define l '())
  (with res (tree->stree (graphical-select-area x1 y1 x2 y2))
   ;(display* "res=" res "\n")
    (set! res (filter-graphical-select res #f #f))
    (foreach (e res)
       (set! l (cons (graphics-path (car e)) l))
    )
    (reverse (list-remove-duplicates l))))

(tm-define (select-first x y)
  (with sel (graphics-select x y 15)
    (if (pair? sel) (car sel) #f)))

(tm-define (select-choose x y)
  (with sel (graphics-select x y 15)
    (set! previous-selection current-selection)
    (set! current-selection sel)
    (if (or (null? sel) (!= current-selection previous-selection))
	(set! subsel-no 0))
    (if (pair? sel) (car (list-tail sel subsel-no)) #f)))

(tm-define (select-next)
  (if (and current-selection subsel-no)
      (begin
	(set! subsel-no (+ subsel-no 1))
	(if (>= subsel-no (length current-selection))
	    (set! subsel-no 0)))))

;; Graphics X cursor
;;NOTE: This subsection is OK
(tm-define graphics-texmacs-pointer #f)
(tm-define (set-texmacs-pointer curs . cache)
  (define (set-pointer name)
     (if (symbol? name)
	 (set! name (symbol->string name)))
     (set! graphics-texmacs-pointer name)
  )
  (if (null? cache)
      (set! graphics-texmacs-pointer #f))
  (if (not (string-symbol=? graphics-texmacs-pointer curs))
  (cond ((== curs 'none)
	 (set-pointer 'none)
	 (set-mouse-pointer
      ;; FIXME: This function is horribly slow, due to the
      ;;   non-correct (?) caching of the xmp files, or to
      ;;   the building of too much X11 datastructures.
	    (tm_xpm "tm_cursor_none.xpm")
	    (tm_xpm "tm_mask_none.xpm")))
	((== curs 'text-arrow)
	 (set-pointer 'none)
	 (set-predef-mouse-pointer "XC_top_left_arrow"))
	((== curs 'graphics-cross)
	 (set-texmacs-pointer 'none)
	 (set-pointer 'graphics-cross))
	((== curs 'graphics-cross-arrows)
	 (set-texmacs-pointer 'none)
	 (set-pointer 'graphics-cross-arrows))
	(else
	   #t))))

;; Graphics context
;;NOTE: This subsection is OK till we find a better system for handling the GC
(define-export-macro (with-graphics-context msg x y path obj no edge . body)
  `(with res #t
     (set! current-x x)
     (set! current-y y)
     (set! current-path-under-mouse #f)
     (with gm (graphics-group-mode? (graphics-mode))
	(if sticky-point
	    (with o (graphical-object #t)
	      (if (or gm (and (pair? o) (nnull? (cdr o)))
		  )
		  (let* ((,obj (if gm '(point) (cadr o)))
			 (,no current-point-no)
			 (,edge current-edge-sel?)
			 (,path (cDr (cursor-path))))
			 (set! current-obj ,obj)
		       ,(cons 'begin body))
		  (begin
		     (set! res #f)
		     (if (not (and (string? ,msg)
				   (== (substring ,msg 0 1) ";")))
			 (display* "Uncaptured gc(sticky) "
			    ,msg " " o ", " ,x ", " ,y "\n")))))
	    (let* (( sel (select-choose (s2f ,x) (s2f ,y)))
		   ( pxy (if sel (car sel) '()))
		   (,path (graphics-path pxy))
		   (,obj (if gm '(point) (graphics-object pxy)))
		   (,edge (and sel (== (length sel) 2)))
		   (,no (if sel (cAr (car sel)) #f)))
	      (set! current-path-under-mouse ,path)
	      (set! current-obj ,obj)
	      (set! current-point-no ,no)
	      (set! current-edge-sel? ,edge)
	      (if ,obj
		  ,(cons 'begin body)
		  (if (and (string? ,msg)
			   (== (substring ,msg 0 1) ";"))
		      (if (== (substring ,msg 0 2) ";:")
			 ,(cons 'begin body)
			  (set! res #f))
		      (begin
			 (set! res #f)
			 (display* "Uncaptured gc(!sticky) "
				   ,msg " " ,obj ", " ,x ", " ,y "\n"))))))
     )
     res))

(define current-cursor #f)
(define TM_PATH (var-eval-system "echo $TEXMACS_PATH"))
(define (tm_xpm name)
  (string-append TM_PATH "/misc/pixmaps/" name))

(tm-define (graphics-reset-context cmd)
  ;; cmd in { begin, exit, undo }
  ;; (display* "Graphics] Reset-context " cmd "\n")
  (if (in? cmd '(begin exit))
      (set! current-path-under-mouse #f))
  (cond
   ((== cmd 'text-cursor)
    (if (not (== current-cursor 'text-cursor))
    (begin
       (set! current-cursor 'text-cursor)
       (set-texmacs-pointer 'text-arrow))))
   ((== cmd 'graphics-cursor)
    (if (not (== current-cursor 'graphics-cursor))
    (begin
       (set! current-cursor 'graphics-cursor)
       (set-texmacs-pointer 'graphics-cross))))
   ((and (in? cmd '(begin exit)) (or (== cmd 'begin) (not sticky-point)))
   ; FIXME : when we move the cursor from one <graphics> to another,
   ;   we are not called, whereas it should be the case.
    (graphics-reset-state)
    (graphics-forget-states)
    (with p (graphics-active-path)
       (if p (create-graphical-object (graphics-active-object) p 'points #f))))
   ((and (== cmd 'exit) sticky-point)
    (set! graphics-undo-enabled #t)
    (if graphics-first-state
	(begin
	  (if (== (state-ref graphics-first-state 'graphics-action)
		   'start-move)
	      (with p (cursor-path)
		(unredoable-undo)
		(go-to p)))))
    (graphics-reset-state)
    (graphics-forget-states))
   ((== cmd 'undo)
    (if (and sticky-point (not graphics-undo-enabled)
	     (in? (state-ref graphics-first-state 'graphics-action)
		 '(start-move start-operation)))
	(begin
	; FIXME : In this begin, the state variables should be raz-ed as well !
	  (set! graphics-undo-enabled #t)
	  (unredoable-undo))
	(begin
	  (set! selected-objects '())
	  (invalidate-graphical-object)
	  (if (and graphics-undo-enabled (not sticky-point))
	      (with p (graphics-active-path)
		(if p
		    (create-graphical-object
		       (graphics-active-object) p 'points #f)
		    (create-graphical-object #f #f #f #f))))
	  (if (and (not graphics-undo-enabled) sticky-point)
	      (create-graphical-object #f #f #f #f))
	  (set! sticky-point #f)
	  (set! current-point-no #f)
	  (set! graphics-undo-enabled #t)
	  (set! multiselecting #f)
	  (if graphics-first-state
	      (graphics-back-first))
	  (graphics-forget-states)
	  (invalidate-graphical-object))))
   (else (display* "Uncaptured reset-context " cmd "\n"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dispatching
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;NOTE: This section is OK till we find a better system for dispatching

(define-export-macro (dispatch obj vals func vars . parms)
  (define (cond-case elt)
    `(,(if (null? (cdr elt))
	   `(== ,obj ',(car elt))
	   `(in? ,obj ',elt))
      (,(string->symbol
	 (string-append
	  (symbol->string (car elt))
	  "_"
	  (symbol->string func)))
       . ,vars)))
  `(begin
    ,(if (and (pair? parms) (in? 'do-tick parms))
	`(begin
	    (events-clocktick)
	    (event-exists! ,obj ',func)))
     (if (and (not sticky-point)
	      (tm-upwards-path (cDr (cursor-path)) '(text-at) '(graphics)))
	 (when-inside-text-at ',func . ,vars)
	,(append (cons
	    'cond
	    (map cond-case vals))
	   `(,(if (and (pair? parms) (in? 'handle-other parms))
		 `(else (,(string->symbol
			   (string-append
			    "other_" (symbol->string func))) . ,vars))
		 `(else (display* "Uncaptured " ',func " " ,obj "\n"))))))))
