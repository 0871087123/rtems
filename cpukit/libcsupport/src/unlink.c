/*
 *  unlink() - POSIX 1003.1b - 5.5.1 - Remove an existing link
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

#include "libio_.h"

int unlink( 
  const char *path 
)
{
  rtems_filesystem_location_info_t  loc;
  int                               result;

  /*
   * Get the node to be unlinked.
   */

  result = rtems_filesystem_evaluate_path( path, 0, &loc, FALSE );
  if ( result != 0 )
     return -1;
  
  if ( !loc.ops->node_type )
    set_errno_and_return_minus_one( ENOTSUP );

  if (  (*loc.ops->node_type)( &loc ) == RTEMS_FILESYSTEM_DIRECTORY )
    set_errno_and_return_minus_one( EISDIR );
  
  if ( !loc.ops->unlink )
    set_errno_and_return_minus_one( ENOTSUP );

  return (*loc.ops->unlink)( &loc );
}

/*
 *  _unlink_r
 *
 *  This is the Newlib dependent reentrant version of unlink().
 */

#if defined(RTEMS_NEWLIB)

#include <reent.h>

int _unlink_r(
  struct _reent *ptr,
  const char    *path
)
{
  return unlink( path );
}
#endif

