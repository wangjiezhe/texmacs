
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : tmtex-springer.scm
;; DESCRIPTION : special conversions for Springer styles
;; COPYRIGHT   : (C) 2012  Joris van der Hoeven, François Poulain
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (convert latex tmtex-springer)
  (:use (convert latex tmtex)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer style options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define llncs? #f)

(tm-define (tmtex-style-init body)
  (:mode springer-style?)
  (set! llncs? #f))

(tm-define (tmtex-style-init body)
  (:mode llncs-style?)
  (set! llncs? #t))

(tm-define (tmtex-transform-style x)
  (:mode springer-style?)
  (if (== x "llncs") x "svjour3"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer metadata presentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (tmtex-make-author names affiliations emails urls miscs notes)
  (:mode springer-style?)
  (with names (tmtex-concat-Sep (map cadr names))
        `(author (!paragraph ,names
                             ,@urls
                             ,@notes
                             ,@miscs))))

(define (springer-append in w l)
  (if (< (length l) 2) l
    (with lf `(!concat (!linefeed) ,w (!linefeed))
          `((,in (!indent (!concat ,@(list-intersperse (map cadr l) lf))))))))

(define (svjour-make-title titles notes miscs)
  (with titles (tmtex-concat-Sep (map cadr titles))
        `(title (!concat ,titles ,@notes ,@miscs))))

(define (svjour-make-doc-data titles subtits authors affs dates miscs notes)
  `(!document
     ,(svjour-make-title titles notes miscs)
     ,@subtits
     ,@(springer-append 'author '(and) authors)
     ,@(springer-append 'institute '(and) affs)
     ,@dates
     (maketitle)))

(tm-define (tmtex-doc-data s l)
  (:mode springer-style?)
  (set! l (map tmtex-replace-documents l))
  (let* ((subtitles (map tmtex-doc-subtitle
                         (tmtex-select-args-by-func 'doc-subtitle l)))
         (notes     (map tmtex-doc-note
                         (tmtex-select-args-by-func 'doc-note l)))
         (miscs     (map tmtex-doc-misc
                         (tmtex-select-args-by-func 'doc-misc l)))
         (dates     (map tmtex-doc-date
                         (tmtex-select-args-by-func 'doc-date l)))
         (authors   (map tmtex-doc-author
                         (tmtex-select-args-by-func 'doc-author l)))
         (titles    (map tmtex-doc-title
                         (tmtex-select-args-by-func 'doc-title l)))
         (affs      (map tmtex-affiliation-group
                         (cluster-by-affiliations
                           (tmtex-select-args-by-func 'doc-author l)))))
    (svjour-make-doc-data titles subtitles authors affs dates miscs notes)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer affiliation clustering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (springer-clear-aff aff a filter?)
  (with datas (cdadr a)
    (if (and filter?
             (== `(,aff)
                 (filter (lambda (x) (== 'author-affiliation (car x))) datas)))
      '()
      `(doc-author (author-data ,@(filter (lambda (x) (!= aff x)) datas))))))

(define (next-affiliation l)
  (cond ((or (null? l) (nlist? l)) #f)
        ((in?   (car l) '(doc-author author-data)) (next-affiliation (cdr l)))
        ((==    (car l) 'author-affiliation) l)
        ((list? (car l))
         (with na (next-affiliation (car l))
           (if na na (next-affiliation (cdr l)))))
        (else #f)))

(define (cluster-by-affiliations l)
  (if (nlist? l) l
    (let* ((aff     (next-affiliation l))
           (hasaff  (filter (lambda (x)
                              (or (not aff)
                                  (and (list? x) (list? (cdr x))
                                       (list? (cadr x))
                                       (in? aff (cdadr x))))) l))
           (hasaff* (map (lambda (x) (springer-clear-aff aff x #f)) hasaff))
           (l*      (map (lambda (x) (springer-clear-aff aff x #t)) l))
           (l*      (filter nnull? l*))
           (aff*    `(affiliation-group
                       ,(if aff (cadr aff) '()) ,@hasaff*)))
      (if aff (append `(,aff*) (cluster-by-affiliations l*)) `(,aff*)))))

(tm-define (tmtex-affiliation-group t)
  (let* ((l        (cdr t))
         (affs     (car l))
         (affs     (if (null? affs) '()
                     `((!concat (!linefeed) (at) (!linefeed) ,(tmtex affs)))))
         (authors  (map cdadr (cdr l)))
         (names    (map (lambda (a)
                          (tmtex-concat-Sep
                            (map tmtex
                                 (map cadr (tmtex-select-args-by-func
                                             'author-name a))))) authors))
         (auth-sep '(!concat " " (and) " "))
         (names    (list-intersperse names auth-sep))
         (emails   (filter nnull?
                           (map (lambda (e)
                                  (tmtex-concat-sep
                                    (map tmtex-author-email
                                         (tmtex-select-args-by-func
                                           'author-email e)))) authors)))
         (emails   (map (lambda (e) `(!concat (!nextline) ,e)) emails)))
         `(institution (!concat ,@names ,@affs ,@emails))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer specific titlemarkup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (tmtex-doc-subtitle t)
  (:mode springer-style?)
  `(subtitle ,(tmtex (cadr t))))

(tm-define (tmtex-doc-note t)
  (:mode springer-style?)
  `(tmnote ,(tmtex (cadr t))))

(tm-define (tmtex-doc-misc t)
  (:mode springer-style?)
  `(tmmisc ,(tmtex (cadr t))))

(tm-define (tmtex-doc-date t)
  (:mode springer-style?)
  `(date ,(tmtex (cadr t))))

(tm-define (tmtex-author-affiliation t)
  (:mode springer-style?)
  `(institute ,(tmtex (cadr t))))

(tm-define (tmtex-author-email t)
  (:mode springer-style?)
  `(email ,(tmtex (cadr t))))

(tm-define (tmtex-author-homepage t)
  (:mode springer-style?)
  `(tmhomepage ,(tmtex (cadr t))))

(tm-define (tmtex-author-note t)
  (:mode springer-style?)
  `(tmnote ,(tmtex (cadr t))))

(tm-define (tmtex-author-misc t)
  (:mode springer-style?)
  `(tmmisc ,(tmtex (cadr t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer specific abstract markup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define  (tmtex-make-abstract-data keywords msc abstract)
  (:mode springer-style?)
  (:require (not llncs?))
  `(!document ,@abstract ,@msc ,@keywords))

(tm-define (tmtex-abstract-keywords t)
  (:mode springer-style?)
  (:require (not llncs?))
  (with args (list-intersperse (map tmtex (cdr t)) '(!group (and)))
    `(keywords (!concat ,@args))))

(tm-define (tmtex-abstract-msc t)
  (:mode springer-style?)
  (:require (not llncs?))
  (with args (list-intersperse (map tmtex (cdr t)) '(!group (and)))
    `(subclass (!concat ,@args))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer SVMono style (basically like default LaTeX classe with subtitle)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (tmtex-transform-style x)
  (:mode svmono-style?) x)

(tm-define (tmtex-doc-subtitle t)
  (:mode svmono-style?)
  `(subtitle ,(tmtex (cadr t))))

(define (svmono-make-title titles notes miscs)
  (with titles (tmtex-concat-Sep (map cadr titles))
        `(title (!indent (!paragraph ,titles ,@notes ,@miscs)))))

(tm-define (tmtex-make-doc-data titles subtitles authors dates miscs notes)
  (:mode svmono-style?)
  `(!document
     ,(svmono-make-title titles notes miscs)
     ,@subtitles
     ,@(tmtex-append-authors authors)
     ,@dates
     (maketitle)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer LLNCS metadata presentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (springer-append in w l)
  (if (< (length l) 2) l
    (with lf `(!concat (!linefeed) ,w (!linefeed))
          `((,in (!indent (!concat ,@(list-intersperse (map cadr l) lf))))))))

(define (svjour-make-title titles notes miscs)
  (with titles (tmtex-concat-Sep (map cadr titles))
        `(title (!concat ,titles ,@notes ,@miscs))))

(define (svjour-make-doc-data titles subtits authors affs dates miscs notes)
  `(!document
     ,(svjour-make-title titles notes miscs)
     ,@subtits
     ,@(springer-append 'author '(and) authors)
     ,@(springer-append 'institute '(and) affs)
     ,@dates
     (maketitle)))

(tm-define (tmtex-doc-data s l)
  (:mode llncs-style?)
  (set! l (map tmtex-replace-documents l))
  (let* ((subtitles (map tmtex-doc-subtitle
                         (tmtex-select-args-by-func 'doc-subtitle l)))
         (notes     (map tmtex-doc-note
                         (tmtex-select-args-by-func 'doc-note l)))
         (miscs     (map tmtex-doc-misc
                         (tmtex-select-args-by-func 'doc-misc l)))
         (dates     (map tmtex-doc-date
                         (tmtex-select-args-by-func 'doc-date l)))
         (titles    (map tmtex-doc-title
                         (tmtex-select-args-by-func 'doc-title l)))
         (authors   (tmtex-select-args-by-func 'doc-author l))
         (affs      (map tmtex-author-affiliation
                         (collect-affiliations authors)))
         (authors   (map tmtex-doc-author
                         (replace-affiliations authors 0))))
    (svjour-make-doc-data titles subtitles authors affs dates miscs notes)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Springer LLNCS affiliation clustering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (collect-affiliations l)
  (if (nlist? l) l
    (let* ((aff     (next-affiliation l))
           (l*      (map (lambda (x) (springer-clear-aff aff x #t)) l))
           (l*      (filter nnull? l*))
           (aff*    (if aff `(affiliation-group ,(cadr aff)))))
      (if aff (append `(,aff*) (collect-affiliations l*)) '()))))

(define (springer-replace-aff aff a n)
  (let* ((ref   `(author-affiliation-ref ,(number->string n)))
         (datas (cdadr a)))
    `(doc-author (author-data ,@(map (lambda (x)
                                       (if (!= aff x) x ref)) datas)))))
(define (replace-affiliations l n)
  (with aff (next-affiliation l)
    (if (or (nlist? l) (not aff)) l
      (let* ((n     (1+ n))
             (l*    (map (lambda (x) (springer-replace-aff aff x n)) l)))
        (replace-affiliations l* n)))))

(define (tmtex-author-affiliation-ref t)
  `(inst ,(tmtex (cadr t))))

(tm-define (tmtex-doc-author t)
  (:mode llncs-style?)
  (set! t (tmtex-replace-documents t))
  (if (or (npair? t) (npair? (cdr t)) (not (func? (cadr t) 'author-data))) '()
    (let* ((datas  (cdadr t))
           (miscs  (map tmtex-author-misc
                        (tmtex-select-args-by-func 'author-misc datas)))
           (notes  (map tmtex-author-note
                        (tmtex-select-args-by-func 'author-note datas)))
           (emails (map tmtex-author-email
                        (tmtex-select-args-by-func 'author-email datas)))
           (urls   (map tmtex-author-homepage
                        (tmtex-select-args-by-func 'author-homepage datas)))
           (names  (map tmtex-author-name
                        (tmtex-select-args-by-func 'author-name datas)))
           (affs   (map tmtex-author-affiliation-ref
                        (tmtex-select-args-by-func
                          'author-affiliation-ref datas))))
      (tmtex-make-author names affs emails urls miscs notes))))

(tm-define (tmtex-make-author names affiliations emails urls miscs notes)
  (:mode llncs-style?)
  (with names (tmtex-concat-Sep (map cadr names))
    (set! names `(,(car names) (!concat ,@(cdr names) ,@affiliations)))
      `(author (!paragraph ,names
                           ,@urls
                           ,@notes
                           ,@miscs))))
