
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : db-menu.scm
;; DESCRIPTION : menus for searching and managing databases
;; COPYRIGHT   : (C) 2015  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (database db-menu)
  (:use (database db-widgets)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Getting and modifying the current database query
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (db-toolbar-current-search)
  (with a (db-get-current-query (current-buffer))
    (or (assoc-ref a "exact-search") "")))

(define (db-toolbar-search search)
  (let* ((a (db-get-current-query (current-buffer)))
         (keys (compute-keys-string search "verbatim"))
         (s (string-recompose keys ",")))
    (set! a (assoc-set! a "exact-search" search))
    (set! a (assoc-set! a "search" s))
    (db-set-current-query (current-buffer) a)
    (revert-buffer)
    (keyboard-focus-on "db-search")))

(define (db-toolbar-current-order)
  (with a (db-get-current-query (current-buffer))
    (or (assoc-ref a "exact-order") "Name")))

(define (db-toolbar-order order)
  (with a (db-get-current-query (current-buffer))
    (set! a (assoc-set! a "exact-order" order))
    (set! a (assoc-set! a "order" (string-replace (locase-all order) " " "")))
    (db-set-current-query (current-buffer) a)
    (revert-buffer)))

(define (db-toolbar-current-direction)
  (with a (db-get-current-query (current-buffer))
    (or (assoc-ref a "direction") "ascend")))

(define (db-toolbar-direction dir)
  (with a (db-get-current-query (current-buffer))
    (set! a (assoc-set! a "direction" dir))
    (db-set-current-query (current-buffer) a)
    (revert-buffer)))

(define (db-toolbar-current-limit)
  (with a (db-get-current-query (current-buffer))
    (or (assoc-ref a "limit") "10")))

(define (db-toolbar-limit limit)
  (with a (db-get-current-query (current-buffer))
    (set! a (assoc-set! a "limit" limit))
    (db-set-current-query (current-buffer) a)
    (revert-buffer)))

(define (db-toolbar-current-presentation)
  (with a (db-get-current-query (current-buffer))
    (upcase-first (or (assoc-ref a "presentation") "detailed"))))

(define (db-toolbar-presentation presentation)
  (with a (db-get-current-query (current-buffer))
    (set! a (assoc-set! a "presentation" (locase-all presentation)))
    (db-set-current-query (current-buffer) a)
    (revert-buffer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Visibility of the database toolbar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (db-toolbar-on?)
  (with r (in-database?)
    (when (not r)
      (set! toolbar-db-active? #f)
      (show-bottom-tools 0 #f)
      r)))

(tm-define (db-show-toolbar)
  (delayed
    (:idle 100)
    (set! toolbar-db-active? #t)
    (show-bottom-tools 0 #t)
    (delayed
      (:idle 250)
      (keyboard-focus-on "db-search"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The database toolbar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-widget (db-toolbar)
  (if (db-toolbar-on?)
      (hlist
        (text "Search: ")
        (input (when answer (db-toolbar-search answer))
               "db-search" (list (db-toolbar-current-search)) "25em")
        // // //
        (text "Order: ")
        (with order (db-toolbar-current-order)
          (enum (when answer (db-toolbar-order answer))
                (list order "Name" "Author" "Title" "Year" "Year, Name" "")
                order "10em"))
        (if (== (db-toolbar-current-direction) "ascend")
            ((balloon (icon "tm_similar_previous.xpm") "Reverse ordering")
             (db-toolbar-direction "descend")))
        (if (== (db-toolbar-current-direction) "descend")
            ((balloon (icon "tm_similar_next.xpm") "Reverse ordering")
             (db-toolbar-direction "ascend")))
        // // //
        (text "Limit: ")
        (enum (when answer (db-toolbar-limit answer))
              (list "1" "2" "5" "10" "20" "50" "100" "1000" "10000" "")
              (db-toolbar-current-limit) "4em")
        >> >> >> >> >> >> >> >>
        (glue #t #f 0 24)
        (enum (when answer (db-toolbar-presentation answer))
              (list "Detailed" "Folded" "Pretty")
              (db-toolbar-current-limit) "6em"))))

(tm-define (load-db-buffer u)
  (load-buffer u)
  (db-show-toolbar))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically generated menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (db-get-kind) "unknown")

(tm-define (db-get-types)
  (smart-ref db-kind-table (db-get-kind)))

(tm-menu (insert-entry-menu)
  (with types (sort (db-get-types) string<=?)
    (for (type types)
      ((eval (upcase-first type)) (make-db-entry type)))
    ---
    ("Other" (interactive make-db-entry))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizing the Insert menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind db-extra-menu)

(menu-bind insert-menu
  (:mode in-database?)
  (if (db-get-types)
      (=> "Database entry" (link insert-entry-menu)))
  (if (not (db-get-types))
      ("Database entry" (interactive make-db-entry)))
  (link db-extra-menu)
  (if (or (in-text?) (in-math?))
      ---)
  (if (in-text?)
      (link text-inline-menu))
  (if (in-math?)
      (link math-insert-menu))
  ---
  (link texmacs-insert-menu))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizing the icons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind db-extra-icons)

(menu-bind db-insert-icons
  (if (db-get-types)
      (=> (balloon (icon "tm_entry_add.xpm") "Insert a new entry")
          (link insert-entry-menu)))
  (if (not (db-get-types))
      ((balloon (icon "tm_entry_add.xpm") "Insert a new entry")
       (interactive make-db-entry)))
  (if (not (selection-active-any?))
      ((balloon (icon "tm_entry_confirm.xpm") "Confirm database entry")
       (kbd-alternate-return))
      ((balloon (icon "tm_entry_remove.xpm") "Remove database entry")
       (structured-remove-left)))
  (if (selection-active-any?)
      ((balloon (icon "tm_entry_confirm.xpm")
                "Confirm selected database entries")
       (kbd-alternate-return))
      ((balloon (icon "tm_entry_remove.xpm")
                "Remove selected database entries")
       (structured-remove-left)))
  (link db-extra-icons))

(menu-bind texmacs-mode-icons
  (:mode in-database?)
  (link db-insert-icons)
  (if (or (in-text?) (in-math?) (in-prog?))
      /)
  (if (in-text?)
      (link text-inline-icons))
  (if (in-math?)
      (link math-insert-icons))
  (if (in-prog?)
      (link prog-format-icons))
  (link texmacs-insert-icons))

(tm-define (alternate-second-icon t)
  (:require (tree-is? t 'db-entry))
  "tm_alternate_both.xpm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main database menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind db-entry-menu
  (if (db-get-types)
      (=> "New entry" (link insert-entry-menu)))
  (if (not (db-get-types))
      ("New entry" (interactive make-db-entry)))
  (if (not (selection-active-any?))
      ("Confirm entry" (kbd-alternate-return))
      ("Remove entry" (structured-remove-left)))
  (if (selection-active-any?)
      ("Confirm selected entries" (kbd-alternate-return))
      ("Remove selected entries" (structured-remove-left))))

(menu-bind db-menu
  ("Open bibliography" (load-db-buffer "tmfs://db/bib/global"))
  ---
  (when (in-database?)
    (link db-entry-menu))
  ---
  (when (db-importable?)
    ("Import" (db-import-file)))
  (when (bib-exportable?)
    ("Export" (db-export-file)))
  ---
  ("Preferences" (open-db-preferences)))
