--
--  TMTEST / SPECIFICATION
--
--  DESCRIPTION:
--
--  This package is the specification for Test 23 of the RTEMS
--  Timing Test Suite.
--
--  DEPENDENCIES: 
--
--  
--
--  COPYRIGHT (c) 1989, 1990, 1991, 1992, 1993, 1994.
--  On-Line Applications Research Corporation (OAR).
--  All rights assigned to U.S. Government, 1994.
--
--  This material may be reproduced by or for the U.S. Government pursuant
--  to the copyright license under the clause at DFARS 252.227-7013.  This
--  notice must appear in all copies of this file and its derivatives.
--
--  tmtest.ads,v 1.3 1995/07/12 19:44:15 joel Exp
--

with TIMER_DRIVER;
with TIME_TEST_SUPPORT;
with RTEMS;

package TMTEST is

--
--  This array contains the IDs of all RTEMS timers created by this test.
--

   TIMER_ID   : array ( RTEMS.UNSIGNED32 
      range 1 .. TIME_TEST_SUPPORT.OPERATION_COUNT ) of RTEMS.ID;

--
--  This data item contains a time of day used by all of the
--  "WHEN" directives timed in this test.
--

   TIME_OF_DAY      : RTEMS.TIME_OF_DAY;

--
--  The following variable is set to the execution time returned
--  by the timer.
--

   END_TIME  : RTEMS.UNSIGNED32;

--
--  INIT
--
--  DESCRIPTION:
--
--  This RTEMS task initializes the application.
--

   procedure INIT (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  NULL_DELAY
--
--  DESCRIPTION:
--
--  This subprogram is a timer service routine.  It performs
--  no actions.
--

   procedure NULL_DELAY (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   );

--
--  HIGH_TASK
--
--  DESCRIPTION:
--
--  This RTEMS task is responsible for measuring and reporting
--  the following directive execution times:
--
--    + TIMER_CREATE
--    + TIMER_FIRE_AFTER with an inactive timer
--    + TIMER_FIRE_AFTER with an active timer
--    + TIMER_CANCEL of an active timer
--    + TIMER_CANCEL of an inactive timer
--    + TIMER_RESET of an active timer
--    + TIMER_RESET of an inactive timer
--    + TIMER_FIRE_WHEN of an inactive timer
--    + TIMER_FIRE_WHEN of an active timer
--    + TIMER_DELETE of an active timer
--    + TIMER_DELETE of an inactive timer
--
--  After measuring and reporting the above times, this task starts
--  the timer and executes the TASK_WAKE_WHEN directive.
--

   procedure HIGH_TASK (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  MIDDLE_TASKS
--
--  DESCRIPTION:
--
--  These RTEMS tasks executes the TASK_WAKE_WHEN directive.
--

   procedure MIDDLE_TASKS (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  MIDDLE_TASKS
--
--  DESCRIPTION:
--
--  This RTEMS task stops the timer and reports the execution time for
--  the TASK_WAKE_WHEN directive.
--

   procedure LOW_TASK (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  This is the Initialization Tasks Table for this test.
--

   INITIALIZATION_TASKS : aliased RTEMS.INITIALIZATION_TASKS_TABLE( 1 .. 1 ) := 
   (1=>
     (
       RTEMS.BUILD_NAME( 'U', 'I', '1', ' ' ),        -- task name
       2048,                                          -- stack size
       1,                                             -- priority
       RTEMS.DEFAULT_ATTRIBUTES,                      -- attributes
       TMTEST.INIT'ACCESS,                            -- entry point
       RTEMS.NO_PREEMPT,                              -- initial mode
       0                                              -- argument list
     )
   );

--
--  This is the Configuration Table for this test.
--

   CONFIGURATION : aliased RTEMS.CONFIGURATION_TABLE := (
      RTEMS.NULL_ADDRESS,        -- will be replaced by BSP
      256 * 1024,                -- executive RAM size
      111,                       -- maximum # tasks
      110,                       -- maximum # timers
      0,                         -- maximum # semaphores
      0,                         -- maximum # message queues
      0,                         -- maximum # messages
      0,                         -- maximum # partitions
      0,                         -- maximum # regions
      0,                         -- maximum # dp memory areas
      0,                         -- maximum # periods
      0,                         -- maximum # user extensions
      RTEMS.MILLISECONDS_TO_MICROSECONDS(10), -- # us in a tick
      0                          -- # ticks in a timeslice
  );

end TMTEST;
