/*
 *  16.1.6 Get Calling Thread's ID, p1003.1c/Draft 10, p. 152
 *
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */


#include <pthread.h>
#include <errno.h>

#include <rtems/system.h>
#include <rtems/score/thread.h>

pthread_t pthread_self( void )
{
  return _Thread_Executing->Object.id;
}
