/*
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */

#include <itron.h>

#include <rtems/score/thread.h>
#include <rtems/score/userext.h>
#include <rtems/score/wkspace.h>
#include <rtems/score/apiext.h>
#include <rtems/score/sysstate.h>

#include <rtems/itron/task.h>

/*
 *  get_tid - Get Task Identifier
 */

ER get_tid(
  ID *p_tskid
)
{
  /*
   *  This does not support multiprocessing.  The id handling will have
   *  to be enhanced to support multiprocessing.
   */
   
  *p_tskid = _Objects_Get_index( _Thread_Executing->Object.id );
  return E_OK;
}

