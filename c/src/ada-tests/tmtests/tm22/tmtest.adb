--
--  TMTEST / BODY
--
--  DESCRIPTION:
--
--  This package is the implementation of Test 22 of the RTEMS
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
--  tmtest.adb,v 1.3 1995/07/12 19:44:10 joel Exp
--

with INTERFACES; use INTERFACES;
with RTEMS;
with RTEMS_CALLING_OVERHEAD;
with TEST_SUPPORT;
with TEXT_IO;
with TIME_TEST_SUPPORT;
with UNSIGNED32_IO;

package body TMTEST is

--PAGE
-- 
--  INIT
--

   procedure INIT (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      ID     : RTEMS.ID;
      STATUS : RTEMS.STATUS_CODES;
   begin

      TEXT_IO.NEW_LINE( 2 );
      TEXT_IO.PUT_LINE( "*** TIME TEST 22 ***" );

      RTEMS.MESSAGE_QUEUE_CREATE( 
         RTEMS.BUILD_NAME( 'M', 'Q', '1', ' ' ),
         0,
         RTEMS.DEFAULT_ATTRIBUTES,
         TMTEST.MESSAGE_QUEUE_ID,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_CREATE" );

      RTEMS.TASK_CREATE( 
         RTEMS.BUILD_NAME( 'L', 'O', 'W', ' ' ), 
         10,
         2048, 
         RTEMS.NO_PREEMPT,
         RTEMS.DEFAULT_ATTRIBUTES,
         ID,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_CREATE LOW" );

      RTEMS.TASK_START( ID, TMTEST.LOW_TASK'ACCESS, 0, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_START LOW" );

      RTEMS.TASK_CREATE( 
         RTEMS.BUILD_NAME( 'P', 'R', 'M', 'T' ),
         11,
         2048, 
         RTEMS.DEFAULT_MODES,
         RTEMS.DEFAULT_ATTRIBUTES,
         ID,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_CREATE PREEMPT" );

      RTEMS.TASK_START( ID, TMTEST.PREEMPT_TASK'ACCESS, 0, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_START PREEMPT" );

      RTEMS.TASK_DELETE( RTEMS.SELF, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_DELETE OF SELF" );

   end INIT;

--PAGE
-- 
--  HIGH_TASK
--

   procedure HIGH_TASK (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      BUFFER         : RTEMS.BUFFER;
      BUFFER_POINTER : RTEMS.BUFFER_POINTER;
      COUNT          : RTEMS.UNSIGNED32;
      STATUS         : RTEMS.STATUS_CODES;
   begin

      BUFFER_POINTER := RTEMS.TO_BUFFER_POINTER( BUFFER'ADDRESS );

      TIMER_DRIVER.INITIALIZE;
         RTEMS.MESSAGE_QUEUE_BROADCAST(
            TMTEST.MESSAGE_QUEUE_ID,
            BUFFER_POINTER,
            COUNT,
            STATUS 
         );
      TMTEST.END_TIME := TIMER_DRIVER.READ_TIMER;

      TIME_TEST_SUPPORT.PUT_TIME( 
         "MESSAGE_QUEUE_BROADCAST (readying)", 
         TMTEST.END_TIME, 
         1,
         0,
         RTEMS_CALLING_OVERHEAD.MESSAGE_QUEUE_BROADCAST
      );

      RTEMS.TASK_SUSPEND( RTEMS.SELF, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_SUSPEND" );

   end HIGH_TASK;

--PAGE
-- 
--  LOW_TASK
--

   procedure LOW_TASK (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      ID             : RTEMS.ID;
      BUFFER         : RTEMS.BUFFER;
      BUFFER_POINTER : RTEMS.BUFFER_POINTER;
      INDEX          : RTEMS.UNSIGNED32;
      OVERHEAD       : RTEMS.UNSIGNED32;
      COUNT          : RTEMS.UNSIGNED32;
      STATUS         : RTEMS.STATUS_CODES;
   begin

      BUFFER_POINTER := RTEMS.TO_BUFFER_POINTER( BUFFER'ADDRESS );

      RTEMS.TASK_CREATE( 
         RTEMS.BUILD_NAME( 'H', 'I', 'G', 'H' ), 
         5,
         2048, 
         RTEMS.NO_PREEMPT,
         RTEMS.DEFAULT_ATTRIBUTES,
         ID,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_CREATE HIGH" );

      RTEMS.TASK_START( ID, TMTEST.HIGH_TASK'ACCESS, 0, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_START HIGH" );

      RTEMS.MESSAGE_QUEUE_RECEIVE(
         TMTEST.MESSAGE_QUEUE_ID,
         BUFFER_POINTER,
         RTEMS.DEFAULT_MODES,
         RTEMS.NO_TIMEOUT,
         STATUS
      );

      TIMER_DRIVER.INITIALIZE;
         for INDEX in 1 .. TIME_TEST_SUPPORT.OPERATION_COUNT
         loop
            TIMER_DRIVER.EMPTY_FUNCTION;
         end loop;
      OVERHEAD := TIMER_DRIVER.READ_TIMER;

      TIMER_DRIVER.INITIALIZE;
         for INDEX in 1 .. TIME_TEST_SUPPORT.OPERATION_COUNT
         loop
            RTEMS.MESSAGE_QUEUE_BROADCAST(
               TMTEST.MESSAGE_QUEUE_ID,
               BUFFER_POINTER,
               COUNT,
               STATUS 
            );
         end loop;
      TMTEST.END_TIME := TIMER_DRIVER.READ_TIMER;

      TIME_TEST_SUPPORT.PUT_TIME( 
         "MESSAGE_QUEUE_BROADCAST (no waiting tasks)",
         TMTEST.END_TIME, 
         TIME_TEST_SUPPORT.OPERATION_COUNT, 
         OVERHEAD,
         RTEMS_CALLING_OVERHEAD.MESSAGE_QUEUE_BROADCAST
      );

      RTEMS.MESSAGE_QUEUE_RECEIVE(
         TMTEST.MESSAGE_QUEUE_ID,
         BUFFER_POINTER,
         RTEMS.DEFAULT_MODES,
         RTEMS.NO_TIMEOUT,
         STATUS
      );

      -- should go to PREEMPT_TASK here

      TMTEST.END_TIME := TIMER_DRIVER.READ_TIMER;

      TIME_TEST_SUPPORT.PUT_TIME( 
         "MESSAGE_QUEUE_BROADCAST (preempt)",
         TMTEST.END_TIME, 
         1,
         0,
         RTEMS_CALLING_OVERHEAD.MESSAGE_QUEUE_BROADCAST
      );

      RTEMS.SHUTDOWN_EXECUTIVE( 0 );

   end LOW_TASK;

--PAGE
-- 
--  LOW_TASK
--

   procedure PREEMPT_TASK (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      BUFFER         : RTEMS.BUFFER;
      BUFFER_POINTER : RTEMS.BUFFER_POINTER;
      COUNT          : RTEMS.UNSIGNED32;
      STATUS         : RTEMS.STATUS_CODES;
   begin

      BUFFER_POINTER := RTEMS.TO_BUFFER_POINTER( BUFFER'ADDRESS );

      TIMER_DRIVER.INITIALIZE;
         RTEMS.MESSAGE_QUEUE_BROADCAST(
            TMTEST.MESSAGE_QUEUE_ID,
            BUFFER_POINTER,
            COUNT,
            STATUS 
         );

      -- should be preempted by LOW_TASK

   end PREEMPT_TASK;

end TMTEST;
