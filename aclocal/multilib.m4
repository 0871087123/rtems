dnl This provides configure definitions used for multilib support

dnl parts of these macros are derived from newlib-1.8.2's multilib support

AC_DEFUN(RTEMS_ENABLE_MULTILIB,
[
AC_ARG_ENABLE(multilib,
[  --enable-multilib         build many library versions (default)],
[case "${enableval}" in
  yes) multilib=yes ;;
  no)  multilib=no ;;
  *)   AC_MSG_ERROR(bad value ${enableval} for multilib option) ;;
 esac], [multilib=no])dnl

AM_CONDITIONAL(MULTILIB,test x"${multilib}" = x"yes")
])

AC_DEFUN(RTEMS_ENABLE_MULTILIB_MASTER,
[
AC_REQUIRE([RTEMS_ENABLE_MULTILIB])

dnl We may get other options which we don't document:
dnl --with-target-subdir, --with-multisrctop, --with-multisubdir

if test "[$]{srcdir}" = "."; then
  if test "[$]{with_target_subdir}" != "."; then
    multilib_basedir="[$]{srcdir}/[$]{with_multisrctop}../ifelse([$2],,,[$2])"
  else
    multilib_basedir="[$]{srcdir}/[$]{with_multisrctop}ifelse([$2],,,[$2])"
  fi
else
  multilib_basedir="[$]{srcdir}/ifelse([$2],,,[$2])"
fi
AC_SUBST(multilib_basedir)

if test "${multilib}" = "yes"; then
  multilib_arg="--enable-multilib"
else
  multilib_arg=
fi

AC_OUTPUT_COMMANDS(
[if test -n "$CONFIG_FILES"; then
    ac_file=]ifelse([$1],,Makefile,[$1])[ \
      . ${multilib_basedir}/../config-ml.in
fi],[
  srcdir=${srcdir}
  host=${host}
  target=${target}
  with_multisrctop="${with_multisrctop}"
  with_target_subdir="${with_target_subdir}"
  with_multisubdir="${with_multisubdir}"
  ac_configure_args="${multilib_arg} ${ac_configure_args}"
  CONFIG_SHELL=${CONFIG_SHELL-/bin/sh}
  multilib_basedir=${multilib_basedir}
  CC="${CC}"])
])
