
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : db-users.scm
;; DESCRIPTION : Users and permissions
;; COPYRIGHT   : (C) 2015  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (database db-users)
  (:use (database db-format)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The current user
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define db-current-user #t)

(tm-define-macro (with-user uid . body)
  `(with-global db-current-user ,uid ,@body))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The default user
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define db-the-default-user #f)

(tm-define (db-default-user)
  (when (and (not db-the-default-user)
             (supports-sql?)
             (url-exists-in-path? "whoami")
             (url-exists-in-path? "finger")
             (url-exists-in-path? "sed"))
    (with-database global-database
      (let* ((pseudo (var-eval-system "whoami"))
             (cmd "finger `whoami` | sed -e '/Name/!d' -e 's/.*Name: //'")
             (name (var-eval-system cmd))
             (me (db-search (list (list "type" "user")
                                  (list "pseudo" pseudo)))))
        (set! me (and (nnull? me) (car me)))
        (when (and (not me) (!= pseudo "") (!= name ""))
          (set! me (db-create-entry (list (list "type" "user")
                                          (list "pseudo" pseudo)
                                          (list "name" name)))))
        (set! db-the-default-user me))))
  (set! db-the-default-user (or db-the-default-user "default"))
  db-the-default-user)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Important tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(smart-table db-encoding-table
  (("owner" * :pseudos) :users)
  (("readable" * :pseudos) :users)
  (("writable" * :pseudos) :users)
  (("delegate-owner" * :pseudos) :users)
  (("delegate-readable" * :pseudos) :users)
  (("delegate-writable" * :pseudos) :users))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Encoding and decoding of lists of users
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (db-encode-user user)
  (if (== user "all") user
      (with l (db-search (list (list "type" "user") (list "pseudo" user)))
        (if (pair? l) (car l) "all"))))

(define (db-encode-users users)
  ;;(display* "Encode users " users "\n")
  (list-filter (map db-encode-user users) identity))

(define (db-decode-user id)
  (if (== id "all") id
      (db-get-field-first id "pseudo" "nobody")))

(define (db-decode-users ids)
  ;;(display* "Decode users " ids "\n")
  (list-filter (map db-decode-user ids) identity))

(smart-table db-encoder-table
  (,:users ,db-encode-users))

(smart-table db-decoder-table
  (,:users ,db-decode-users))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creating new users
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (db-set-user-info uid pseudo name email)
  (db-set-field uid "pseudo" (list pseudo))
  (db-set-field uid "name" (list name))
  (db-set-field uid "type" (list "user"))
  (db-set-field uid "owner" (list uid))
  (db-set-field uid "email" (list email))
  (with home (string-append "~" pseudo)
    (when (null? (db-search (list (list "name" home)
                                  (list "type" "dir"))))
      (db-create home "dir" uid))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Expand user list according to group membership
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (db-expand accu todo attr)
  (with-user #t
    (with added (make-ahash-table)
      (for (uid (ahash-set->list todo))
        (with q (list (list "type" "group")
                      (list (string-append "delegate-" attr) uid))
          (for (x (db-search q))
            (when (not (ahash-ref accu x))
              (ahash-set! accu x #t)
              (ahash-set! added x #t)))))
      (if (== (ahash-size added) 0)
          accu
          (db-expand accu added attr)))))

(tm-define (db-expand-user uid attr)
  (cond ((== uid #t) #t)
        ((string? uid) (db-expand-user (list uid) attr))
        ((list? uid)
         (let* ((accu (list->ahash-set uid))
                (todo accu)
                (done (db-expand accu todo attr)))
           (rcons (sort (ahash-set->list done) string<=?) "all")))
        (else "all")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Access rights
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (db-allow? id uid attr)
  ;;(display* "Allow " id ", " uid ", " attr "\n")
  (let* ((ids (db-get-field id attr))
         (exp (db-expand-user uid attr)))
    ;;(display* "Expanded " uid " -> " exp "\n")
    ;;(display* "Test " ids " -> " (nnull? (list-intersection ids exp)) "\n")
    (or (nnull? (list-intersection ids exp))
        (and (!= attr "owner")
             (db-allow? id uid "owner")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wrap basic interface to databases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (db-get-field id attr)
  (if (or (== db-current-user #t)
          (db-allow? id db-current-user "owner")
          (db-allow? id db-current-user "readable"))
      (with-user #t
        (former id attr))
      (list)))

(tm-define (db-set-field id attr vals)
  (when (or (== db-current-user #t)
            (db-allow? id db-current-user "owner"))
    (with-user #t
      (former id attr vals))))

(tm-define (db-get-entry id)
  (if (or (== db-current-user #t)
          (db-allow? id db-current-user "owner")
          (db-allow? id db-current-user "readable"))
      (with-user #t
        (former id))
      (list)))

(tm-define (db-set-entry id l)
  (when (or (== db-current-user #t)
            (db-allow? id db-current-user "owner"))
    (with-user #t
      (former id l))))

(tm-define (db-create-entry l)
  (if (== db-current-user #t)
      (former l)
      (let* ((old-owners (or (assoc-ref l "owner") (list)))
             (new-owners (cond ((string? db-current-user)
                                (list db-current-user))
                               ((list? db-current-user)
                                db-current-user)
                               (else (list))))
             (all-owners (list-union old-owners new-owners)))
        (and (nnull? all-owners)
             (with-user #t
               (set! l (assoc-set! (list-copy l) "owner" all-owners))
               (former l))))))

(tm-define (db-search l)
  (if (== db-current-user #t)
      (former l)
      (let* ((users (db-expand-user db-current-user "readable"))
             (lo (rcons l (cons "owner" users)))
             (lr (rcons l (cons "readable" users))))
        (with-user #t
          (list-union (former lo)
                      (former lr))))))