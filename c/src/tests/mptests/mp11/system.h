/*  system.h
 *
 *  This include file contains information that is included in every
 *  function in the test set.
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

#include <tmacros.h>

/* functions */

rtems_task Init(
  rtems_task_argument argument
);

/* configuration information */
 
#define CONFIGURE_MP_APPLICATION
 
#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER

#define CONFIGURE_MP_MAXIMUM_GLOBAL_OBJECTS     0
#define CONFIGURE_MP_MAXIMUM_PROXIES            0
 
#define CONFIGURE_MAXIMUM_TASKS               1
#if ( NODE_NUMBER == 1 )
#define CONFIGURE_MAXIMUM_SEMAPHORES          1
#define CONFIGURE_MAXIMUM_MESSAGE_QUEUES      1
#define CONFIGURE_MAXIMUM_PARTITIONS          1
#endif

#define CONFIGURE_RTEMS_INIT_TASKS_TABLE

#include <confdefs.h>

/* variables */

TEST_EXTERN rtems_id   Task_id[ 4 ];     /* array of task ids */
TEST_EXTERN rtems_name Task_name[ 4 ];   /* array of task names */

TEST_EXTERN rtems_id   Queue_id[ 2 ];       /* array of message queue ids */
TEST_EXTERN rtems_name Queue_name[ 2 ];     /* array of message queue names */
 
TEST_EXTERN rtems_id   Semaphore_id[ 2 ];   /* array of semaphore ids */
TEST_EXTERN rtems_name Semaphore_name[ 2 ]; /* array of semaphore names */

/* end of include file */
