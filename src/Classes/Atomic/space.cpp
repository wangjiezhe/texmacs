
/******************************************************************************
* MODULE     : space.cpp
* DESCRIPTION: spacing
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#include "space.hpp"

/******************************************************************************
* Constructors
******************************************************************************/

space_rep::space_rep (SI min2, SI def2, SI max2) {
  min= min2;
  def= def2;
  max= max2;
}

space_rep::space_rep (SI def2) {
  min= def= max= def2;
}

space::space (SI min, SI def, SI max) {
  rep= new space_rep (min, def, max);
}

space::space (SI def) {
  rep= new space_rep (def);
}

space::operator tree () {
  return tree (TUPLE,
	       as_string (rep->min),
	       as_string (rep->def),
	       as_string (rep->max));
}

/******************************************************************************
* The routines which are provided
******************************************************************************/

bool
operator == (space spc1, space spc2) {
  return
    (spc1->min == spc2->min) &&
    (spc1->def == spc2->def) &&
    (spc1->max == spc2->max);
}

bool
operator != (space spc1, space spc2) {
  return
    (spc1->min != spc2->min) ||
    (spc1->def != spc2->def) ||
    (spc1->max != spc2->max);
}

ostream&
operator << (ostream& out, space spc) {
  out << "[ " << spc->min << ", " << spc->def << ", " << spc->max << " ]";
  return out;
}

space
copy (space spc) {
  return space (spc->min, spc->def, spc->max);
}

space
operator + (space spc1, space spc2) {
  return space (spc1->min + spc2->min,
		spc1->def + spc2->def,
		spc1->max + spc2->max);
}

space
operator - (space spc1, space spc2) {
  return space (spc1->min - spc2->min,
		spc1->def - spc2->def,
		spc1->max - spc2->max);
}

space
operator * (int i, space spc) {
  return space (i*spc->min, i*spc->def, i*spc->max);
}

space
operator / (space spc, int i) {
  return space (spc->min/i, spc->def/i, spc->max/i);
}

space
max (space spc1, space spc2) {
  return space (max (spc1->min, spc2->min),
		max (spc1->def, spc2->def),
		max (spc1->max, spc2->max));
}
