
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : latex-texmacs-drd.scm
;; DESCRIPTION : TeXmacs extensions to LaTeX
;; COPYRIGHT   : (C) 2005  Joris van der Hoeven
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (convert latex latex-texmacs-drd)
  (:use (convert latex latex-symbol-drd)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra TeXmacs symbols
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-group latex-texmacs-symbol%
  ;; arrows and other symbols with limits
  leftarrowlim rightarrowlim leftrightarrowlim mapstolim
  longleftarrowlim longrightarrowlim longleftrightarrowlim longmapstolim
  leftsquigarrowlim rightsquigarrowlim leftrightsquigarrowlim
  equallim longequallim Leftarrowlim Rightarrowlim
  Leftrightarrowlim Longleftarrowlim Longrightarrowlim Longleftrightarrowlim
  cdotslim

  ;; asymptotic relations by Joris
  nasymp asympasymp nasympasymp simsim nsimsim npreccurlyeq
  precprec precpreceq precprecprec precprecpreceq
  succsucc succsucceq succsuccsucc succsuccsucceq
  lleq llleq ggeq gggeq

  ;; extra literal symbols
  btimes Backepsilon Mho mapmulti
  mathcatalan mathd mathD mathe matheuler mathlambda mathi mathpi
  Alpha Beta Epsilon Eta Iota Kappa Mu Nu Omicron Chi Rho Tau Zeta

  ;; other extra symbols
  exterior Exists bigintwl bigointwl asterisk point cdummy comma copyright
  bignone nobracket nospace nocomma noplus nosymbol
  nin nni notni nequiv nleadsto
  dotamalg dottimes dotoplus dototimes dotast into longequal
  longhookrightarrow longhookleftarrow longdownarrow longuparrow
  triangleup precdot preceqdot llangle rrangle join um upl upm ump upequal
  assign plusassign minusassign timesassign overassign
  lflux gflux colons transtype udots
  rightmap leftmap leftrightmap)

