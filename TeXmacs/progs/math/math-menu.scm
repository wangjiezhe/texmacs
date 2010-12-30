
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : math-menu.scm
;; DESCRIPTION : menus for mathematical mode and mathematical symbols
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (math math-menu)
  (:use (table table-edit)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inserting mathematical markup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind insert-math-menu
  ("Formula" (make 'math))
  (if (style-has? "env-math-dtd")
      ("Equation" (make-equation*))
      ("Equations" (make-eqnarray*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The Mathematics menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind math-menu
  ("Fraction" (make-fraction))
  ("Square root" (make-sqrt))
  ("N-th root" (make-var-sqrt))
  ("Negation" (make-neg))
  ("Tree" (make-tree))
  ---
  (-> "Size tag" (link size-tag-menu))
  (-> "Script"
      ("Left subscript" (make-script #f #f))
      ("Left superscript" (make-script #t #f))
      ("Right subscript" (make-script #f #t))
      ("Right superscript" (make-script #t #t))
      ("Script below" (make-below))
      ("Script above" (make-above)))
  (-> "Accent above"
      ("Tilda" (make-wide "~"))
      ("Hat" (make-wide "^"))
      ("Bar" (make-wide "<bar>"))
      ("Vector" (make-wide "<vect>"))
      ("Check" (make-wide "<check>"))
      ("Breve" (make-wide "<breve>"))
      ---
      ("Acute" (make-wide "<acute>"))
      ("Grave" (make-wide "<grave>"))
      ("Dot" (make-wide "<dot>"))
      ("Two dots" (make-wide "<ddot>"))
      ("Circle" (make-wide "<abovering>"))
      ---
      ("Overbrace" (make-wide "<wide-overbrace>"))
      ("Underbrace" (make-wide "<wide-underbrace*>"))
      ("Square overbrace" (make-wide "<wide-sqoverbrace>"))
      ("Square underbrace" (make-wide "<wide-squnderbrace*>"))
      ("Right arrow" (make-wide "<wide-varrightarrow>"))
      ("Left arrow" (make-wide "<wide-varleftarrow>"))
      ("Wide bar" (make-wide "<wide-bar>")))
  (-> "Accent below"
      ("Tilda" (make-wide-under "~"))
      ("Hat" (make-wide-under "^"))
      ("Bar" (make-wide-under "<bar>"))
      ("Vector" (make-wide-under "<vect>"))
      ("Check" (make-wide-under "<check>"))
      ("Breve" (make-wide-under "<breve>"))
      ---
      ("Acute" (make-wide-under "<acute>"))
      ("Grave" (make-wide-under "<grave>"))
      ("Dot" (make-wide-under "<dot>"))
      ("Two dots" (make-wide-under "<ddot>"))
      ("Circle" (make-wide-under "<abovering>"))
      ---
      ("Overbrace" (make-wide-under "<wide-overbrace*>"))
      ("Underbrace" (make-wide-under "<wide-underbrace>"))
      ("Square overbrace" (make-wide-under "<wide-sqoverbrace*>"))
      ("Square underbrace" (make-wide-under "<wide-squnderbrace>"))
      ("Right arrow" (make-wide-under "<wide-varrightarrow>"))
      ("Left arrow" (make-wide-under "<wide-varleftarrow>"))
      ("Wide bar" (make-wide-under "<wide-bar>")))
  (-> "Symbol" (link symbol-menu))
  ---
  ("Text" (make 'text))
  (-> "Table" (link insert-table-menu))
  (-> "Image" (link insert-image-menu))
  (-> "Link" (link insert-link-menu))
  (if (detailed-menus?)
      (if (style-has? "std-fold-dtd")
	  (-> "Fold" (link insert-fold-menu)))
      (-> "Animation" (link insert-animation-menu))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu for syntax and other corrections
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind math-correct-menu
  ("Correct all" (math-correct-all))
  (when (with-versioning-tool?)
    ("Correct manually" (math-correct-manually)))
  ---
  (group "Options")
  ("Remove superfluous invisible operators"
   (toggle-preference "manual remove superfluous invisible"))
  ("Insert missing invisible operators"
   (toggle-preference "manual insert missing invisible"))
  ("Homoglyph substitutions"
   (toggle-preference "manual homoglyph correct")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The mathematical Symbol menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind symbol-menu
  (-> "Large opening bracket" (tile 8 (link left-delimiter-menu)))
  (-> "Large separator" (tile 8 (link middle-delimiter-menu)))
  (-> "Large closing bracket" (tile 8 (link right-delimiter-menu)))
  (-> "Big operator"
      (tile 8 (link big-operator-menu)))
  ---
  (-> "Binary operation"
      (tile 8 (link binary-operation-menu)))
  (-> "Binary relation"
      (tile 8 (link binary-relation-menu-1))
      ---
      (tile 8 (link binary-relation-menu-2)))
  (-> "Arrow"
      (tile 9 (link horizontal-arrow-menu))
      ---
      (tile 8 (link vertical-arrow-menu))
      ---
      (tile 6 (link long-arrow-menu)))
  (-> "Negation"
      ("General negation" (key-press "/"))
      ---
      (tile 9 (link negation-menu-1))
      ---
      (tile 9 (link negation-menu-2)))
  ---
  (-> "Greek letter"
      (tile 8 (link lower-greek-menu))
      ---
      (tile 8 (link upper-greek-menu)))
  (-> "Miscellaneous"
      (tile 8 (link miscellaneous-symbol-menu))
      ---
      (tile 6 (link dots-menu))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Large delimiters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind large-delimiter-menu
  (symbol "<left-(-2>" (math-bracket-open "(" ")" 'default))
  (symbol "<left-)-2>" (math-bracket-open ")" "(" 'default))
  (symbol "<left-[-2>" (math-bracket-open "[" "]" 'default))
  (symbol "<left-]-2>" (math-bracket-open "]" "[" 'default))
  (symbol "<left-{-2>" (math-bracket-open "{" "}" 'default))
  (symbol "<left-}-2>" (math-bracket-open "}" "{" 'default))
  (symbol "<left-langle-2>" (math-bracket-open "langle" "rangle" 'default))
  (symbol "<left-rangle-2>" (math-bracket-open "rangle" "langle" 'default))
  (symbol "<left-lfloor-2>" (math-bracket-open "lfloor" "rfloor" 'default))
  (symbol "<left-rfloor-2>" (math-bracket-open "rfloor" "lfloor" 'default))
  (symbol "<left-lceil-2>" (math-bracket-open "lceil" "rceil" 'default))
  (symbol "<left-rceil-2>" (math-bracket-open "rceil" "lceil" 'default))
  (symbol "<left-llbracket-2>"
          (math-bracket-open "llbracket" "rrbracket" 'default))
  (symbol "<left-rrbracket-2>"
          (math-bracket-open "rrbracket" "llbracket" 'default))
  (symbol "<left-|-4>" (math-bracket-open "|" "|" 'default))
  (symbol "<left-||-4>" (math-bracket-open "||" "||" 'default))
  (symbol "<left-/-2>" (math-bracket-open "/" "\\" 'default))
  (symbol "<left-\\-2>" (math-bracket-open "\\" "/" 'default))
  (symbol "<left-.-2>" (math-bracket-open "." "." 'default)))

(menu-bind left-delimiter-menu
  (symbol "<left-(-2>" (math-bracket-open "(" ")" #t))
  (symbol "<left-)-2>" (math-bracket-open ")" "(" #t))
  (symbol "<left-[-2>" (math-bracket-open "[" "]" #t))
  (symbol "<left-]-2>" (math-bracket-open "]" "[" #t))
  (symbol "<left-{-2>" (math-bracket-open "{" "}" #t))
  (symbol "<left-}-2>" (math-bracket-open "}" "{" #t))
  (symbol "<left-langle-2>" (math-bracket-open "langle" "rangle" #t))
  (symbol "<left-rangle-2>" (math-bracket-open "rangle" "langle" #t))
  (symbol "<left-lfloor-2>" (math-bracket-open "lfloor" "rfloor" #t))
  (symbol "<left-rfloor-2>" (math-bracket-open "rfloor" "lfloor" #t))
  (symbol "<left-lceil-2>" (math-bracket-open "lceil" "rceil" #t))
  (symbol "<left-rceil-2>" (math-bracket-open "rceil" "lceil" #t))
  (symbol "<left-llbracket-2>" (math-bracket-open "llbracket" "rrbracket" #t))
  (symbol "<left-rrbracket-2>" (math-bracket-open "rrbracket" "llbracket" #t))
  (symbol "<left-|-4>" (math-bracket-open "|" "|" #t))
  (symbol "<left-||-4>" (math-bracket-open "||" "||" #t))
  (symbol "<left-/-2>" (math-bracket-open "/" "\\" #t))
  (symbol "<left-\\-2>" (math-bracket-open "\\" "/" #t))
  (symbol "<left-.-2>" (math-bracket-open "." "." #t)))

(menu-bind middle-delimiter-menu
  (symbol "<mid-(-2>" (math-separator "(" #t))
  (symbol "<mid-)-2>" (math-separator ")" #t))
  (symbol "<mid-[-2>" (math-separator "[" #t))
  (symbol "<mid-]-2>" (math-separator "]" #t))
  (symbol "<mid-{-2>" (math-separator "{" #t))
  (symbol "<mid-}-2>" (math-separator "}" #t))
  (symbol "<mid-langle-2>" (math-separator "langle" #t))
  (symbol "<mid-rangle-2>" (math-separator "rangle" #t))
  (symbol "<mid-lfloor-2>" (math-separator "lfloor" #t))
  (symbol "<mid-rfloor-2>" (math-separator "rfloor" #t))
  (symbol "<mid-lceil-2>" (math-separator "lceil" #t))
  (symbol "<mid-rceil-2>" (math-separator "rceil" #t))
  (symbol "<mid-llbracket-2>" (math-separator "llbracket" #t))
  (symbol "<mid-rrbracket-2>" (math-separator "rrbracket" #t))
  (symbol "<mid-|-4>" (math-separator "|" #t))
  (symbol "<mid-||-4>" (math-separator "||" #t))
  (symbol "<mid-/-2>" (math-separator "/" #t))
  (symbol "<mid-\\-2>" (math-separator "\\" #t)))

(menu-bind right-delimiter-menu
  (symbol "<right-(-2>" (math-bracket-close "(" ")" #t))
  (symbol "<right-)-2>" (math-bracket-close ")" "(" #t))
  (symbol "<right-[-2>" (math-bracket-close "[" "]" #t))
  (symbol "<right-]-2>" (math-bracket-close "]" "[" #t))
  (symbol "<right-{-2>" (math-bracket-close "{" "}" #t))
  (symbol "<right-}-2>" (math-bracket-close "}" "{" #t))
  (symbol "<right-langle-2>" (math-bracket-close "langle" "rangle" #t))
  (symbol "<right-rangle-2>" (math-bracket-close "rangle" "langle" #t))
  (symbol "<right-lfloor-2>" (math-bracket-close "lfloor" "rfloor" #t))
  (symbol "<right-rfloor-2>" (math-bracket-close "rfloor" "lfloor" #t))
  (symbol "<right-lceil-2>" (math-bracket-close "lceil" "rceil" #t))
  (symbol "<right-rceil-2>" (math-bracket-close "rceil" "lceil" #t))
  (symbol "<right-llbracket-2>"
	  (math-bracket-close "llbracket" "rrbracket" #t))
  (symbol "<right-rrbracket-2>"
	  (math-bracket-close "rrbracket" "llbracket" #t))
  (symbol "<right-|-4>" (math-bracket-close "|" "|" #t))
  (symbol "<right-||-4>" (math-bracket-close "||" "||" #t))
  (symbol "<right-/-2>" (math-bracket-close "/" "\\" #t))
  (symbol "<right-\\-2>" (math-bracket-close "\\" "/" #t))
  (symbol "<right-.-2>" (math-bracket-close "." "." #t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Big operators
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind big-operator-menu
  (symbol "<big-sum-2>" (math-big-operator "sum"))
  (symbol "<big-prod-2>" (math-big-operator "prod"))
  (symbol "<big-int-2>" (math-big-operator "int"))
  (symbol "<big-oint-2>" (math-big-operator "oint"))
  (symbol "<big-amalg-2>" (math-big-operator "amalg"))
  (symbol "<big-cap-2>" (math-big-operator "cap"))
  (symbol "<big-cup-2>" (math-big-operator "cup"))
  (symbol "<big-wedge-2>" (math-big-operator "wedge"))
  (symbol "<big-vee-2>" (math-big-operator "vee"))
  (symbol "<big-odot-2>" (math-big-operator "odot"))
  (symbol "<big-oplus-2>" (math-big-operator "oplus"))
  (symbol "<big-otimes-2>" (math-big-operator "otimes"))
  (symbol "<big-sqcap-2>" (math-big-operator "sqcap"))
  (symbol "<big-sqcup-2>" (math-big-operator "sqcup"))
  (symbol "<big-curlywedge-2>" (math-big-operator "curlywedge"))
  (symbol "<big-curlyvee-2>" (math-big-operator "curlyvee"))
  (symbol "<big-triangleup-2>" (math-big-operator "triangleup"))
  (symbol "<big-triangledown-2>" (math-big-operator "triangledown"))
  (symbol "<big-box-2>" (math-big-operator "box"))
  (symbol "<big-pluscup-2>" (math-big-operator "pluscup"))
  (symbol "<big-parallel-2>" (math-big-operator "parallel"))
  (symbol "<big-interleave-2>" (math-big-operator "interleave"))
  (symbol "<big-.-2>" (math-big-operator ".")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Binary operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind binary-operation-menu
  (symbol "<oplus>")
  (symbol "<ominus>")
  (symbol "<otimes>")
  (symbol "<oslash>")
  (symbol "<odot>")
  (symbol "<varocircle>")
  (symbol "<circledast>")
  (symbol "<obar>")
  (symbol "<boxplus>")
  (symbol "<boxminus>")
  (symbol "<boxtimes>")
  (symbol "<boxslash>")
  (symbol "<boxdot>")
  (symbol "<boxbox>")
  (symbol "<boxast>")
  (symbol "<boxbar>")

  (symbol "<pm>")
  (symbol "<mp>")
  (symbol "<times>")
  (symbol "<div>")
  (symbol "<ast>")
  (symbol "<star>")
  (symbol "<circ>")
  (symbol "<bullet>")
  (symbol "<cdot>")
  (symbol "<cap>")
  (symbol "<cup>")
  (symbol "<uplus>")
  (symbol "<sqcap>")
  (symbol "<sqcup>")
  (symbol "<vee>")
  (symbol "<wedge>")
  
  (symbol "<ltimes>")
  (symbol "<rtimes>")
  (symbol "<leftthreetimes>")
  (symbol "<rightthreetimes>")
  (symbol "<curlyvee>")
  (symbol "<curlywedge>")
  (symbol "<veebar>")
  (symbol "<barwedge>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Binary relations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind binary-relation-menu-1
  (symbol "<sim>")
  (symbol "<simeq>")
  (symbol "<approx>")
  (symbol "<cong>")
  (symbol "<asymp>")
  (symbol "<equiv>")
  (symbol "<asympasymp>")
  (symbol "<simsim>")
  (symbol "<bumpeq>")
  (symbol "<Bumpeq>")
  (symbol "<circeq>")
  (symbol "<backsim>")
  (symbol "<backsimeq>")
  (symbol "<eqcirc>")
  (symbol "<thicksim>")
  (symbol "<thickapprox>")
  (symbol "<approxeq>")
  (symbol "<triangleq>")
  (symbol "<neq>" "= /")
  (symbol "<nin>")
  (symbol "<perp>")
  (symbol "<smile>")
  (symbol "<frown>")
  (symbol "<propto>"))

(menu-bind binary-relation-menu-2
  (symbol "<less>")
  (symbol "<leqslant>")
  (symbol "<leq>")
  (symbol "<leqq>")
  (symbol "<ll>")
  (symbol "<lleq>")
  (symbol "<lll>")
  (symbol "<llleq>")
  (symbol "<gtr>")
  (symbol "<geqslant>")
  (symbol "<geq>")
  (symbol "<geqq>")
  (symbol "<gg>")
  (symbol "<ggeq>")
  (symbol "<ggg>")
  (symbol "<gggeq>")

  (symbol "<prec>")
  (symbol "<preccurlyeq>")
  (symbol "<preceq>")
  (symbol "<precsim>")
  (symbol "<precprec>")
  (symbol "<precpreceq>")
  (symbol "<precprecprec>")
  (symbol "<precprecpreceq>")
  (symbol "<succ>")
  (symbol "<succcurlyeq>")
  (symbol "<succeq>")
  (symbol "<succsim>")
  (symbol "<succsucc>")
  (symbol "<succsucceq>")
  (symbol "<succsuccsucc>")
  (symbol "<succsuccsucceq>")

  (symbol "<subset>")
  (symbol "<subseteq>")
  (symbol "<subseteqq>")
  (symbol "<sqsubset>")
  (symbol "<sqsubseteq>")
  (symbol "<Subset>")
  (symbol "<subsetplus>")
  (symbol "<in>")
  (symbol "<supset>")
  (symbol "<supseteq>")
  (symbol "<supseteqq>")
  (symbol "<sqsupset>")
  (symbol "<sqsupseteq>")
  (symbol "<Supset>")
  (symbol "<supsetplus>")
  (symbol "<ni>")

  (symbol "<vartriangleleft>")
  (symbol "<trianglelefteqslant>")
  (symbol "<trianglelefteq>")
  (symbol "<blacktriangleleft>")
  (symbol "<lesssim>")
  (symbol "<lessapprox>")
  (symbol "<precsim>")
  (symbol "<precapprox>")
  (symbol "<vartriangleright>")
  (symbol "<trianglerighteqslant>")
  (symbol "<trianglerighteq>")
  (symbol "<blacktriangleright>")
  (symbol "<gtrsim>")
  (symbol "<gtrapprox>")
  (symbol "<succsim>")
  (symbol "<succapprox>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Arrows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind horizontal-arrow-menu
  (symbol "<leftarrow>")
  (symbol "<Leftarrow>")
  (symbol "<leftharpoonup>")
  (symbol "<leftharpoondown>")
  (symbol "<leftleftarrows>")
  (symbol "<leftarrowtail>")
  (symbol "<hookleftarrow>")
  (symbol "<looparrowleft>")
  (symbol "<twoheadleftarrow>")

  (symbol "<rightarrow>")
  (symbol "<Rightarrow>")
  (symbol "<rightharpoonup>")
  (symbol "<rightharpoondown>")
  (symbol "<rightrightarrows>")
  (symbol "<rightarrowtail>")
  (symbol "<hookrightarrow>")
  (symbol "<looparrowright>")
  (symbol "<twoheadrightarrow>")

  (symbol "<leftrightarrow>")
  (symbol "<Leftrightarrow>")
  (symbol "<leftrightharpoons>")
  (symbol "<rightleftharpoons>")
  (symbol "<leftrightarrows>")
  (symbol "<rightleftarrows>")
  (symbol "<mapsto>")
  (symbol "<rightsquigarrow>")
  (symbol "<leftrightsquigarrow>"))

(menu-bind vertical-arrow-menu
  (symbol "<uparrow>")
  (symbol "<Uparrow>")
  (symbol "<upuparrows>")
  (symbol "<upharpoonleft>")
  (symbol "<upharpoonright>")
  (symbol "<nwarrow>")
  (symbol "<nearrow>")
  (symbol "<updownarrow>")

  (symbol "<downarrow>")
  (symbol "<Downarrow>")
  (symbol "<downdownarrows>")
  (symbol "<downharpoonleft>")
  (symbol "<downharpoonright>")
  (symbol "<swarrow>")
  (symbol "<searrow>")
  (symbol "<Updownarrow>"))

(menu-bind long-arrow-menu
  (symbol "<longleftarrow>")
  (symbol "<longrightarrow>")
  (symbol "<longleftrightarrow>")
  (symbol "<Longleftarrow>")
  (symbol "<Longrightarrow>")
  (symbol "<Longleftrightarrow>")
  (symbol "<longhookleftarrow>")
  (symbol "<longhookrightarrow>")
  (symbol "<longmapsto>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Negations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind negation-menu-1
  (symbol "<neq>")
  (symbol "<nequiv>")
  (symbol "<nasymp>")
  (symbol "<nsim>")
  (symbol "<napprox>")
  (symbol "<nsimeq>")
  (symbol "<ncong>")
  (symbol "<nin>")
  (symbol "<nni>"))

(menu-bind negation-menu-2
  (symbol "<nless>")
  (symbol "<nleqslant>")
  (symbol "<nleq>")
  (symbol "<lneq>")
  (symbol "<lneqq>")
  (symbol "<lvertneqq>")
  (symbol "<lnsim>")
  (symbol "<lnapprox>")
  (symbol "<precneqq>")

  (symbol "<ngtr>")
  (symbol "<ngeqslant>")
  (symbol "<ngeq>")
  (symbol "<gneq>")
  (symbol "<gneqq>")
  (symbol "<gvertneqq>")
  (symbol "<gnsim>")
  (symbol "<gnapprox>")
  (symbol "<succneqq>")

  (symbol "<nprec>")
  (symbol "<npreccurlyeq>")
  (symbol "<npreceq>")
  (symbol "<precnsim>")
  (symbol "<precnapprox>")
  (symbol "<subsetneq>")
  (symbol "<subsetneqq>")
  (symbol "<varsubsetneq>")
  (symbol "<varsubsetneqq>")

  (symbol "<nsucc>")
  (symbol "<nsucccurlyeq>")
  (symbol "<nsucceq>")
  (symbol "<succnsim>")
  (symbol "<succnapprox>")
  (symbol "<supsetneq>")
  (symbol "<supsetneqq>")
  (symbol "<varsupsetneq>")
  (symbol "<varsupsetneqq>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Greek characters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind lower-greek-menu
  (symbol "<alpha>")
  (symbol "<beta>")
  (symbol "<gamma>")
  (symbol "<delta>")
  (symbol "<varepsilon>")
  (symbol "<epsilon>")
  (symbol "<zeta>")
  (symbol "<eta>")
  (symbol "<theta>")
  (symbol "<vartheta>")
  (symbol "<iota>")
  (symbol "<kappa>")
  (symbol "<lambda>")
  (symbol "<mu>")
  (symbol "<nu>")
  (symbol "<xi>")
  (symbol "<omicron>")
  (symbol "<pi>")
  (symbol "<varpi>")
  (symbol "<rho>")
  (symbol "<varrho>")
  (symbol "<sigma>")
  (symbol "<varsigma>")
  (symbol "<tau>")
  (symbol "<upsilon>")
  (symbol "<phi>")
  (symbol "<varphi>")
  (symbol "<chi>")
  (symbol "<psi>")
  (symbol "<omega>"))

(menu-bind upper-greek-menu
  (symbol "<Gamma>")
  (symbol "<Delta>")
  (symbol "<Theta>")
  (symbol "<Lambda>")
  (symbol "<Xi>")
  (symbol "<Pi>")
  (symbol "<Sigma>")
  (symbol "<Upsilon>")
  (symbol "<Phi>")
  (symbol "<Psi>")
  (symbol "<Omega>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous symbols
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind miscellaneous-symbol-menu
  (symbol "<mathd>")
  (symbol "<mathi>")
  (symbol "<mathe>")
  (symbol "<matheuler>")
  (symbol "<mathpi>")
  (symbol "<imath>")
  (symbol "<jmath>")
  (symbol "<ell>")

  (symbol "<aleph>")
  (symbol "<beth>")
  (symbol "<gimel>")
  (symbol "<daleth>")
  (symbol "<Re>")
  (symbol "<Im>")
  (symbol "<Mho>")
  (symbol "<wp>")

  (symbol "<emptyset>")
  (symbol "<varnothing>")
  (symbol "<infty>")
  (symbol "<partial>")
  (symbol "<nabla>")
  (symbol "<forall>")
  (symbol "<exists>")
  (symbol "<neg>")

  (symbol "<top>")
  (symbol "<bot>")
  (symbol "<vdash>")
  (symbol "<Vdash>")
  (symbol "<Vvdash>")
  (symbol "<vDash>")
  (symbol "<dashv>")
  (symbol "<angle>")

  (symbol "<box>")
  (symbol "<diamond>")
  (symbol "<vartriangle>")
  (symbol "<clubsuit>")
  (symbol "<diamondsuit>")
  (symbol "<heartsuit>")
  (symbol "<spadesuit>")
  (symbol "<backslash>")

  (symbol "<flat>")
  (symbol "<natural>")
  (symbol "<sharp>")
  (symbol "<eighthnote>")
  (symbol "<quarternote>")
  (symbol "<halfnote>")
  (symbol "<fullnote>")
  (symbol "<twonotes>")

  (symbol "<sun>")
  (symbol "<leftmoon>")
  (symbol "<rightmoon>")
  (symbol "<earth>")
  (symbol "<male>")
  (symbol "<female>")
  (symbol "<maltese>")
  (symbol "<kreuz>")

  (symbol "<recorder>")
  (symbol "<phone>")
  (symbol "<checked>")
  (symbol "<pointer>")
  (symbol "<bell>"))

(menu-bind dots-menu
  (symbol "<ldots>")
  (symbol "<cdots>")
  (symbol "<hdots>")
  (symbol "<vdots>")
  (symbol "<ddots>")
  (symbol "<udots>"))

(menu-bind bold-num-menu
  (symbol "<b-0>")
  (symbol "<b-1>")
  (symbol "<b-2>")
  (symbol "<b-3>")
  (symbol "<b-4>")
  (symbol "<b-5>")
  (symbol "<b-6>")
  (symbol "<b-7>")
  (symbol "<b-8>")
  (symbol "<b-9>"))

(menu-bind bold-alpha-menu
  (symbol "<b-a>")
  (symbol "<b-b>")
  (symbol "<b-c>")
  (symbol "<b-d>")
  (symbol "<b-e>")
  (symbol "<b-f>")
  (symbol "<b-g>")
  (symbol "<b-h>")
  (symbol "<b-i>")
  (symbol "<b-j>")
  (symbol "<b-k>")
  (symbol "<b-l>")
  (symbol "<b-m>")
  (symbol "<b-n>")
  (symbol "<b-o>")
  (symbol "<b-p>")
  (symbol "<b-q>")
  (symbol "<b-r>")
  (symbol "<b-s>")
  (symbol "<b-t>")
  (symbol "<b-u>")
  (symbol "<b-v>")
  (symbol "<b-w>")
  (symbol "<b-x>")
  (symbol "<b-y>")
  (symbol "<b-z>")
  (symbol "<b-A>")
  (symbol "<b-B>")
  (symbol "<b-C>")
  (symbol "<b-D>")
  (symbol "<b-E>")
  (symbol "<b-F>")
  (symbol "<b-G>")
  (symbol "<b-H>")
  (symbol "<b-I>")
  (symbol "<b-J>")
  (symbol "<b-K>")
  (symbol "<b-L>")
  (symbol "<b-M>")
  (symbol "<b-N>")
  (symbol "<b-O>")
  (symbol "<b-P>")
  (symbol "<b-Q>")
  (symbol "<b-R>")
  (symbol "<b-S>")
  (symbol "<b-T>")
  (symbol "<b-U>")
  (symbol "<b-V>")
  (symbol "<b-W>")
  (symbol "<b-X>")
  (symbol "<b-Y>")
  (symbol "<b-Z>"))

(menu-bind bold-greek-menu
  (symbol "<b-alpha>")
  (symbol "<b-beta>")
  (symbol "<b-gamma>")
  (symbol "<b-delta>")
  (symbol "<b-epsilon>")
  (symbol "<b-varepsilon>")
  (symbol "<b-zeta>")
  (symbol "<b-eta>")
  (symbol "<b-theta>")
  (symbol "<b-vartheta>")
  (symbol "<b-iota>")
  (symbol "<b-kappa>")
  (symbol "<b-lambda>")
  (symbol "<b-mu>")
  (symbol "<b-nu>")
  (symbol "<b-xi>")
  (symbol "<b-omicron>")
  (symbol "<b-pi>")
  (symbol "<b-varpi>")
  (symbol "<b-rho>")
  (symbol "<b-varrho>")
  (symbol "<b-sigma>")
  (symbol "<b-varsigma>")
  (symbol "<b-tau>")
  (symbol "<b-upsilon>")
  (symbol "<b-phi>")
  (symbol "<b-varphi>")
  (symbol "<b-chi>")
  (symbol "<b-psi>")
  (symbol "<b-omega>")
  (symbol "<b-Gamma>")
  (symbol "<b-Delta>")
  (symbol "<b-Theta>")
  (symbol "<b-Lambda>")
  (symbol "<b-Xi>")
  (symbol "<b-Pi>")
  (symbol "<b-Sigma>")
  (symbol "<b-Upsilon>")
  (symbol "<b-Phi>")
  (symbol "<b-Psi>")
  (symbol "<b-Omega>"))

(menu-bind cal-menu
  (symbol "<cal-A>")
  (symbol "<cal-B>")
  (symbol "<cal-C>")
  (symbol "<cal-D>")
  (symbol "<cal-E>")
  (symbol "<cal-F>")
  (symbol "<cal-G>")
  (symbol "<cal-H>")
  (symbol "<cal-I>")
  (symbol "<cal-J>")
  (symbol "<cal-K>")
  (symbol "<cal-L>")
  (symbol "<cal-M>")
  (symbol "<cal-N>")
  (symbol "<cal-O>")
  (symbol "<cal-P>")
  (symbol "<cal-Q>")
  (symbol "<cal-R>")
  (symbol "<cal-S>")
  (symbol "<cal-T>")
  (symbol "<cal-U>")
  (symbol "<cal-V>")
  (symbol "<cal-W>")
  (symbol "<cal-X>")
  (symbol "<cal-Y>")
  (symbol "<cal-Z>"))

(menu-bind frak-menu
  (symbol "<frak-a>")
  (symbol "<frak-b>")
  (symbol "<frak-c>")
  (symbol "<frak-d>")
  (symbol "<frak-e>")
  (symbol "<frak-f>")
  (symbol "<frak-g>")
  (symbol "<frak-h>")
  (symbol "<frak-i>")
  (symbol "<frak-j>")
  (symbol "<frak-k>")
  (symbol "<frak-l>")
  (symbol "<frak-m>")
  (symbol "<frak-n>")
  (symbol "<frak-o>")
  (symbol "<frak-p>")
  (symbol "<frak-q>")
  (symbol "<frak-r>")
  (symbol "<frak-s>")
  (symbol "<frak-t>")
  (symbol "<frak-u>")
  (symbol "<frak-v>")
  (symbol "<frak-w>")
  (symbol "<frak-x>")
  (symbol "<frak-y>")
  (symbol "<frak-z>")
  (symbol "<frak-A>")
  (symbol "<frak-B>")
  (symbol "<frak-C>")
  (symbol "<frak-D>")
  (symbol "<frak-E>")
  (symbol "<frak-F>")
  (symbol "<frak-G>")
  (symbol "<frak-H>")
  (symbol "<frak-I>")
  (symbol "<frak-J>")
  (symbol "<frak-K>")
  (symbol "<frak-L>")
  (symbol "<frak-M>")
  (symbol "<frak-N>")
  (symbol "<frak-O>")
  (symbol "<frak-P>")
  (symbol "<frak-Q>")
  (symbol "<frak-R>")
  (symbol "<frak-S>")
  (symbol "<frak-T>")
  (symbol "<frak-U>")
  (symbol "<frak-V>")
  (symbol "<frak-W>")
  (symbol "<frak-X>")
  (symbol "<frak-Y>")
  (symbol "<frak-Z>"))

(menu-bind bbb-menu
  (symbol "<bbb-a>")
  (symbol "<bbb-b>")
  (symbol "<bbb-c>")
  (symbol "<bbb-d>")
  (symbol "<bbb-e>")
  (symbol "<bbb-f>")
  (symbol "<bbb-g>")
  (symbol "<bbb-h>")
  (symbol "<bbb-i>")
  (symbol "<bbb-j>")
  (symbol "<bbb-k>")
  (symbol "<bbb-l>")
  (symbol "<bbb-m>")
  (symbol "<bbb-n>")
  (symbol "<bbb-o>")
  (symbol "<bbb-p>")
  (symbol "<bbb-q>")
  (symbol "<bbb-r>")
  (symbol "<bbb-s>")
  (symbol "<bbb-t>")
  (symbol "<bbb-u>")
  (symbol "<bbb-v>")
  (symbol "<bbb-w>")
  (symbol "<bbb-x>")
  (symbol "<bbb-y>")
  (symbol "<bbb-z>")
  (symbol "<bbb-A>")
  (symbol "<bbb-B>")
  (symbol "<bbb-C>")
  (symbol "<bbb-D>")
  (symbol "<bbb-E>")
  (symbol "<bbb-F>")
  (symbol "<bbb-G>")
  (symbol "<bbb-H>")
  (symbol "<bbb-I>")
  (symbol "<bbb-J>")
  (symbol "<bbb-K>")
  (symbol "<bbb-L>")
  (symbol "<bbb-M>")
  (symbol "<bbb-N>")
  (symbol "<bbb-O>")
  (symbol "<bbb-P>")
  (symbol "<bbb-Q>")
  (symbol "<bbb-R>")
  (symbol "<bbb-S>")
  (symbol "<bbb-T>")
  (symbol "<bbb-U>")
  (symbol "<bbb-V>")
  (symbol "<bbb-W>")
  (symbol "<bbb-X>")
  (symbol "<bbb-Y>")
  (symbol "<bbb-Z>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Icons for math mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(menu-bind math-icons
  (=> (balloon (icon "tm_fraction.xpm") "Insert a fraction")
      ("Standard fraction" (make-fraction))
      ("Small inline fraction" (make 'tfrac))
      ("Large displayed fraction" (make 'dfrac))
      ("Slash" (make 'frac*)))
  (=> (balloon (icon "tm_root.xpm") "Insert a root")
      ("Square root" (make-sqrt))
      ("Multiple root" (make-var-sqrt)))
  (=> (balloon (icon "tm_subsup.xpm") "Insert a script")
      ("Subscript" (make-script #f #t))
      ("Superscript" (make-script #t #t))
      ("Left subscript" (make-script #f #f))
      ("Left superscript" (make-script #t #f))
      ("Subscript below" (make-below))
      ("Superscript above" (make-above)))
  /
  (=> (balloon (icon "tm_bigop.xpm") "Insert a big operator")
      (tile 8 (link big-operator-menu)))
  (=> (balloon (icon "tm_bigaround.xpm") "Insert large delimiters")
      (tile 8 (link large-delimiter-menu))
      ---
      (-> "Opening" (tile 8 (link left-delimiter-menu)))
      (-> "Middle" (tile 8 (link middle-delimiter-menu)))
      (-> "Closing" (tile 8 (link right-delimiter-menu))))
  (=> (balloon (icon "tm_wide.xpm") "Insert an accent")
      (tile 6
            ((icon "tm_hat.xpm") (make-wide "^"))
            ((icon "tm_tilda.xpm") (make-wide "~"))
            ((icon "tm_bar.xpm") (make-wide "<bar>"))
            ((icon "tm_vect.xpm") (make-wide "<vect>"))
            ((icon "tm_check.xpm") (make-wide "<check>"))
            ((icon "tm_breve.xpm") (make-wide "<breve>"))
            ((icon "tm_dot.xpm") (make-wide "<dot>"))
            ((icon "tm_ddot.xpm") (make-wide "<ddot>"))
            ((icon "tm_acute.xpm") (make-wide "<acute>"))
            ((icon "tm_grave.xpm") (make-wide "<grave>"))))
  /
  (=> (balloon (icon "tm_binop.xpm") "Insert a binary operation")
      (tile 8 (link binary-operation-menu)))
  (=> (balloon (icon "tm_binrel.xpm") "Insert a binary relation")
      (tile 8 (link binary-relation-menu-1))
      ---
      (tile 8 (link binary-relation-menu-2)))
  (=> (balloon (icon "tm_arrow.xpm") "Insert an arrow")
      (tile 9 (link horizontal-arrow-menu))
      ---
      (tile 8 (link vertical-arrow-menu))
      ---
      (tile 6 (link long-arrow-menu)))
  (=> (balloon (icon "tm_unequal.xpm") "Insert a negation")
      (tile 9 (link negation-menu-1))
      ---
      (tile 9 (link negation-menu-2)))
  (=> (balloon (icon "tm_miscsymb.xpm") "Insert a miscellaneous symbol")
      (tile 8 (link miscellaneous-symbol-menu))
      ---
      (tile 6 (link dots-menu)))
  /
  (=> (balloon (icon "tm_greek.xpm") "Insert a greek character")
      (tile 8 (link lower-greek-menu))
      ---
      (tile 8 (link upper-greek-menu)))
  (=> (balloon (icon "tm_mathbold.xpm")
	       "Insert a bold character")
      (tile 15 (link bold-num-menu))
      ---
      (tile 13 (link bold-alpha-menu))
      ---
      (tile 15 (link bold-greek-menu))
      ---
      ("Use a bold font" (make-with "math-font-series" "bold")))
  (=> (balloon (icon "tm_cal.xpm")
	       "Insert a calligraphic character")
      (tile 13 (link cal-menu))
      ---
      ("Use a calligraphic font" (make-with "math-font" "cal")))
  (=> (balloon (icon "tm_frak.xpm")
	       "Insert a fraktur character")
      (tile 13 (link frak-menu))
      ---
      ("Use the fraktur font" (make-with "math-font" "Euler")))
  (=> (balloon (icon "tm_bbb.xpm")
	       "Insert a blackboard bold character")
      (tile 13 (link bbb-menu))
      ---
      ("Use the blackboard bold font" (make-with "math-font" "Bbb*")))
  (link math-format-icons)
  (=> (balloon (icon "tm_math_preferences.xpm")
               "Preferences for editing mathematics")
      (group "Semantics")
      ("Semantic editing" (toggle-preference "semantic editing"))
      ("Matching brackets" (toggle-matching-brackets)))
  (link texmacs-insert-icons))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Math focus menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (focus-tag-name l)
  (:require (== l 'math))
  "Formula")

(tm-define (focus-tag-name l)
  (:require (in? l '(equation equation*)))
  "Equation")

(tm-define (focus-variants-of t)
  (:require (tree-in? t '(math equation equation*)))
  '(formula equation))

(tm-menu (focus-variant-menu t)
  (:require (tree-in? t '(math equation equation*)))
  ("Formula" (variant-formula t))
  ("Equation" (variant-equation t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script focus menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (focus-can-insert-remove? t)
  (:require (script-context? t))
  #t)

(tm-define (focus-variants-of t)
  (:require (tree-in? t '(lsub lsup)))
  '(lsub lsup))

(tm-define (focus-variants-of t)
  (:require (tree-in? t '(rsub rsup)))
  '(rsub rsup))

(tm-menu (focus-variant-menu t)
  (:require (tree-in? t '(lsub lsup)))
  (when (script-only-script? t)
    ("Left subscript" (variant-set (focus-tree) 'lsub))
    ("Left superscript" (variant-set (focus-tree) 'lsup))))

(tm-menu (focus-variant-menu t)
  (:require (tree-in? t '(rsub rsup)))
  (when (script-only-script? t)
    ("Subscript" (variant-set (focus-tree) 'rsub))
    ("Superscript" (variant-set (focus-tree) 'rsup))))

(tm-menu (focus-insert-menu t)
  (:require (script-context? t))
  (assuming (tree-in? t '(lsub rsub))
    (when (script-only-script? t)
      ("Insert superscript" (structured-insert-up))))
  (assuming (tree-in? t '(lsup rsup))
    (when (script-only-script? t)
      ("Insert subscript" (structured-insert-down)))))

(tm-menu (focus-insert-icons t)
  (:require (script-context? t))
  (assuming (tree-in? t '(lsub rsub))
    (when (script-only-script? t)
      ((balloon (icon "tm_insert_up.xpm") "Insert superscript")
       (structured-insert-up))))
  (assuming (tree-in? t '(lsup rsup))
    (when (script-only-script? t)
      ((balloon (icon "tm_insert_down.xpm") "Insert subscript")
       (structured-insert-down)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Root focus menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (focus-can-insert-remove? t)
  (:require (tree-is? t 'sqrt))
  #f)

(tm-menu (focus-toggle-menu t)
  (:require (tree-is? t 'sqrt))
  ((check "Multiple root" "v"
          (== (tree-arity (focus-tree)) 2))
   (sqrt-toggle (focus-tree))))

(tm-menu (focus-toggle-icons t)
  (:require (tree-is? t 'sqrt))
  ((check (balloon (icon "tm_root_index.xpm") "Multiple root") "v"
          (== (tree-arity (focus-tree)) 2))
   (sqrt-toggle (focus-tree))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wide accent focus menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (focus-tag-name l)
  (:require (in? l '(wide wide*)))
  "Wide")

(tm-define (focus-variants-of t)
  (:require (tree-in? t '(wide wide*)))
  '(wide))

(tm-menu (focus-toggle-menu t)
  (:require (tree-in? t '(wide wide*)))
  ((check "Accent below" "v"
	  (alternate-second? (focus-tree)))
   (alternate-toggle (focus-tree))))

(tm-menu (focus-toggle-icons t)
  (:require (tree-in? t '(wide wide*)))
  ((check (balloon (icon "tm_wide_under.xpm") "Accent below") "v"
	  (alternate-second? (focus-tree)))
   (alternate-toggle (focus-tree))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Around focus menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (focus-tag-name l)
  (:require (in? l '(around around*)))
  "Around")

(tm-define (focus-variants-of t)
  (:require (tree-in? t '(around around*)))
  '(around))

(tm-menu (focus-toggle-menu t)
  (:require (tree-in? t '(around around*)))
  ((check "Large brackets" "v"
	  (alternate-second? (focus-tree)))
   (alternate-toggle (focus-tree))))

(tm-menu (focus-toggle-icons t)
  (:require (tree-in? t '(around around*)))
  ((check (balloon (icon "tm_large_around.xpm") "Large brackets") "v"
	  (alternate-second? (focus-tree)))
   (alternate-toggle (focus-tree))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eqnarray focus menus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (focus-tag-name l)
  (:require (in? l '(eqnarray eqnarray*)))
  "Equations")

(tm-define (focus-variants-of t)
  (:require (tree-in? t '(eqnarray eqnarray*)))
  '(eqnarray*))
