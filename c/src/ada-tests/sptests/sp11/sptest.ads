--
--  SPTEST / SPECIFICATION
--
--  DESCRIPTION:
--
--  This package is the specification for Test 11 of the RTEMS
--  Single Processor Test Suite.
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

with CLOCK_DRIVER;
with RTEMS;

package SPTEST is

--
--  These arrays contain the IDs and NAMEs of all RTEMS tasks created
--  by this test.
--

   TASK_ID   : array ( RTEMS.UNSIGNED32 range 1 .. 3 ) of RTEMS.ID;
   TASK_NAME : array ( RTEMS.UNSIGNED32 range 1 .. 3 ) of RTEMS.NAME;

--
--  These arrays contain the IDs and NAMEs of all RTEMS timers created
--  by this test.
--

   TIMER_ID   : array ( RTEMS.UNSIGNED32 range 1 .. 6 ) of RTEMS.ID;
   TIMER_NAME : array ( RTEMS.UNSIGNED32 range 1 .. 6 ) of RTEMS.NAME;

--
--  TA1_SEND_18_TO_SELF_5_SECONDS
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer after 5 seconds
--  and to send EVENT_18 to TASK_1.
--

   procedure TA1_SEND_18_TO_SELF_5_SECONDS (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

--
--  TA1_SEND_8_TO_SELF_60_SECONDS
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer after 60 seconds
--  and to send EVENT_8 to TASK_1.
--

   procedure TA1_SEND_8_TO_SELF_60_SECONDS (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

--
--  TA1_SEND_9_TO_SELF_5_SECONDS
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer after 60 seconds
--  and to send EVENT_9 to TASK_1.
--

   procedure TA1_SEND_9_TO_SELF_60_SECONDS (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

--
--  TA1_SEND_10_TO_SELF
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer after 60 seconds
--  and to send EVENT_10 to TASK_1.
--

   procedure TA1_SEND_10_TO_SELF (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

--
--  TA1_SEND_1_TO_SELF_EVERY_SECOND
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer every second
--  and to send EVENT_1 to TASK_1 until the timer is cancelled.
--

   procedure TA1_SEND_1_TO_SELF_EVERY_SECOND (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

--
--  TA1_SEND_11_TO_SELF
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer at a
--  specific time of day and to send EVENT_11 to TASK_1.
--

   procedure TA1_SEND_11_TO_SELF (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

--
--  TA2_SEND_10_TO_SELF
--
--  DESCRIPTION:
--
--  This subprogram is scheduled to be fired by a timer after 5 seconds
--  and to send EVENT_10 to TASK_2.
--

   procedure TA2_SEND_10_TO_SELF (
      IGNORED_ID      : in     RTEMS.ID;  
      IGNORED_ADDRESS : in     RTEMS.ADDRESS 
   ); 

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
--  TASK_1
--
--  DESCRIPTION:
--
--  This RTEMS task tests the Event and Timer Managers.
--

   procedure TASK_1 (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  TASK_2
--
--  DESCRIPTION:
--
--  This RTEMS task tests the Event and Timer Managers.
--

   procedure TASK_2 (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   );

--
--  This is the Driver Address Table for this test.
--

   DEVICE_DRIVERS : aliased RTEMS.DRIVER_ADDRESS_TABLE( 1 .. 1 ) :=
   (1=>
      (
        CLOCK_DRIVER.INITIALIZE'ACCESS,              -- Initialization
        RTEMS.NO_DRIVER_ENTRY,                       -- Open
        RTEMS.NO_DRIVER_ENTRY,                       -- Close
        RTEMS.NO_DRIVER_ENTRY,                       -- Read
        RTEMS.NO_DRIVER_ENTRY,                       -- Write
        RTEMS.NO_DRIVER_ENTRY                        -- Control
      )
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
       SPTEST.INIT'ACCESS,                            -- entry point
       RTEMS.NO_PREEMPT,                              -- initial mode
       0                                              -- argument list
     )
   );

--
--  This is the Configuration Table for this test.
--

   CONFIGURATION : aliased RTEMS.CONFIGURATION_TABLE := (
      RTEMS.NULL_ADDRESS,        -- will be replaced by BSP
      64 * 1024,                 -- executive RAM size
      10,                        -- maximum # tasks
      6,                         -- maximum # timers
      0,                         -- maximum # semaphores
      0,                         -- maximum # message queues
      0,                         -- maximum # messages
      0,                         -- maximum # partitions
      0,                         -- maximum # regions
      0,                         -- maximum # dp memory areas
      0,                         -- maximum # periods
      0,                         -- maximum # user extensions
      RTEMS.MILLISECONDS_TO_MICROSECONDS(10), -- # us in a tick
      100                        -- # ticks in a timeslice
  );

end SPTEST;
