#-------------------------------------------------------------------
# Modified version of GUILE_FLAGS in guile.m4
# from the official guile distribution
#-------------------------------------------------------------------

AC_DEFUN([GUILE_FLAGS],[
## The GUILE_FLAGS macro.
  ## First, let's just see if we can find Guile at all.
  AC_MSG_CHECKING(for Guile)
  GUILE_BIN="guile18"
  GUILE_CONFIG="guile18-config"
  guile18-config link > /dev/null || {
    GUILE_BIN="guile"
    GUILE_CONFIG="guile-config"
    guile-config link > /dev/null || {
      echo "configure: cannot find guile-config; is Guile installed?" 1>&2
      exit 1
    }
  }
  GUILE_ORIGINAL_CFLAGS="`$GUILE_CONFIG compile`"
  GUILE_CFLAGS="$GUILE_ORIGINAL_CFLAGS"
  GUILE_VARIANT_CFLAGS="$GUILE_ORIGINAL_CFLAGS $GUILE_ORIGINAL_CFLAGS/guile $GUILE_ORIGINAL_CFLAGS/libguile"
  GUILE_LDFLAGS="`$GUILE_CONFIG link`"
  GUILE_VARIANT_LDFLAGS="-L`$GUILE_CONFIG info libdir` -lguile -lreadline -ltermcap"
  AC_SUBST(GUILE_CFLAGS)
  AC_SUBST(GUILE_LDFLAGS)
  AC_MSG_RESULT(yes)
])

#-------------------------------------------------------------------
# For autodetection of flags required to link statically with Guile
#-------------------------------------------------------------------

AC_DEFUN(TEXMACS_LINK_GUILE,
[AC_TRY_LINK([
#include <guile/gh.h>
$CONFIG_DOTS
],[
  struct dummy {
    static void my_main (int argc, char** argv) {}
    static void install_guile () {
#ifdef DOTS_OK
      gh_enter (0, NULL, (void (*)(...)) ((void*) my_main));
#else
      gh_enter (0, NULL, my_main);
#endif
    }
  };
  dummy::install_guile ();
], $1, $2)
])




AC_DEFUN([LC_WITH_GUILE],[
  AC_MSG_CHECKING(whether ... arguments behave correctly)
  if test -z "$GUILE_CFLAGS"; then
    CXXFLAGS="`$GUILE_CONFIG compile`"
  else
    CXXFLAGS="$GUILE_CFLAGS"
  fi
  AC_TRY_COMPILE([
    #include <guile/gh.h>
    #include <libguile.h>
    typedef SCM (*FN)(...);
    static SCM identity (SCM x) { return x; }
    void declare () { gh_new_procedure ("identity", (FN) identity, 1, 0, 0); }
  ],[
  ],[
    AC_DEFINE(DOTS_OK, 1, [Defined if ...-style argument passing works])
    AC_MSG_RESULT(yes)
  ],[
    AC_MSG_RESULT(no)
  ])
  CXXFLAGS=""

  AC_MSG_CHECKING(the size_t of guile strings)
  if test -z "$GUILE_CFLAGS"; then
    CXXFLAGS="`$GUILE_CONFIG compile`"
  else
    CXXFLAGS="$GUILE_CFLAGS"
  fi
  AC_TRY_COMPILE([
    #include <guile/gh.h>
    #include <libguile.h>
    void print_string (SCM s) {
      int len_r;
      char* r= gh_scm2newstr (s, &len_r); }
  ],[
  ],[
    AC_DEFINE(guile_str_size_t, int, [Guile string size type])
    AC_MSG_RESULT(int)
  ],[
    AC_DEFINE(guile_str_size_t, size_t, [Guile string size type])
    AC_MSG_RESULT(size_t)
  ])
  CXXFLAGS=""
])



AC_DEFUN([LC_GUILE_STATIC],[
AC_MSG_CHECKING([if statically linking with guile works])
SAVE_CPPFLAGS="$CPPFLAGS"
SAVE_LDFLAGS="$LDFLAGS"
SAVE_LIBS="$LIBS"
CPPFLAGS="$GUILE_CFLAGS"
LDFLAGS="-static"
LIBS="$GUILE_LDFLAGS"
TEXMACS_LINK_GUILE([tm_link_guile_static="yes"],
		   [tm_link_guile_static="no"])
AC_MSG_RESULT(["$tm_link_guile_static"])
if test "$tm_link_guile_static" = "no" ; then
   AC_MSG_CHECKING([if it works with -lltdl])
   LIBS="$GUILE_LDFLAGS -lltdl"
   TEXMACS_LINK_GUILE([tm_link_guile_static_ltdl="yes"],
		      [tm_link_guile_static_ltdl="no"])
   AC_MSG_RESULT(["$tm_link_guile_static_ltdl"])
   if test "$tm_link_guile_static_ltdl" = "yes" ; then
      GUILE_LDFLAGS="$GUILE_LDFLAGS -lltdl"
   else
      AC_MSG_CHECKING([if it works with -lltdl -ldl])
      LIBS="$GUILE_LDFLAGS -lltdl -ldl"
      TEXMACS_LINK_GUILE([tm_link_guile_static_ltdl_ldl="yes"],
			 [tm_link_guile_static_ltdl_ldl="no"])
      AC_MSG_RESULT(["$tm_link_guile_static_ltdl_ldl"])
      if test "$tm_link_guile_static_ltdl_ldl" = "yes" ; then
	 GUILE_LDFLAGS="$GUILE_LDFLAGS -lltdl -ldl"
      else
         AC_MSG_WARN([unable to link statically with guile])
      fi
   fi
fi
CPPFLAGS="$SAVE_CPPFLAGS"
LDFLAGS="$SAVE_LDFLAGS"
LIBS="$SAVE_LIBS"
])

AC_DEFUN([LC_GUILE],[
  AC_ARG_ENABLE(guile2,
  [  --enable-guile2         enable compilation with Guile 2, for development purposes],
      [], [enable_guile2="no"])

  if test -z "$GUILE_CFLAGS" -a -z "$GUILE_LDFLAGS"; then
    GUILE_FLAGS
  fi

  AC_MSG_CHECKING(version of guile)
  if test -z "$GUILE_EFFECTIVE_VERSION" ; then
    GUILE_EFFECTIVE_VERSION=`$GUILE_BIN -c '(display (version))'`
  fi
  AC_MSG_RESULT($GUILE_EFFECTIVE_VERSION)

  case "$GUILE_EFFECTIVE_VERSION" in
    1.0* | 1.1* | 1.2* | 1.3* | 1.4* | 1.5*)
      CONFIG_GUILE_SERIAL="A"
    ;;
    1.6* | 1.7*)
      CONFIG_GUILE_SERIAL="B"
    ;;
    2.*)
      CONFIG_GUILE_SERIAL="D"
      if test "$enable_guile2" != "yes"; then
        AC_MSG_ERROR([TeXmacs is incompatible with Guile 2.
  If you know what you are doing, run configure with --enable-guile2=yes])
      fi
    ;;
    *)
      CONFIG_GUILE_SERIAL="C"
    ;;
  esac

  AC_MSG_CHECKING(guile data path)
  if test -z "$GUILE_DATA_PATH" ; then
    GUILE_DATA_PATH=`$GUILE_CONFIG info pkgdatadir`
  fi
  AC_MSG_RESULT($GUILE_DATA_PATH)

  AC_SUBST(GUILE_BIN)
  AC_SUBST(CONFIG_GUILE_SERIAL)
  AC_SUBST(GUILE_DATA_PATH)
])
