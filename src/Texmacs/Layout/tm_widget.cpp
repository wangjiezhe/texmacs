
/******************************************************************************
* MODULE     : tm_widget.cpp
* DESCRIPTION: Main current graphical interface for user applications
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#include "window.hpp"
#include "Widkit/wk_widget.hpp"
#include "tm_widget.hpp"

#define THIS (wk_widget (this))
extern int nr_windows;
string icon_bar_name (int which);

/******************************************************************************
* Subwidgets of main TeXmacs widgets
******************************************************************************/

static wk_widget
make_menu_bar () {
  array<wk_widget> M (2);
  array<string> M_name (2);
  M[0]= horizontal_array (array<wk_widget> (0));
  M[1]= glue_wk_widget (true, false);
  M_name[0]= "menu";

  array<wk_widget> V (2);
  array<string> V_name (2);
  V[0]= glue_wk_widget (true, false, 0, 2*PIXEL);
  V[1]= horizontal_array (M, M_name);
  V_name[1]= "bar";
  return optional_widget (vertical_list (V, V_name));
}

static wk_widget
make_icon_bar (bool on) {
  array<wk_widget> I (4);
  array<string> I_name (4);
  I[0]= glue_wk_widget (false, false, 3*PIXEL);
  I[1]= horizontal_array (array<wk_widget> (0));
  I[2]= glue_wk_widget (true, false);
  I[3]= glue_wk_widget (false, false, 3*PIXEL);
  I_name[1]= "icons";

  array<wk_widget> V (2);
  array<string> V_name (2);
  V[0]= separator_wk_widget (PIXEL, 2*PIXEL);
  V[1]= horizontal_array (I, I_name);
  V_name[1]= "bar";
  return optional_widget (vertical_list (V, V_name), on);
}

static wk_widget
make_header (int mask) {
  array<wk_widget> H (5);
  array<string> H_name (5);
  H[0]= make_menu_bar ();
  H[1]= make_icon_bar ((mask & 2) == 2);
  H[2]= make_icon_bar ((mask & 4) == 4);
  H[3]= make_icon_bar ((mask & 8) == 8);
  H[4]= glue_wk_widget (true, false, 0, 2*PIXEL);
  H_name[0]= "menu";
  H_name[1]= "main";
  H_name[2]= "context";
  H_name[3]= "user";
  return optional_widget (vertical_list (H, H_name), (mask & 1) == 1);
}

static wk_widget
make_footer (int mask) {
  array<wk_widget> F (3);
  array<string> F_name (3);
  F[0]= text_wk_widget ("Welcome to TeXmacs!", false, "english");
  F[1]= glue_wk_widget (true, false);
  F[2]= text_wk_widget ("TeXmacs#" TEXMACS_VERSION, false, "english");
  F_name[0]= "left";
  F_name[1]= "middle";
  F_name[2]= "right";
  wk_widget ftr= horizontal_array (F, F_name, 1);
#ifdef OS_DARWIN
  F << glue_wk_widget (false, false, 14*PIXEL, 0);
  F_name << "margin";
#endif

  array<wk_widget> I (2);
  array<string> I_name (2);
  I[0]= text_wk_widget ("Input:", false, "english");
  I[1]= glue_wk_widget (true, false);
  I_name[0]= "left";
  I_name[1]= "middle";
  wk_widget iac= horizontal_array (I, I_name, 1);

  array<wk_widget> S (3);
  array<string> S_name (3);
  S[0]= ftr;
  S[1]= iac;
  S[2]= glue_wk_widget (false, false);
  S_name[0]= "default";
  S_name[1]= "interactive";
  return switch_widget (S, S_name, (mask & 16) == 16? 0: 2);
}

static wk_widget
make_texmacs_widget (int mask) {
  array<wk_widget> V (3);
  array<string> V_name (3);
  V[0]= make_header (mask);
  V[1]= canvas_widget (glue_wk_widget ());
  V[2]= make_footer (mask);
  V_name[0]= "header";
  V_name[1]= "canvas";
  V_name[2]= "footer";
  return vertical_list (V, V_name);
}

/******************************************************************************
* Constructor and destructor
******************************************************************************/

tm_widget_rep::tm_widget_rep (int mask):
  basic_widget_rep (1),
  footer_flag (true), text_ptr (NULL)
{
  a[0]= make_texmacs_widget (mask);
}

tm_widget_rep::~tm_widget_rep () {}

