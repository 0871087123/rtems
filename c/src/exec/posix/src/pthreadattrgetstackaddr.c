/*
 *  16.1.1 Thread Creation Attributes, P1003.1c/Draft 10, p, 140
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


#include <pthread.h>
#include <errno.h>

int pthread_attr_getstackaddr(
  const pthread_attr_t   *attr,
  void                  **stackaddr
)
{
  if ( !attr || !attr->is_initialized || !stackaddr )
    return EINVAL;

  *stackaddr = attr->stackaddr;
  return 0;
}
