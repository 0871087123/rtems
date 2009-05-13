/**
 *  COPYRIGHT (c) 1989-2007.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

#if HAVE_CONFIG_H
#include "config.h"
#endif

#include <rtems/system.h>
#include <rtems/score/protectedheap.h>

bool _Protected_heap_Get_information(
  Heap_Control            *the_heap,
  Heap_Information_block  *the_info
)
{
  Heap_Get_information_status status;

  if ( !the_heap )
    return false;

  if ( !the_info )
    return false;

  _RTEMS_Lock_allocator();
    status = _Heap_Get_information( the_heap, the_info );
  _RTEMS_Unlock_allocator();

  if ( status == HEAP_GET_INFORMATION_SUCCESSFUL )
    return true;

  return false;
}
