
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : git-utils.scm
;; DESCRIPTION : subroutines for the Git tools
;; COPYRIGHT   : (C) 2019  Darcy Shen
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (utils git git-utils))

(define callgit "git")
(define NR_LOG_OPTION " -1000 ")

(define gitroot "/")

(define (delete-tail-newline a-str)
  (if (string-ends? a-str "\n")
      (delete-tail-newline (string-drop-right a-str 1))
      a-str))

(tm-define (git-root dir)
  (let* ((git-dir (url-append dir ".git"))
         (pdir (url-expand (url-append dir ".."))))
    (cond ((url-directory? git-dir)
           (string-replace (url->string dir) "\\" "/"))
          ((== pdir dir) "/")
          (else (git-root pdir)))))

(tm-define (git-versioned? name)
  (when (not (buffer-tmfs? name))
    (set! gitroot
          (git-root (if (url-directory? name)
                        name
                        (url-head name))))
    (set! callgit
          (string-append "git --work-tree=" gitroot
                         " --git-dir=" gitroot "/.git")))
  (!= gitroot "/"))

(tm-define (buffer-status name)
  (let* ((name-s (url->string name))
         (cmd (string-append callgit " status --porcelain " name-s))
         (ret (eval-system cmd)))
    (cond ((> (string-length ret) 3) (string-take ret 2))
          ((file-exists? name-s) "  ")
          (else ""))))

(tm-define (buffer-to-unadd? name)
  (with ret (buffer-status name)
        (or (== ret "A ")
            (== ret "M ")
            (== ret "MM")
            (== ret "AM")))) 

(tm-define (buffer-to-add? name)
  (with ret (buffer-status name)
        (or (== ret "??")
            (== ret " M")
            (== ret "MM")
            (== ret "AM"))))

(tm-define (buffer-histed? name)
  (with ret (buffer-status name)
        (or (== ret "M ")
            (== ret "MM")
            (== ret " M")
            (== ret "  "))))

(tm-define (buffer-has-diff? name)
  (with ret (buffer-status name)
        (or (== ret "M ")
            (== ret "MM")
            (== ret " M"))))

(tm-define (buffer-tmfs? name)
  (string-starts? (url->string name)
                  "tmfs"))
(tm-define (git-add name)
  (let* ((name-s (url->string name))
         (cmd (string-append callgit " add " name-s))
         (ret (eval-system cmd)))
    (set-message cmd "The file is added")))

(tm-define (git-unadd name)
  (display name)
  (let* ((name-s (url->string name))
         (cmd (string-append callgit " reset HEAD " name-s))
         (ret (eval-system cmd)))
    (set-message cmd "The file is unadded.")
    (display cmd)))

(tm-define (buffer-log name)
  (let* ((name1 (string-replace (url->string name) "\\" "/"))
         (sub (string-append gitroot "/"))
         (name-s (string-replace name1 sub ""))
         (cmd (string-append
               callgit " log --pretty=%ai%n%an%n%s%n%H%n"
               NR_LOG_OPTION
               name1))
         (ret1 (eval-system cmd))
         (ret2 (string-decompose ret1 "\n\n")))
    (define (string->commit-file str)
      (string->commit str name-s))
    (and (> (length ret2) 0)
         (string-null? (cAr ret2))
         (map string->commit-file (cDr ret2)))))

(tm-define (git-log)
  (let* ((cmd (string-append
               callgit
               " log --pretty=%ai%n%an%n%s%n%H%n"
               NR_LOG_OPTION))
         (ret1 (eval-system cmd))
         (ret2 (string-decompose ret1 "\n\n")))
    (define (string->commit-diff str)
      (string->commit str ""))
    (and (> (length ret2) 0)
         (string-null? (cAr ret2))
         (map string->commit-diff (cDr ret2)))))

