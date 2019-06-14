#!/usr/bin/env python
###############################################################################
##
## MODULE      : graphviz.py
## DESCRIPTION : Graphviz plotting support
## COPYRIGHT   : (C) 2019  Darcy Shen
##
## This software falls under the GNU general public license version 3 or later.
## It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
## in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.

import sys
from subprocess import Popen, PIPE, STDOUT
from .graph import Graph
from .protocol import *

class Graphviz(Graph):
    def __init__(self, name):
        super(Graphviz, self).__init__()
        self.name = name
        try:
            p = Popen([self.name, "-V"], stderr=PIPE)
            ret, err = p.communicate()
            # WARN: The Version Info is in stderr
            if (p.returncode == 0):
                self.message = err.decode()
        except OSError:
            pass

    def evaluate(self, code):
        path = self.get_eps_path()
        if os.path.isfile(path):
            os.remove(path)
        f = open(path, 'wb')
        cmd_list = [self.name, "-Teps"]
        p = Popen(cmd_list, stdout=f, stdin=PIPE, stderr=PIPE)
        py_ver = sys.version_info[0]
        if py_ver == 3:
            out, err = p.communicate(input=code.encode())
        else:
            out, err = p.communicate(input=code)
        if (p.returncode == 0):
            flush_file (self.get_eps())
        else:
            flush_verbatim (err.decode())

