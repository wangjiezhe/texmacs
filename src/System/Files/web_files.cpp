
/******************************************************************************
* MODULE     : web_files.cpp
* DESCRIPTION: file handling via the web
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "file.hpp"
#include "web_files.hpp"
#include "sys_utils.hpp"
#include "analyze.hpp"
#include "hashmap.hpp"
#include "Scheme/object.hpp"

#ifdef OS_WIN32
#include <urlget.h>
#endif

#define MAX_CACHED 25
static int web_nr=0;
static array<tree> web_cache (MAX_CACHED);
static hashmap<tree,tree> web_cache_resolve ("");

/******************************************************************************
* Caching
******************************************************************************/

static url
get_cache (url name) {
  if (web_cache_resolve->contains (name->t)) {
    int i, j;
    tree tmp= web_cache_resolve [name->t];
    for (i=0; i<MAX_CACHED; i++)
      if (web_cache[i] == name->t) {
	// cout << name << " in cache as " << tmp << " at " << i << "\n";
	for (j=i; ((j+1) % MAX_CACHED) != web_nr; j= (j+1) % MAX_CACHED)
	  web_cache[j]= web_cache[(j+1) % MAX_CACHED];
	web_cache[j]= name->t;
	break;
      }
    return as_url (tmp); // url_system (tmp);
  }
  return url_none ();
}

static url
set_cache (url name, url tmp) {
  web_cache_resolve->reset (web_cache [web_nr]);
  web_cache [web_nr]= name->t;
  web_cache_resolve (name->t)= tmp->t;
  web_nr= (web_nr+1) % MAX_CACHED;
  return tmp;
}

void
web_cache_invalidate (url name) {
  for (int i=0; i<MAX_CACHED; i++)
    if (web_cache[i] == name->t) {
      web_cache[i]= tree ("");
      web_cache_resolve->reset (name->t);
    }
}

/******************************************************************************
* Web files
******************************************************************************/

static string
web_encode (string s) {
  return tm_decode (s);
}

url
get_from_web (url name) {
  if (!is_rooted_web (name)) return url_none ();
  url res= get_cache (name);
  if (!is_none (res)) return res;

#ifdef OS_WIN32
  char *urlPath;
  char *tempFilePath;
  string urlString = as_string (name);
  url tmp = url_temp();
	
  if (starts (urlString, "www."))
    urlString = "http://" * urlString;
  else if (starts (urlString, "ftp."))
    urlString = "ftp://" * urlString;
  else if (starts (urlString, "ftp://"))
    urlPath = NULL;
  else if (starts (urlString, "http://"))
    urlPath = NULL;
  else
    urlString = "http://" * urlString;
  urlString= web_encode (urlString);

  urlPath = as_charp(urlString);
  tempFilePath = as_charp(as_string(tmp));

  if(!URL_Get(urlPath, tempFilePath)){
    tm_delete_array (urlPath);
    tm_delete_array (tempFilePath);
    return url_none();
  }

  else return set_cache (name, tmp);
#else
  string test= var_eval_system ("which wget");
  if (!ends (test, "wget")) return url_none ();
  url tmp= url_temp ();
  string tmp_s= escape_sh (concretize (tmp));
  string cmd= "wget --header='User-Agent: TeXmacs-" TEXMACS_VERSION "' -q";
  cmd << " -O " << tmp_s << " " << escape_sh (web_encode (as_string (name)));
  // cout << cmd << "\n";
  system (cmd);
  // cout << "got " << name << " as " << tmp << "\n";

  if (var_eval_system ("cat " * tmp_s * " 2> /dev/null") == "") {
    remove (tmp);
    return url_none ();
  }
  else return set_cache (name, tmp);
#endif
}

/******************************************************************************
* Files from a hyperlink file system
******************************************************************************/

url
get_from_server (url u) {
  if (!is_rooted_tmfs (u)) return url_none ();
  url res= get_cache (u);
  if (!is_none (res)) return res;

  string name= as_string (u);
  if (ends (name, "~") || ends (name, "#")) return url_none ();
  string r= as_string (call ("tmfs-load", object (name)));
  if (r == "") return url_none ();
  url tmp= url_temp ();
  (void) save_string (tmp, r, true);

  return set_cache (u, tmp);
}

bool
save_to_server (url u, string s) {
  if (!is_rooted_tmfs (u)) return true;
  string name= as_string (u);
  (void) call ("tmfs-save", object (name), object (s));
  return false;
}

/******************************************************************************
* Ramdisc
******************************************************************************/

url
get_from_ramdisc (url u) {
  if (!is_ramdisc (u)) return url_none ();
  url res= get_cache (u);
  if (!is_none (res)) return (res);
  url tmp= url_temp (string (".") * suffix (u));
  save_string (tmp, u[1][2]->t->label);
  return set_cache (u, tmp);
}