(logic-rules
  ((latex-texmacs-arity% 'x 0) (latex-texmacs-symbol% 'x))
  ((latex-symbol% 'x) (latex-texmacs-symbol% 'x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra TeXmacs macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-group latex-texmacs-0%
  tmunsc emdash tmhrule tmat tmbsl tmdummy
  TeXmacs madebyTeXmacs withTeXmacstext
  scheme tmsep tmSep pari qed)

(logic-group latex-texmacs-1%
  key tmrsub tmrsup keepcase
  tmtextrm tmtextsf tmtexttt tmtextmd tmtextbf
  tmtextup tmtextsl tmtextit tmtextsc tmmathbf
  tmverbatim tmop tmstrong tmem tmtt tmname tmsamp tmabbr
  tmdfn tmkbd tmvar tmacronym tmperson tmscript tmdef
  dueto op tmdate tmoutput tmerrput tmtiming
  tmrunningtitle tmrunningauthor tmaffiliation tmemail tmhomepage
  tmsubtitle tmacmhomepage tmacmmisc tmieeeemail tmnote tmmisc)

(logic-group latex-texmacs-1*%
  tmcodeinline)

(logic-group latex-texmacs-2%
  tmcolor
  tmsummarizeddocumentation tmsummarizedgrouped tmsummarizedexplain
  tmsummarizedplain tmsummarizedtiny tmsummarizedraw tmsummarizedenv
  tmsummarizedstd tmsummarized
  tmdetaileddocumentation tmdetailedgrouped tmdetailedexplain
  tmdetailedplain tmdetailedtiny tmdetailedraw tmdetailedenv
  tmdetailedstd tmdetailed
  tmfoldeddocumentation tmunfoldeddocumentation
  tmfoldedsubsession tmunfoldedsubsession
  tmfoldedgrouped tmunfoldedgrouped tmfoldedexplain tmunfoldedexplain
  tmfoldedplain tmunfoldedplain tmfoldedenv tmunfoldedenv
  tmfoldedstd tmunfoldedstd tmfolded tmunfolded
  tminput tminputmath tmhlink tmaction ontop subindex)

(logic-group latex-texmacs-3%
  tmsession tmfoldedio tmunfoldedio tmfoldediomath tmunfoldediomath
  subsubindex tmref glossaryentry)

(logic-group latex-texmacs-4%
  tmscriptinput tmscriptoutput tmconverterinput tmconverteroutput
  subsubsubindex)

(logic-rules
  ((latex-texmacs% 'x) (latex-texmacs-0% 'x))
  ((latex-texmacs% 'x) (latex-texmacs-1% 'x))
  ((latex-texmacs% 'x) (latex-texmacs-1*% 'x))
  ((latex-texmacs% 'x) (latex-texmacs-2% 'x))
  ((latex-texmacs% 'x) (latex-texmacs-3% 'x))
  ((latex-texmacs% 'x) (latex-texmacs-4% 'x))
  ((latex-texmacs-arity% 'x 0) (latex-texmacs-0% 'x))
  ((latex-texmacs-arity% 'x 1) (latex-texmacs-1% 'x))
  ((latex-texmacs-arity% 'x 1) (latex-texmacs-1*% 'x))
  ((latex-texmacs-arity% 'x 2) (latex-texmacs-2% 'x))
  ((latex-texmacs-arity% 'x 3) (latex-texmacs-3% 'x))
  ((latex-texmacs-arity% 'x 4) (latex-texmacs-4% 'x))
  ((latex-texmacs-option% 'x #t) (latex-texmacs-1*% 'x))
  ((latex-command-0% 'x) (latex-texmacs-0% 'x))
  ((latex-command-1% 'x) (latex-texmacs-1% 'x))
  ((latex-command-1*% 'x) (latex-texmacs-1*% 'x))
  ((latex-command-2% 'x) (latex-texmacs-2% 'x))
  ((latex-command-3% 'x) (latex-texmacs-3% 'x))
  ((latex-command-4% 'x) (latex-texmacs-4% 'x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra TeXmacs environments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-table latex-texmacs-env-arity%
  ("proof" 0)
  ("proof*" 1)
  ("leftaligned" 0)
  ("rightaligned" 0)
  ("tmcode" 0)
  ("tmparmod" 3)
  ("tmparsep" 1)
  ("tmindent" 0)
  ("elsequation" 0)
  ("elsequation*" 0)
  ("theglossary" 1))

(logic-table latex-texmacs-option%
  ("tmcode" #t))

(logic-group latex-texmacs-environment-0%
  begin-proof begin-leftaligned begin-rightaligned
  begin-tmindent begin-elsequation begin-elsequation*)

(logic-group latex-texmacs-environment-0*%
  begin-tmcode)

(logic-group latex-texmacs-environment-1%
  begin-proof* begin-tmparsep begin-theglossary)

(logic-group latex-texmacs-environment-3%
  begin-tmparmod)

(logic-rules
  ((latex-texmacs-arity% 'x 0) (latex-texmacs-environment-0% 'x))
  ((latex-texmacs-arity% 'x 0) (latex-texmacs-environment-0*% 'x))
  ((latex-texmacs-arity% 'x 1) (latex-texmacs-environment-1% 'x))
  ((latex-texmacs-arity% 'x 3) (latex-texmacs-environment-3% 'x))
  ((latex-texmacs-option% 'x #t) (latex-texmacs-environment-0*% 'x))
  ((latex-environment-0%  'x) (latex-texmacs-environment-0% 'x))
  ((latex-environment-0*% 'x) (latex-texmacs-environment-0*% 'x))
  ((latex-environment-1%  'x) (latex-texmacs-environment-1% 'x))
  ((latex-environment-3%  'x) (latex-texmacs-environment-3% 'x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TeXmacs list environments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-table latex-texmacs-env-arity%
  ("itemizeminus" 0)
  ("itemizedot" 0)
  ("itemizearrow" 0)
  ("enumeratenumeric" 0)
  ("enumerateroman" 0)
  ("enumerateromancap" 0)
  ("enumeratealpha" 0)
  ("enumeratealphacap" 0)
  ("descriptioncompact" 0)
  ("descriptionaligned" 0)
  ("descriptiondash" 0)
  ("descriptionlong" 0))

(logic-group latex-texmacs-list%
  begin-itemizeminus begin-itemizedot begin-itemizearrow
  begin-enumeratenumeric begin-enumerateroman begin-enumerateromancap
  begin-enumeratealpha begin-enumeratealphacap
  begin-descriptioncompact begin-descriptionaligned
  begin-descriptiondash begin-descriptionlong)

(logic-rules
  ((latex-texmacs-arity% 'x 0) (latex-texmacs-list% 'x))
  ((latex-list% 'x) (latex-texmacs-list% 'x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Commands requiring special definitions in the preamble
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-group latex-texmacs-preamble-command%
  newmdenv
  tmkeywords tmacm tmarxiv tmpacs tmmsc
  fmtext tdatetext tmisctext tsubtitletext
  thankshomepage thanksemail thanksdate thanksamisc thanksmisc thankssubtitle
  mho tmfloat

  xminus xleftrightarrow xmapsto xmapsfrom xequal
  xLeftarrow xRightarrow xLeftrightarrow)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environments requiring special definitions in the preamble
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-group latex-texmacs-env-preamble-environment%
  "tmpadded" "tmoverlined" "tmunderlined" "tmbothlined"
  "tmframed" "tmornamented")

(logic-group latex-texmacs-env-preamble-environment%
  "theorem" "proposition" "lemma" "corollary"
  "axiom" "definition" "notation" "conjecture"
  "remark" "note" "example" "convention"
  "warning" "acknowledgments" "answer" "question"
  "exercise" "problem" "solution")

(logic-group latex-texmacs-theorem%
  begin-theorem begin-proposition begin-lemma begin-corollary
  begin-axiom begin-definition begin-notation begin-conjecture
  begin-remark begin-note begin-example begin-convention
  begin-warning begin-acknowledgments begin-answer begin-question
  begin-exercise begin-problem begin-solution)

(logic-rules
  ((latex-texmacs-arity% 'x 0) (latex-texmacs-theorem% 'x))
  ((latex-environment-0% 'x) (latex-texmacs-theorem% 'x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; These macros are defined by TeXmacs in certain styles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-group latex-texmacs-0%
  appendix)

(logic-group latex-texmacs-1%
  chapter section subsection paragraph subparagraph)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Deprecated extra macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(logic-group latex-texmacs-0%
  labeleqnum eqnumber leqnumber reqnumber)

(logic-group latex-texmacs-1%
  skey ckey akey mkey hkey)
