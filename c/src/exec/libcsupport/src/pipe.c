/*
 *  pipe() - POSIX 1003.1b 6.1.1 Create an Inter-Process Channel
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

#include <errno.h>

int pipe(
  int filsdes[2]
)
{
  errno = ENOSYS;
  return -1;
}
