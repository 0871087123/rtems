dnl $Id$

dnl
dnl RTEMS_TOP($1)
dnl 
dnl $1 .. relative path from this configure.in to the toplevel configure.in
dnl
AC_DEFUN(RTEMS_TOP,
[dnl
AC_ARG_WITH(target-subdir,
[  --with-target-subdir=DIR],
TARGET_SUBDIR="$withval",
TARGET_SUBDIR=".")

RTEMS_TOPdir="$1";
AC_SUBST(RTEMS_TOPdir)

PROJECT_ROOT=`pwd`/$RTEMS_TOPdir;
test "$TARGET_SUBDIR" = "." || PROJECT_ROOT="$PROJECT_ROOT/.."
AC_SUBST(PROJECT_ROOT)

dnl Determine RTEMS Version string from the VERSION file
dnl Hopefully, Joel never changes its format ;-
AC_MSG_CHECKING([for RTEMS Version])
if test -r "${srcdir}/${RTEMS_TOPdir}/VERSION"; then
changequote(,)dnl
RTEMS_VERSION=`grep Version ${srcdir}/${RTEMS_TOPdir}/VERSION | \
sed -e 's%RTEMS[ 	]*Version[ 	]*\(.*\)[ 	]*%\1%g'`
changequote([,])dnl
else
AC_MSG_ERROR(Unable to find ${RTEMS_TOPdir}/VERSION)
fi
if test -z "$RTEMS_VERSION"; then
AC_MSG_ERROR(Unable to determine version)
fi
AC_MSG_RESULT($RTEMS_VERSION)

RTEMS_ROOT='$(top_srcdir)'/$RTEMS_TOPdir;
AC_SUBST(RTEMS_ROOT)
])dnl
