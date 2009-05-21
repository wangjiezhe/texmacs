
/******************************************************************************
* MODULE     : patch.cpp
* DESCRIPTION: Routines on patches
* COPYRIGHT  : (C) 2009  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "patch.hpp"

/******************************************************************************
* Concrete patches
******************************************************************************/

class modification_patch_rep: public patch_rep {
  modification mod;
public:
  modification_patch_rep (modification mod2): mod (mod2) {}
  int get_type () { return PATCH_MODIFICATION; }
  modification get_modification () { return mod; }
};

class compound_patch_rep: public patch_rep {
  array<patch> a;
public:
  compound_patch_rep (array<patch> a2): a (a2) {}
  int get_type () { return PATCH_COMPOUND; }
  int get_arity () { return N(a); }
  patch get_child (int i) { return a[i]; }
};

class birth_patch_rep: public patch_rep {
  double author;
  bool birth;
public:
  birth_patch_rep (double a2, bool b2): author (a2), birth (b2) {}
  int get_type () { return PATCH_BIRTH; }
  double get_author () { return author; }
  bool get_birth () { return birth; }
};

class author_patch_rep: public patch_rep {
  double author;
  patch p;
public:
  author_patch_rep (double a2, patch p2): author (a2), p (p2) {}
  int get_type () { return PATCH_AUTHOR; }
  int get_arity () { return 1; }
  patch get_child (int i) {
    ASSERT (i == 0, "out of range");
    return p; }
  double get_author () { return author; }
};

patch::patch (modification mod):
  rep (tm_new<modification_patch_rep> (mod)) { rep->ref_count= 1; }
patch::patch (array<patch> a):
  rep (tm_new<compound_patch_rep> (a)) { rep->ref_count= 1; }
patch::patch (patch p1, patch p2):
  rep (tm_new<compound_patch_rep> (array<patch>(p1,p2))) { rep->ref_count= 1; }
patch::patch (double author, bool create):
  rep (tm_new<birth_patch_rep> (author, create)) { rep->ref_count= 1; }
patch::patch (double author, patch p):
  rep (tm_new<author_patch_rep> (author, p)) { rep->ref_count= 1; }

array<patch>
get_children (patch p) {
  int i, n= N(p);
  array<patch> a (n);
  for (i=0; i<N(p); i++) a[i]= p[i];
  return a;
}

/******************************************************************************
* Common routines
******************************************************************************/

ostream&
operator << (ostream& out, patch p) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    out << get_modification (p);
    break;
  case PATCH_COMPOUND:
    out << "Composite" << INDENT;
    for (int i=0; i<N(p); i++)
      out << LF << p[i];
    out << UNINDENT;
    break;
  case PATCH_BIRTH:
    if (get_birth (p)) out << "Birth ";
    else out << "Death ";
    out << get_author (p);
    break;
  case PATCH_AUTHOR:
    out << "Author " << get_author (p) << INDENT << LF;
    out << p[0];
    out << UNINDENT;
    break;
  default:
    FAILED ("unsupported patch type");
  }
  return out;
}

patch
copy (patch p) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    return patch (copy (get_modification (p)));
  case PATCH_COMPOUND:
    {
      int i, n= N(p);
      array<patch> r (n);
      for (i=0; i<N(p); i++) r[i]= copy (p[i]);
      return r;
    }
  case PATCH_BIRTH:
    return p;
  case PATCH_AUTHOR:
    return patch (get_author (p), copy (p[0]));
  default:
    FAILED ("unsupported patch type");
  }
  return p;
}

/******************************************************************************
* Patch application
******************************************************************************/

bool
is_applicable (patch p, tree t) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    return is_applicable (t, get_modification (p));
  case PATCH_BIRTH:
    return true;
  case PATCH_COMPOUND:
  case PATCH_AUTHOR:
    for (int i=0; i<N(p); i++) {
      if (!is_applicable (p[i], t)) return false;
      t= clean_apply (p[i], t);
    }
    return true;
  default:
    FAILED ("unsupported patch type");
    return false;
  }
}

tree
clean_apply (patch p, tree t) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    return clean_apply (t, get_modification (p));
  case PATCH_BIRTH:
    return t;
  case PATCH_COMPOUND:
  case PATCH_AUTHOR:
    for (int i=0; i<N(p); i++)
      t= clean_apply (p[i], t);
    return t;
  default:
    FAILED ("unsupported patch type");
    return t;
  }
}

void
apply (patch p, tree& t) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    apply (t, get_modification (p));
    break;
  case PATCH_BIRTH:
    break;
  case PATCH_COMPOUND:
  case PATCH_AUTHOR:
    for (int i=0; i<N(p); i++)
      apply (p[i], t);
    break;
  default:
    FAILED ("unsupported patch type");
  }
}

/******************************************************************************
* Patch inversion
******************************************************************************/

