/*
 *  RTEMS Cache Aligned Malloc
 *
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

#include <rtems.h>
#include <cache_.h>

/*
 *  rtems_cache_aligned_malloc
 *
 *  DESCRIPTION:
 *
 *  This function is used to allocate storage that spans an
 *  integral number of cache blocks.
 */

void *rtems_cache_aligned_malloc (
  size_t nbytes
)
{
  /*
   * Arrange to have the user storage start on the first cache
   * block beyond the header.
   */
#if defined(_CPU_DATA_CACHE_ALIGNMENT)
  return (void *) ((((unsigned long)
     malloc( nbytes + _CPU_DATA_CACHE_ALIGNMENT - 1 ))
        + _CPU_DATA_CACHE_ALIGNMENT - 1 ) &(~(_CPU_DATA_CACHE_ALIGNMENT - 1)) );
#else
  return malloc( nbytes );
#endif
}

