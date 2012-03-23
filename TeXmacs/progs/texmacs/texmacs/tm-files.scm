
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : files.scm
;; DESCRIPTION : file handling
;; COPYRIGHT   : (C) 2001  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (texmacs texmacs tm-files)
  (:use (texmacs texmacs tm-server)
        (texmacs texmacs tm-print)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autosave
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (delayed-auto-save)
  (let* ((pref (get-preference "autosave"))
	 (len (if (and (string? pref) (integer? (string->number pref)))
		  (* (string->number pref) 1000) 120000)))
    (if (> len 0)
	(delayed
	  (:pause len)
	  (auto-save)))))

(define (notify-autosave var val)
  (if (has-view?) ; delayed-autosave would crash at initialization time
      (delayed-auto-save)))

(define-preferences
  ("autosave" "120" notify-autosave))

;;;

(define (more-recent file suffix1 suffix2)
  (and (url-exists? (url-glue file suffix1))
       (url-exists? (url-glue file suffix2))
       (url-newer? (url-glue file suffix1) (url-glue file suffix2))))

(define (most-recent-suffix file)
  (if (more-recent file "~" "")
      (if (not (more-recent file "#" "")) "~"
          (if (more-recent file "#" "~") "#" "~"))
      (if (more-recent file "#" "") "#" "")))

(define (autosave-eligible? name)
  (and (not (url-rooted-web? file))
       (not (url-rooted-tmfs? file))))

(define (autosave-propose name)
  (and (autosave-eligible? name)
       (with s (most-recent-suffix name)
         (and (!= s "")
              (url-glue name s)))))

(define (autosave-rescue? name) 
  (and (autosave-eligible? name)
       (== (most-recent-suffix name) "#")))