tm_widget_rep::operator tree () {
  return tree (TUPLE, "TeXmacs window", (tree) a[0]);
}

/******************************************************************************
* Accessors
******************************************************************************/

void
tm_widget_rep::set_subwidget (wk_widget w, string which, wk_widget sw) {
  SI ww1= 600*PIXEL, hh1=18*PIXEL, ww2=600*PIXEL, hh2=18*PIXEL;
  if (which == "icons") hh1= hh2= 18*PIXEL;
  w << get_size (ww1, hh1);
  w << set_widget (which, sw);
  w << get_size (ww2, hh2);
  if (attached ()) {
    if (hh1 == hh2) w << emit_update ();
    else THIS << emit_update ();
  }
}

bool
tm_widget_rep::get_subwidget_flag (wk_widget w) {
  int which;
  w << get_integer ("switch", which);
  return which == 0;
}

void
tm_widget_rep::set_subwidget_flag (wk_widget w, bool on) {
  if (get_subwidget_flag (w) != on) {
    w << set_integer ("switch", on? 0: 1);
    if (attached ()) THIS << emit_update ();
  }
}

/******************************************************************************
* Changing the footer
******************************************************************************/

void
tm_widget_rep::set_left_footer (string s) {
  wk_widget tw= text_wk_widget (s, false, "english");
  set_subwidget (THIS ["footer"], "left", tw);
}

void
tm_widget_rep::set_right_footer (string s) {
  wk_widget tw= text_wk_widget (s, false, "english");
  set_subwidget (THIS ["footer"], "right", tw);
}

int
tm_widget_rep::get_footer_mode () {
  int which;
  THIS ["footer"] << get_integer ("switch", which);
  return which;
}

void
tm_widget_rep::set_footer_mode (int which) {
  if (get_footer_mode () != which) {
    SI ww1= 600*PIXEL, hh1=18*PIXEL, ww2=600*PIXEL, hh2=18*PIXEL;
    THIS ["footer"] << get_size (ww1, hh1);
    THIS ["footer"] << set_integer ("switch", which);
    THIS ["footer"] << get_size (ww2, hh2);
    if (attached ()) {
      if (hh1 == hh2) THIS ["footer"] << emit_update ();
      else THIS << emit_update ();
    }
  }
}

bool
tm_widget_rep::get_footer_flag () {
  return footer_flag;
}

void
tm_widget_rep::set_footer_flag (bool on) {
  footer_flag= on;
  if (get_footer_mode () != 1)
    set_footer_mode (on? 0: 2);
}

/******************************************************************************
* Interactive commands on the footer
******************************************************************************/

class ia_command_rep: public command_rep {
  tm_widget_rep* man;
public:
  ia_command_rep (tm_widget_rep* man2): man (man2) {}
  void apply () { man->interactive_return (); }
  ostream& print (ostream& out) { return out << "tm_widget_rep command"; }
};

void
tm_widget_rep::interactive (string name, string type, array<string> def,
			    string& s, command cmd)
{
  int i, n= N(def);
  if (get_footer_mode () == 1) { s= "cancel"; return; }
  call_back= cmd;
  set_footer_mode (1);
  wk_widget iac= THIS ["footer"] ["interactive"];
  wk_widget tw = text_wk_widget (name, false, "english");
  wk_widget inp= input_text_wk_widget (new ia_command_rep (this));
  inp << set_string ("type", type);
  if (N(def) > 0) inp << set_string ("input", def[0]);
  for (i=0; i<n; i++) inp << set_string ("default", def[i]);
  iac << set_widget ("left", tw);
  iac << set_widget ("middle", inp);
  iac << emit_update ();
  THIS ["canvas"] << emit_keyboard_focus (false);
  iac  ["middle"] << emit_keyboard_focus (true);
  text_ptr= &s;
}

void
tm_widget_rep::interactive_return () {
  wk_widget iac= THIS ["footer"] ["interactive"];
  iac ["middle"] << get_input_string (*text_ptr);
  text_ptr= NULL;
  iac ["middle"] << emit_keyboard_focus (false);
  THIS ["canvas"] << emit_keyboard_focus (true);
  set_footer_mode (footer_flag? 0: 2);
  call_back ();
}

/******************************************************************************
* Handling standard events
******************************************************************************/

void
tm_widget_rep::handle_get_size (get_size_event ev) {
  if (ev->mode == 0) {
    ev->w= (800-24) * PIXEL; // (800-32) * PIXEL;
    ev->h= (600-28) * PIXEL;
  }
  else if (ev->mode == 1) the_display->get_max_size (ev->w, ev->h);
  else basic_widget_rep::handle_get_size (ev);
}

