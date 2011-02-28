/**
 *  @file  rtems/score/schedulerpriority.h
 *
 *  This include file contains all the constants and structures associated
 *  with the manipulation of threads for the priority-based scheduler.
 */

/*
 *  Copryight (c) 2010 Gedare Bloom.
 *  Copyright (C) 2011 On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

#ifndef _RTEMS_SCORE_SCHEDULERPRIORITY_H
#define _RTEMS_SCORE_SCHEDULERPRIORITY_H

#include <rtems/score/chain.h>
#include <rtems/score/priority.h>
#include <rtems/score/scheduler.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  @addtogroup ScoreScheduler
 *
 */
/**@{*/

/**
 *  Entry points for the Deterministic Priority Based Scheduler.
 */
#define SCHEDULER_PRIORITY_ENTRY_POINTS \
  { \
    _Scheduler_priority_Initialize, /* initialize entry point */ \
    _Scheduler_priority_Schedule,   /* schedule entry point */ \
    _Scheduler_priority_Yield,      /* yield entry point */ \
    _Scheduler_priority_Block,      /* block entry point */ \
    _Scheduler_priority_Unblock,    /* unblock entry point */ \
    _Scheduler_priority_Allocate,   /* allocate entry point */ \
    _Scheduler_priority_Free,       /* free entry point */ \
    _Scheduler_priority_Update,     /* update entry point */ \
    _Scheduler_priority_Enqueue,    /* enqueue entry point */ \
    _Scheduler_priority_Enqueue,    /* enqueue_first entry point */ \
    _Scheduler_priority_Extract     /* extract entry point */ \
  }

/**
 * Per-thread data related to the _Scheduler_PRIORITY scheduling policy.
 */
typedef struct {
  /** This field points to the Ready FIFO for this thread's priority. */
  Chain_Control                        *ready_chain;

  /** This field contains precalculated priority map indices. */
  Priority_bit_map_Information          Priority_map;
} Scheduler_priority_Per_thread;

/**
 * This routine initializes the priority scheduler.
 */
void _Scheduler_priority_Initialize(void);

/**
 *  This routine removes @a the_thread from the scheduling decision, 
 *  that is, removes it from the ready queue.  It performs
 *  any necessary scheduling operations including the selection of
 *  a new heir thread.
 *
 *  @param[in] the_thread is the thread to be blocked
 */
void _Scheduler_priority_Block( 
  Thread_Control    *the_thread 
);

/**
 *  This kernel routine sets the heir thread to be the next ready thread 
 *  by invoking the_scheduler->ready_queue->operations->first().
 */
void _Scheduler_priority_Schedule(void);

/**
 *  This routine allocates @a the_thread->scheduler.
 *
 *  @param[in] the_thread is the thread the scheduler is allocating
 *             management memory for
 */
void * _Scheduler_priority_Allocate(
  Thread_Control      *the_thread
);

/**
 *  This routine frees @a the_thread->scheduler.
 *
 *  @param[in] the_thread is the thread whose scheduler specific information
 *             will be deallocated.
 */
void _Scheduler_priority_Free(
  Thread_Control      *the_thread
);

/**
 *  This routine updates @a the_thread->scheduler based on @a the_scheduler 
 *  structures and thread state.
 *
 *  @param[in] the_thread will have its scheduler specific information
 *             structure updated.
 */
void _Scheduler_priority_Update(
  Thread_Control      *the_thread
);

/**
 *  This routine adds @a the_thread to the scheduling decision, 
 *  that is, adds it to the ready queue and 
 *  updates any appropriate scheduling variables, for example the heir thread.
 *
 *  @param[in] the_thread will be unblocked
 */
void _Scheduler_priority_Unblock(
  Thread_Control    *the_thread 
);

/**
 *  This routine is invoked when a thread wishes to voluntarily
 *  transfer control of the processor to another thread in the queue.
 *
 *  This routine will remove the running THREAD from the ready queue
 *  and place it immediately at the rear of this chain.  Reset timeslice
 *  and yield the processor functions both use this routine, therefore if
 *  reset is true and this is the only thread on the queue then the
 *  timeslice counter is reset.  The heir THREAD will be updated if the
 *  running is also the currently the heir.
 */
void _Scheduler_priority_Yield( void );

/**
 *  This routine puts @a the_thread on to the priority-based ready queue.
 *
 *  @param[in] the_thread will be enqueued at the TAIL of its priority.
 */
void _Scheduler_priority_Enqueue(
  Thread_Control    *the_thread
);

/**
 *  This routine puts @a the_thread to the head of the ready queue. 
 *  For priority-based ready queues, the thread will be the first thread
 *  at its priority level.
 *
 *  @param[in] the_thread will be enqueued at the HEAD of its priority.
 */
void _Scheduler_priority_Enqueue_first(
  Thread_Control    *the_thread
);

/**
 *  This routine removes a specific thread from the scheduler's set
 *  of ready threads.
 *
 *  @param[in] the_thread will be extracted from the ready set.
 */
void _Scheduler_priority_Extract(
  Thread_Control     *the_thread
);

/**
 *  This is the major bit map.
 */
extern volatile Priority_bit_map_Control _Priority_Major_bit_map;

/**
 *  This is the minor bit map.
 */
extern Priority_bit_map_Control _Priority_Bit_map[16] CPU_STRUCTURE_ALIGNMENT;

#ifndef __RTEMS_APPLICATION__
#include <rtems/score/schedulerpriority.inl>
#endif

#ifdef __cplusplus
}
#endif

/**@}*/

#endif
/* end of include file */
