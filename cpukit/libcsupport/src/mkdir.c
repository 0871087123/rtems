/*
 *  mkdir() - POSIX 1003.1b 5.4.1 - Make a Directory
 *
 *  COPYRIGHT (c) 1989-1998.
 *  On-Line Applications Research Corporation (OAR).
 *  Copyright assigned to U.S. Government, 1994.
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */

#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

int mkdir(
  const char *pathname,
  mode_t      mode
)
{
  return mknod( pathname, mode | S_IFDIR, 0LL);
}