void
tm_widget_rep::handle_get_widget (get_widget_event ev) {
  a[0] << ev;
}

void
tm_widget_rep::handle_set_widget (set_widget_event ev) {
  if (ev->which == "menu bar")
    set_subwidget (THIS ["header"] ["menu"] ["bar"], "menu", ev->w);
  else if (ev->which == "main icons bar")
    set_subwidget (THIS ["header"] ["main"] ["bar"], "icons", ev->w);
  else if (ev->which == "context icons bar")
    set_subwidget (THIS ["header"] ["context"] ["bar"], "icons", ev->w);
  else if (ev->which == "user icons bar")
    set_subwidget (THIS ["header"] ["user"] ["bar"], "icons", ev->w);
  else a[0] << ev;
}

void
tm_widget_rep::handle_set_string (set_string_event ev) {
  if (ev->which == "window name") win->set_name (ev->s);
  else if (ev->which == "left footer") set_left_footer (ev->s);
  else if (ev->which == "right footer") set_right_footer (ev->s);
  else if (ev->which == "footer mode") set_footer_mode (as_int (ev->s));
  else if (ev->which == "footer flag") set_footer_flag (ev->s == "on");
  else if (ev->which == "header")
    set_subwidget_flag (THIS ["header"], ev->s == "on");
  else if (ev->which == "main icons")
    set_subwidget_flag (THIS ["header"] ["main"], ev->s == "on");
  else if (ev->which == "context icons")
    set_subwidget_flag (THIS ["header"] ["context"], ev->s == "on");
  else if (ev->which == "user icons")
    set_subwidget_flag (THIS ["header"] ["user"], ev->s == "on");
  else fatal_error ("Could not set string attribute " * ev->which);
}

void
tm_widget_rep::handle_get_string (get_string_event ev) {
  if (ev->which == "footer mode")
    ev->s= as_string (get_footer_mode ());
  else if (ev->which == "footer flag")
    ev->s= get_footer_flag ()? string ("on"): string ("off");
  else if (ev->which == "header")
    ev->s= get_subwidget_flag (THIS ["header"])?
             string ("on"): string ("off");
  else if (ev->which == "main icons")
    ev->s= get_subwidget_flag (THIS ["header"] ["main"])?
             string ("on"): string ("off");
  else if (ev->which == "context icons")
    ev->s= get_subwidget_flag (THIS ["header"] ["context"])?
             string ("on"): string ("off");
  else if (ev->which == "user icons")
    ev->s= get_subwidget_flag (THIS ["header"] ["user"])?
             string ("on"): string ("off");
  else fatal_error ("Could not set string attribute " * ev->which);
}

void
tm_widget_rep::handle_keypress (keypress_event ev) {
  if (get_footer_mode () == 1)
    THIS ["footer"] ["interactive"] ["middle"] << ev;
  else THIS ["canvas"] << ev;
}

void
tm_widget_rep::handle_mouse (mouse_event ev) {
  basic_widget_rep::handle_mouse (ev);
}

void
tm_widget_rep::handle_keyboard_focus (keyboard_focus_event ev) {
  if (get_footer_mode () == 1)
    THIS ["footer"] ["interactive"] ["middle"] << ev;
  else THIS ["canvas"] << ev;
}

void
tm_widget_rep::handle_resize (resize_event ev) {
  switch (get_footer_mode ()) {
  case 0: THIS ["footer"] ["middle"] << ev; break;
  case 1: THIS ["footer"] ["interactive"] ["middle"] << ev; break;
  }
  THIS ["canvas"] << ev;
}

void
tm_widget_rep::handle_destroy (destroy_event ev) {
  // WARNING: should be removed when the window model is redesigned
  THIS ["canvas"] << emit_keyboard_focus (true);

  get_server () -> exec_delayed (scheme_cmd ("(safely-kill-window)"));
}

/******************************************************************************
* Handling standard events
******************************************************************************/

bool
tm_widget_rep::handle (event ev) {
  // cout << "handle " << ((event) ev) << LF;
  switch (ev->type) {
  case GET_STRING_EVENT:
    handle_get_string (ev);
    return true;
  case SET_STRING_EVENT:
    handle_set_string (ev);
    return true;
  default:
    return basic_widget_rep::handle (ev);
  }
}