(tm-define (git-compare-with-current name)
  (let* ((name-s (url->string name))
         (file-r (cAr (string-split name-s #\|)))
         (file (string-append gitroot "/" file-r)))
    (switch-to-buffer (string->url file))
    (compare-with-older name)))

(tm-define (git-compare-with-parent name)
  (let* ((name-s (tmfs-cdr (tmfs-cdr (url->tmfs-string name))))
         (hash (first (string-split name-s #\|)))
         (file (second (string-split name-s #\|)))
         (file-buffer-s (tmfs-url-commit (git-commit-file-parent file hash)
                                         "|" file))
         (parent (string->url file-buffer-s)))
    (if (== name parent)
        ;; FIXME: should prompt a dialog
        (set-message "No parent" "No parent")
        (compare-with-older parent))))

(tm-define (git-compare-with-master name)
  (let* ((name-s (string-replace (url->string name)
                                 (string-append gitroot "/")
                                 "|"))
         (file-buffer-s (tmfs-url-commit (git-commit-master)
                                         name-s))
         (master (string->url file-buffer-s)))
    (compare-with-older master)))

(tm-define (git-status)
  (let* ((cmd (string-append callgit " status --porcelain"))
         (ret1 (eval-system cmd))
         (ret2 (string-split ret1 #\nl)))
    (define (convert name)
      (let* ((status (string-take name 2))
             (filename (string-drop name 3))
             (file (if (or (string-starts? status "A")
                           (string-starts? status "?"))
                       filename
                       ($link (tmfs-url-git_history (url->tmfs-string 
                                                     (string-append 
                                                      gitroot "/" filename)))
                              (utf8->cork filename)))))
        (list status file)))
    (and (> (length ret2) 0)
         (string-null? (cAr ret2))
         (map convert (cDr ret2)))))

(tm-define (git-interactive-commit)
  (:interactive #t)
  (git-show-status)
  (interactive (lambda (message) (git-commit message))))

(tm-define (git-commit message)
  (let* ((cmd (string-append
               callgit " commit -m \"" message "\""))
         (ret (eval-system cmd)))
    ;; (display ret)
    (set-message (string-append callgit " commit") message))
  (git-show-status))
(tm-define (git-show object)
  (let* ((cmd (string-append callgit " show " object))
         (ret (eval-system cmd)))
    ;; (display* "\n" cmd "\n" ret "\n")
    ret))

(tm-define (git-commit-message hash)
  (let* ((cmd (string-append callgit " log -1 " hash))
         (ret (eval-system cmd)))
    (string-split ret #\nl)))

(tm-define (git-commit-parents hash)
  (let* ((cmd (string-append
               callgit " show --no-patch --format=%P " hash))
         (ret1 (eval-system cmd))
         (ret2 (delete-tail-newline ret1))
         (ret3 (string-split ret2 #\nl))
         (ret4 (cAr ret3))
         (ret5 (string-split ret4 #\ )))
    ret5))

(tm-define (git-commit-parent hash)
  (cAr (git-commit-parents hash)))

(tm-define (git-commit-file-parent file hash)
  (let* ((cmd (string-append
               callgit " log --pretty=%H "
               gitroot "/" file))
         (ret (eval-system cmd))
         (ret2 (string-decompose
                ret (string-append hash "\n"))))
    ;; (display ret2)
    (if (== (length ret2) 1)
        hash
        (string-take (second ret2) 40))))

(tm-define (git-commit-master)
  (let* ((cmd (string-append callgit " log -1 --pretty=%H"))
         (ret (eval-system cmd)))
    (delete-tail-newline ret)))

(tm-define (git-commit-diff parent hash)
  (let* ((cmd (if (== parent hash)
                  (string-append
                   callgit " show " hash
                   " --numstat --pretty=oneline")
                  (string-append
                   callgit " diff --numstat "
                   parent " " hash)))
         (ret (eval-system cmd))
         (ret2 (if (== parent hash)
                   (cdr (string-split ret #\nl))
                   (string-split ret #\nl))))
    (define (convert body)
      (let* ((alist (string-split body #\ht)))
        (if (== (first alist) "-")
            (list 0 0 (utf8->cork (third alist))
                  (string-length (third alist)))
            (list (string->number (first alist))
                  (string->number (second alist))
                  ($link (tmfs-url-commit hash "|" (third alist))
                         (utf8->cork (third alist)))
                  (string-length (third alist))))))
    (and (> (length ret2) 0)
         (string-null? (cAr ret2))
         (map convert (cDr ret2)))))