(define (autosave-remove name)
  (when (file-exists? (url-glue name "~"))
    (system-remove (url-glue name "~")))
  (when (file-exists? (url-glue name "#"))
    (system-remove (url-glue name "#"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Saving
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define current-save-target (url-none))

(define (secure-save-buffer file fm)
  (if (not (url-exists? file))
      (texmacs-save-buffer file fm)
      (user-confirm
	  "File already exists. Overwrite existing file?" #f
	(lambda (answ)
	  (when answ
	    (texmacs-save-buffer file fm))))))

(tm-define (save-buffer . l)
  (if (and (pair? l) (url? (car l)))
      (set! current-save-target (car l)))
  (cond ((= (length l) 0) (save-buffer (current-buffer)))
	((url-scratch? (car l))
	 (choose-file save-buffer "Save TeXmacs file" "texmacs"))
	((= (length l) 1) (texmacs-save-buffer (car l) "generic"))
	(else (secure-save-buffer (car l) (cadr l)))))

(tm-define (export-buffer to)
  ;; Temporary fix for saving to postscript or pdf
  (if (string? to) (set! to (url-relative (buffer-base-url) to)))
  (if (url? to) (set! current-save-target to))
  (if (in? (url-suffix to) '("ps" "pdf"))
      (print-to-file to)
      (texmacs-save-buffer to "generic")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (load-buffer-sub file fm where)
  (let* ((suffix (most-recent-suffix file))
         (question (if (== suffix "#")
                       "Rescue file from crash?"
                       "Load more recent autosave file?")))
    (if (and (!= fm "help")
	     (not (url-rooted-web? file))
	     (!= suffix ""))
	(user-confirm question #t
	  (lambda (answ)
	    (if answ
		(texmacs-load-buffer (url-glue file suffix) fm where #t)
		(texmacs-load-buffer file fm where #f))))
	(begin
	  (texmacs-load-buffer file fm where #f)))))

(tm-define (load-buffer . l)
  (with file (url-append "$TEXMACS_FILE_PATH" (car l))
    (cond ((= (length l) 1)
	   (load-buffer-sub file "generic" 0))
	  ((and (= (length l) 2) (string? (cadr l)))
	   (load-buffer-sub file (cadr l) 0))
	  ((and (= (length l) 2) (integer? (cadr l)))
	   (load-buffer-sub file "generic" (cadr l)))
	  (else (load-buffer-sub file (cadr l) (caddr l))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; New way to save buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (buffer-notify-recent name)
  (learn-interactive 'recent-buffer
                     (list (cons "0" (url->string name)))))

(define (buffer-faithful-save? name)
  (in? (url-suffix name) '("tm" "ts" "tp" "stm" "tmml")))

(define (save-buffer-save name opts)
  (with vname `(verbatim ,(url->string name))
    (if (buffer-save name)
        (set-message `(concat "Could not save '" ,vname "'") "Save file")
        (begin
          (autosave-remove name)
          (buffer-notify-recent name)
          ;;(pretend-saved...))
          (set-message `(concat "Saved '" ,vname "'") "Save file")))))

(define (save-buffer-check-faithful name opts)
  (if (buffer-faithful-save? name)
      (save-buffer-save name opts)
      (user-confirm "Save requires data conversion. Really proceed?" #f
        (lambda (answ)
          (when answ
            (save-buffer-save name opts))))))

(define (save-buffer-check-permissions name opts)
  (set! current-save-target name)
  (with vname `(verbatim ,(url->string name))
    (cond ((url-scratch? name)
           (choose-file
             (lambda (x) (apply save-buffer-as-main (cons x name opts)))
             "Save TeXmacs file" ""))
          ((not (in? name (buffer-list)))
           (with msg `(concat "The buffer '" ,vname "' does not exist")
             (set-message msg "Save file")))
          ((not (buffer-modified? name))
           (with msg "No changes need to be saved"
             (set-message msg "Save file")))
          ((and (not (url-test? name "f")) (not (url-test? name "c")))
           (with msg `(concat "The file '" ,vname "' cannot be created")
             (set-message msg "Save file")))
          ((and (url-test? name "f") (not (url-test? name "w")))
           (with msg `(concat "You do not have write access for '" ,vname "'")
             (set-message msg "Save file")))
;;          ((buffer-more-recent-on-disk? name)
;;           (user-confirm "The file has changed on disk. Really save?" #f
;;             (lambda (answ)
;;               (when answ
;;                 (save-buffer-check-faithful name opts)))))
          (else (save-buffer-check-faithful name opts)))))

(tm-define (save-buffer-main . args)
  (if (or (null? args) (not (url? (car args))))
      (save-buffer-check-permissions (current-buffer) args)
      (save-buffer-check-permissions (car args) (cdr args))))

(define (save-buffer-as-save new-name name opts)
  ;; FIXME: we might want to check further permissions and
  ;; ask for confirmation when changing the file format
  (if (and (url-scratch? name) (url-exists? name)) (system-remove name))
  (buffer-rename name new-name)
  ;; FIXME: what to do if buffer is currently being visited?
  ;; the current implementation of buffer-rename is incorrect in that case
  (apply save-buffer-main (cons new-name opts)))

(define (save-buffer-as-check-exists new-name name opts)
  (if (url-test? new-name "f")
      (user-confirm "File already exists. Really overwrite?" #f
        (lambda (answ)
          (when answ (save-buffer-as-save new-name name opts))))
      (save-buffer-as-save new-name name opts)))

(tm-define (save-buffer-as-main new-name . args)
  (if (or (null? args) (not (url? (car args))))
      (save-buffer-as-check-exists new-name (current-buffer) args)
      (save-buffer-as-check-exists new-name (car args) (cdr args))))

(tm-define (xsave-buffer . l)
  (if (null? l) (save-buffer-main)
      (begin
        (if (and (pair? l) (url? (car l)))
            (set! current-save-target (car l)))
        (cond ((url-scratch? (car l))
               (choose-file save-buffer "Save TeXmacs file" "texmacs"))
              ((= (length l) 1) (save-buffer-as-main (car l)))
              (else (secure-save-buffer (car l) (cadr l)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; New way to load buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (load-buffer-open name opts)
  (cond ((in? :background opts) (noop))
        ((in? :new-window opts)
         (open-buffer-in-window name (buffer-get name) ""))
        (else (buffer-select name)))
  (buffer-notify-recent name))

(define (load-buffer-load name opts)
  (if (url-exists? name)
      (if (buffer-load name)
          (with vname `(verbatim ,(url->string name))
            (set-message `(concat "Could not load '" ,vname "'") "Load file"))
          (load-buffer-open name opts))
      (begin
        (buffer-set-body name '(document ""))
        (load-buffer-open name opts))))

(define (load-buffer-check-permissions name opts)
  (with vname `(verbatim ,(url->string name))
    (cond ((and (not (url-test? name "f")) (not (url-test? name "c")))
           (with msg `(concat "The file '" ,vname
                              "' cannot be loaded or created")
             (set-message msg "Load file")))
          ((and (url-test? name "f") (not (url-test? name "r")))
           (with msg `(concat "You do not have read access to '" ,vname "'")
             (set-message msg "Load file")))
          (else (load-buffer-load name opts)))))

(define (load-buffer-check-autosave name opts)
  (if (autosave-propose name)
      (with question (if (autosave-rescue? name)
                         "Rescue file from crash?"
                         "Load more recent autosave file?")
        (user-confirm question #t
          (lambda (answ)
            (if answ
                (begin
                  (buffer-load (autosave-propose name))
                  (buffer-set name (buffer-get (autosave-propose name)))
                  ;;(buffer-requires-save name)
                  (load-buffer-open name opts))
                (load-buffer-load name opts)))))
      (load-buffer-load name opts)))

(tm-define (load-buffer-main name . opts)
  (if (and (not (url-exists? name))
           (url-exists? (url-append "$TEXMACS_FILE_PATH" name)))
      (set! name (url-resolve (url-append "$TEXMACS_FILE_PATH" name) "f")))
  (load-buffer-check-autosave name opts))

(tm-define (xload-buffer . l)
  (cond ((null? l)
         (noop))
        ((= (length l) 1)
         (load-buffer (car l) "generic" 0))
        ((and (= (length l) 2) (string? (cadr l)))
         (load-buffer (car l) (cadr l) 0))
        ((and (= (length l) 2) (integer? (cadr l)))
         (load-buffer (car l) "generic" (cadr l)))
        ((!= (cadr l) "generic")
         (load-buffer-sub (car l) (cadr l) (caddr l)))
        ((== (caddr l) 0)
         (load-buffer-main (car l)))
        ((== (caddr l) 1)
         (load-buffer-main :new-window))
        ((== (caddr l) 2)
         (load-buffer-main :background))
        (else
         (load-buffer-sub (car l) (cadr l) (caddr l)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (propose-name-buffer)
  (with name (url->string (current-buffer))
    (cond ((not (url-scratch? name)) name)
	  ((os-win32?) "")
	  (else (string-append (var-eval-system "pwd") "/")))))

(tm-property (load-buffer name)
  (:argument name smart-file "File name")
  (:default  name (propose-name-buffer)))

(tm-property (save-buffer name)
  (:argument name texmacs-file "Save as")
  (:default  name (propose-name-buffer)))

(tm-property (choose-file fun text type)
  (:interactive #t))

(tm-define (buffer-loader fm) (lambda (s) (load-buffer s fm)))
(tm-define (buffer-saver fm) (lambda (s) (save-buffer s fm)))
(tm-define (load-in-new-window s) (load-buffer s 1))
(tm-define (load-browse-buffer s) (load-buffer s))

(tm-define (open-buffer)
  (:synopsis "Open a new file")
  (choose-file load-buffer "Load file" ""))

(tm-define (print-buffer)
  (:synopsis "Print the current buffer")
  (print))

(tm-define (interactive-page-setup)
  (:synopsis "Specify the page setup")
  (:interactive #t)
  (set-message "Not yet implemented" "Printer setup"))

(tm-define (interactive-print-buffer)
  (:synopsis "Print the current buffer")
  (:interactive #t)
  (print-to-file "$TEXMACS_HOME_PATH/system/tmp/tmpprint.ps")
  (interactive-print '() "$TEXMACS_HOME_PATH/system/tmp/tmpprint.ps"))

(tm-define (open-auxiliary aux body . opt-master)
  (let* ((name (aux-name aux))
         (master (if (null? opt-master) (buffer-base-url) (car opt-master))))
    (aux-set-document aux body)
    (aux-set-master aux master)
    (switch-to-buffer name)))

(define-public-macro (with-aux u . prg)
  `(let* ((u ,u)
	  (t (texmacs-load-tree u "texmacs"))
	  (name (current-buffer)))
     (open-auxiliary "* Aux *" t u)
     (with r (begin ,@prg)
       (switch-to-buffer name)
       r)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Deprecated functionality
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (set-abbr-buffer name abbr)
  (deprecated-function "set-abbr-buffer" "buffer-set-title")
  (buffer-set-title (current-buffer) abbr))

(tm-define (get-abbr-buffer name)
  (deprecated-function "get-abbr-buffer" "buffer-get-title")
  (buffer-get-title (current-buffer)))

(tm-define (set-buffer name doc)
  (deprecated-function "set-buffer" "buffer-set")
  (buffer-set name doc))

(tm-define (set-buffer-tree name doc)
  (deprecated-function "set-buffer-tree" "buffer-set")
  (set-buffer-tree name doc))

(tm-define (get-buffer-tree name)
  (deprecated-function "get-buffer-tree" "buffer-get-body")
  (get-buffer-tree name))

(tm-define (get-name-buffer-path p)
  (deprecated-function "get-name-buffer-path" "path->buffer")
  (path->buffer p))

(tm-define (get-name-buffer)
  (deprecated-function "get-name-buffer" "current-buffer")
  (current-buffer))

(tm-define (set-name-buffer name)
  (deprecated-function "set-name-buffer" "buffer-rename")
  (buffer-rename (current-buffer) name))

(tm-define (pretend-save-buffer)
  (deprecated-function "pretend-save-buffer" "buffer-pretend-saved")
  (buffer-pretend-saved (current-buffer)))

(tm-define (buffer-unsaved?)
  (deprecated-function "buffer-unsaved?" "buffer-modified?")
  (buffer-modified? (current-buffer)))

(tm-define (no-name?)
  (deprecated-function "no-name?" "buffer-has-name?")
  (not (buffer-has-name? (current-buffer))))
