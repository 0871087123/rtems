dnl $Id$

# PROJECT_ROOT .. Directory to put the temporary installed files into

# FIXME: to be revisited - featureladden, bloated 
AC_DEFUN([RTEMS_ENV_RTEMSCPU],
[
  AC_REQUIRE([RTEMS_ENABLE_MULTILIB])

  AS_IF([test -n "$enable_rtemsbsp"],
  [ # Per BSP
    AC_ARG_VAR([CPU_CFLAGS],[])
    AC_ARG_VAR([CFLAGS_OPTIMIZE_V],
      [CFLAGS for building the optimized variant])
    AC_ARG_VAR([CFLAGS_DEBUG_V],
      [CFLAGS for building the debugging variant])
 
    AC_MSG_CHECKING([for RTEMS_BSP])
    AC_CACHE_VAL(rtems_cv_RTEMS_BSP,[
      test -n "${RTEMS_BSP}" && rtems_cv_RTEMS_BSP="$enable_rtemsbsp"
    ])
    AS_IF([test -z "$rtems_cv_RTEMS_BSP"],[
      AC_MSG_ERROR([Missing RTEMS_BSP])
    ])
    RTEMS_BSP="$rtems_cv_RTEMS_BSP"
    AC_MSG_RESULT(${RTEMS_BSP})

    includedir="\${exec_prefix}/${RTEMS_BSP}/lib/include"
    libdir="\${exec_prefix}/${RTEMS_BSP}/lib"
  ],[
    includedir="\${exec_prefix}/include"
    libdir="${libdir}\$(MULTISUBDIR)"
  ])

  AC_SUBST([project_libdir],["\$(libdir)"])
  AC_SUBST([project_includedir],["\$(includedir)"])

  AM_CONDITIONAL([MULTILIB],[test x"$multilib" = x"yes"])
])
