#!/usr/bin/env python
###############################################################################
##
## MODULE      : tikz.py
## DESCRIPTION : TikZ support
## COPYRIGHT   : (C) 2019  Darcy Shen, Massimiliano Gubinelli
##
## This software falls under the GNU general public license version 3 or later.
## It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
## in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.

import os
from subprocess import Popen, PIPE, STDOUT
from .latex import LaTeX
from .protocol import *


class TikZ(LaTeX):
    def __init__(self, name = "tikz"):
        super(TikZ, self).__init__()
        self.name = name

        self.pre_code = """
\\documentclass[tikz]{standalone}
\\begin{document}
"""
        self.post_code = """
\\end{document}
"""
        self.message = "TeXmacs interface to TikZ"

    def evaluate(self, code):
        if not (code.lstrip().startswith("\\documentclass")):
            if not (code.lstrip().startswith("\\begin{tikzpicture}")):
                code = "\\begin{tikzpicture}\n" + code + "\n\\end{tikzpicture}"
            code = self.pre_code + "\n" + code + "\n" + self.post_code

        super(TikZ, self).evaluate(code)
