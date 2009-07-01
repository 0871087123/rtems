/*  COPYRIGHT (c) 1989-2009.
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

#include <pthread.h>
#include <errno.h>

#include <rtems/system.h>
#include <rtems/posix/pthread.h>
#include <rtems/posix/priority.h>
#include <rtems/posix/time.h>

int _POSIX_Thread_Translate_sched_param(
  int                                  policy,
  struct sched_param                  *param,
  Thread_CPU_budget_algorithms        *budget_algorithm,
  Thread_CPU_budget_algorithm_callout *budget_callout
)
{
  if ( !_POSIX_Priority_Is_valid( param->sched_priority ) )
    return EINVAL;

  *budget_algorithm = THREAD_CPU_BUDGET_ALGORITHM_NONE;
  *budget_callout = NULL;

  switch ( policy ) {
    case SCHED_OTHER:
      *budget_algorithm = THREAD_CPU_BUDGET_ALGORITHM_RESET_TIMESLICE;
      break;

    case SCHED_FIFO:
      *budget_algorithm = THREAD_CPU_BUDGET_ALGORITHM_NONE;
      break;

    case SCHED_RR:
      *budget_algorithm = THREAD_CPU_BUDGET_ALGORITHM_EXHAUST_TIMESLICE;
      break;

    case SCHED_SPORADIC:
      *budget_algorithm  = THREAD_CPU_BUDGET_ALGORITHM_CALLOUT;
      *budget_callout = _POSIX_Threads_Sporadic_budget_callout;

      if ( _Timespec_To_ticks( &param->ss_replenish_period ) <
           _Timespec_To_ticks( &param->ss_initial_budget ) )
        return EINVAL;

      if ( !_POSIX_Priority_Is_valid( param->ss_low_priority ) )
        return EINVAL;
      break;

    default:
      return EINVAL;
  }
  return 0;
}