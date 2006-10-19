/*
 *  Mutex Handler
 *
 *  DESCRIPTION:
 *
 *  This package is the implementation of the Mutex Handler.
 *  This handler provides synchronization and mutual exclusion capabilities.
 *
 *  COPYRIGHT (c) 1989-2006.
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
#include <rtems/score/isr.h>
#include <rtems/score/coremutex.h>
#include <rtems/score/states.h>
#include <rtems/score/thread.h>
#include <rtems/score/threadq.h>

/*PAGE
 *
 *  _CORE_mutex_Seize (interrupt blocking support)
 *
 *  This routine blocks the caller thread after an attempt attempts to obtain
 *  the specified mutex has failed.
 *
 *  Input parameters:
 *    the_mutex - pointer to mutex control block
 *    timeout   - number of ticks to wait (0 means forever)
 */

void _CORE_mutex_Seize_interrupt_blocking(
  CORE_mutex_Control  *the_mutex,
  Watchdog_Interval    timeout
)
{
  Thread_Control   *executing;

  executing = _Thread_Executing;
  if ( _CORE_mutex_Is_inherit_priority( &the_mutex->Attributes ) ) {
    if ( the_mutex->holder->current_priority > executing->current_priority ) {
      _Thread_Change_priority(
        the_mutex->holder,
        executing->current_priority,
        FALSE
      );
    }
  }

  the_mutex->blocked_count++;
  _Thread_queue_Enqueue( &the_mutex->Wait_queue, timeout );

  _Thread_Enable_dispatch();
}