patch
invert (patch p, tree t) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    return patch (invert (get_modification (p), t));
  case PATCH_BIRTH:
    return p;
  case PATCH_COMPOUND:
    {
      int i, n=N(p);
      array<patch> r(n);
      for (i=0; i<n; i++) {
	r[n-1-i]= invert (p[i], t);
	t= clean_apply (p[i], t);
      }
      return patch (r);
    }
  case PATCH_AUTHOR:
    return patch (get_author (p), invert (p[0], t));
  default:
    FAILED ("unsupported patch type");
    return patch ();
  }
}

/******************************************************************************
* Commutation of patches
******************************************************************************/

static bool
swap_basic (patch& p1, patch& p2) {
  patch aux= p1;
  p1= p2;
  p2= aux;
  return true;
}

bool
swap (patch& p1, patch& p2) {
  if (get_type (p1) == PATCH_COMPOUND) {
    int n= N(p1);
    array<patch> a (n);
    for (int i=0; i<n; i++) a[i]= p1[i];
    for (int i=n-1; i>=0; i--) {
      if (!swap (a[i], p2)) return false;
      swap_basic (a[i], p2);
    }
    p1= p2;
    p2= patch (a);
    return true;
  }
  if (get_type (p2) == PATCH_COMPOUND) {
    int n= N(p2);
    array<patch> a (n);
    for (int i=0; i<n; i++) a[i]= p2[i];
    for (int i=0; i<n; i++) {
      if (!swap (p1, a[i])) return false;
      swap_basic (p1, a[i]);
    }
    p2= p1;
    p1= patch (a);
    return true;
  }
  if (get_type (p1) == PATCH_AUTHOR) {
    patch s= p1[0];
    bool r= swap (s, p2);
    p2= patch (get_author (p1), p2);
    p1= s;
    return r;
  }
  if (get_type (p2) == PATCH_AUTHOR) {
    patch s= p2[0];
    bool r= swap (p1, s);
    p1= patch (get_author (p2), p1);
    p2= s;
    return r;
  }
  if (get_type (p1) == PATCH_BIRTH ||
      get_type (p2) == PATCH_BIRTH)
    return swap_basic (p1, p2);
  if (get_type (p1) == PATCH_MODIFICATION &&
      get_type (p2) == PATCH_MODIFICATION)
    {
      modification m1= get_modification (p1);
      modification m2= get_modification (p2);
      bool r= swap (m1, m2);
      p1= patch (m1);
      p2= patch (m2);
      return r;
    }
  FAILED ("invalid situaltion");
  return false;
}

bool
commute (patch p1, patch p2) {
  patch s1= p1;
  patch s2= p2;
  return swap (s1, s2);
}

/******************************************************************************
* Other routines
******************************************************************************/

void
insert (array<patch>& a, patch p) {
  if (get_type (p) == PATCH_COMPOUND) {
    int i, n= N(p);
    for (i=0; i<n; i++)
      insert (a, p[i]);
  }
  else a << p;
}

patch
compactify (patch p) {
  switch (get_type (p)) {
  case PATCH_COMPOUND:
    {
      array<patch> r;
      insert (r, p);
      if (N(r) == 1) return r[0];
      return patch (r);
    }
  case PATCH_AUTHOR:
    return patch (get_author (p), compactify (p[0]));
  }
  return p;
}

path
cursor_hint (modification m, tree t) {
  ASSERT (is_applicable (t, m), "modification not applicable");
  path rp= root (m);
  tree st= subtree (t, rp);
  switch (m->k) {
  case MOD_ASSIGN:
    return end (t, rp);
  case MOD_INSERT:
    if (is_atomic (st)) return rp * index (m);
    else if (index (m) == N (st)) return end (t, rp);
    else return start (t, rp * index (m));
  case MOD_REMOVE:
    if (is_atomic (st)) return rp * (index (m) + argument (m));
    else if (index (m) == N (st)) return end (t, rp);
    else if (argument (m) == 0) return start (t, rp * index (m));
    else return end (t, rp * (index (m) + argument (m) - 1));
  case MOD_SPLIT:
    if (is_atomic (st [index (m)])) return m->p;
    else if (argument (m) == N (st [index (m)])) return end (t, rp * index(m));
    else return start (t, m->p);
  case MOD_JOIN:
    return end (t, m->p);
  case MOD_ASSIGN_NODE:
    return end (t, rp);
  case MOD_INSERT_NODE:
    return end (t, rp);
  case MOD_REMOVE_NODE:
    return end (t, rp * index (m));
  default:
    FAILED ("unexpected situation");
    return path ();
  }
}

path
cursor_hint (patch p, tree t) {
  switch (get_type (p)) {
  case PATCH_MODIFICATION:
    return cursor_hint (get_modification (p), t);
  case PATCH_BIRTH:
    return path ();
  case PATCH_COMPOUND:
  case PATCH_AUTHOR:
    for (int i=0; i<N(p); i++) {
      path r= cursor_hint (p[i], t);
      if (!is_nil (r)) return r;
    }
    return path ();
  default:
    FAILED ("unsupported patch type");
  }
  return path ();
}
