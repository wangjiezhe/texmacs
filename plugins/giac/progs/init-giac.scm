
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : init-giac.scm
;; DESCRIPTION : Initialize giac plugin
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(lazy-menu (giac-menus) giac-functions-menu)

(define (giac-initialize)
  (import-from (utils plugins plugin-convert))
  (lazy-input-converter (giac-input) giac)
  (menu-extend texmacs-extra-menu
    (if (in-giac?)
	(=> "Giac" (link giac-functions-menu)))))

(plugin-configure giac
  (:require (url-exists-in-path? "giac"))
  (:initialize (giac-initialize))
  (:tab-completion #t)
  (:launch "giac --texmacs")
  (:session "Giac"))
