
/******************************************************************************
* MODULE     : convert.hpp
* DESCRIPTION: various conversion routines
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#ifndef CONVERT_H
#define CONVERT_H
#include "analyze.hpp"
#include "hashmap.hpp"
typedef tree scheme_tree;

/*** Miscellaneous ***/
bool   is_snippet (tree doc);
string get_texmacs_path ();

/*** Generic ***/
string suffix_to_format (string suffix);
string format_to_suffix (string format);
string get_format (string s, string suffix);
tree   generic_to_tree (string s, string format);
string tree_to_generic (tree doc, string format);

/*** Texmacs ***/
tree   texmacs_to_tree (string s);
tree   texmacs_document_to_tree (string s);
string tree_to_texmacs (tree t);
tree   extract (tree doc, string attr);
tree   extract_document (tree doc);
hashmap<string,int> get_codes (string version);
tree   string_to_tree (string s, string version);
tree   upgrade (tree t, string version);

/*** Scheme ***/
string scheme_tree_to_string (scheme_tree t);
string scheme_tree_to_block (scheme_tree t);
scheme_tree tree_to_scheme_tree (tree t);
string tree_to_scheme (tree t);
scheme_tree string_to_scheme_tree (string s);
scheme_tree block_to_scheme_tree  (string s);
tree   scheme_tree_to_tree (scheme_tree t);
tree   scheme_tree_to_tree (scheme_tree t, string version);
tree   scheme_to_tree (string s);
tree   scheme_document_to_tree (string s);

/*** Verbatim ***/
string tree_to_verbatim (tree t, bool pritty= false);
tree   verbatim_to_tree (string s);
tree   verbatim_document_to_tree (string s);

/*** Latex ***/
tree   parse_latex (string s);
tree   parse_latex_document (string s);
tree   latex_to_tree (tree t);

/*** Xml / Html ***/
tree   parse_xml (string s);
tree   parse_html (string s);
tree   tmml_upgrade (scheme_tree t);

#endif // defined CONVERT_H
