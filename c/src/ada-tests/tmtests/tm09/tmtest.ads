--
--  TMTEST / SPECIFICATION
--
--  DESCRIPTION:
--
--  This package is the specification for Test 9 of the RTEMS
--  Timing Test Suite.
--
--  DEPENDENCIES: 
--
--  
--
--  COPYRIGHT (c) 1989-1997.
--  On-Line Applications Research Corporation (OAR).
--  Copyright assigned to U.S. Government, 1994.
--
--  The license and distribution terms for this file may in
--  the file LICENSE in this distribution or at
--  http://www.OARcorp.com/rtems/license.html.
--
--  $Id$
--

with TIMER_DRIVER;
with RTEMS;

package TMTEST is

--
--  The following is the ID of the message queue used for timing operations.
--

   QUEUE_ID  : RTEMS.ID;

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
--  TEST_TASK
--
--  DESCRIPTION:
--
--  This RTEMS task is responsible for measuring and reporting the
--  following directive execution times:
--
--    + MESSAGE_QUEUE_CREATE
--    + MESSAGE_QUEUE_DELETE
--

   procedure TEST_TASK (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  QUEUE_TEST
--
--  DESCRIPTION:
--
--  This subprogram is responsible for measuring and reporting the
--  following directive execution times:
--
--    + MESSAGE_QUEUE_SEND with no tasks waiting
--    + MESSAGE_QUEUE_URGENT with no tasks waiting
--    + MESSAGE_QUEUE_RECEIVE with messages available
--    + MESSAGE_QUEUE_FLUSH with an empty message queue
--    + MESSAGE_QUEUE_FLUSH with messages flushed
--

   procedure QUEUE_TEST;

end TMTEST;
