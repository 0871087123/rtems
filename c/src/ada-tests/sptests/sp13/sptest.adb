--
--  SPTEST / BODY
--
--  DESCRIPTION:
--
--  This package is the implementation of Test 13 of the RTEMS
--  Single Processor Test Suite.
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
--  sptest.adb,v 1.3 1995/07/12 19:41:55 joel Exp
--

with BSP;
with INTERFACES; use INTERFACES;
with RTEMS;
with TEST_SUPPORT;
with TEXT_IO;
with UNCHECKED_CONVERSION;
with UNSIGNED32_IO;

package body SPTEST is

--PAGE
-- 
--  INIT
--

   procedure INIT (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      STATUS : RTEMS.STATUS_CODES;
   begin

      TEXT_IO.NEW_LINE( 2 );
      TEXT_IO.PUT_LINE( "*** TEST 13 ***" );

      SPTEST.TASK_NAME( 1 ) := RTEMS.BUILD_NAME(  'T', 'A', '1', ' ' );
      SPTEST.TASK_NAME( 2 ) := RTEMS.BUILD_NAME(  'T', 'A', '2', ' ' );
      SPTEST.TASK_NAME( 3 ) := RTEMS.BUILD_NAME(  'T', 'A', '3', ' ' );

      RTEMS.TASK_CREATE( 
         SPTEST.TASK_NAME( 1 ), 
         4, 
         2048, 
         RTEMS.DEFAULT_MODES,
         RTEMS.DEFAULT_ATTRIBUTES,
         SPTEST.TASK_ID( 1 ),
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_CREATE OF TA1" );

      RTEMS.TASK_CREATE( 
         SPTEST.TASK_NAME( 2 ), 
         4, 
         2048, 
         RTEMS.DEFAULT_MODES,
         RTEMS.DEFAULT_ATTRIBUTES,
         SPTEST.TASK_ID( 2 ),
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_CREATE OF TA2" );

      RTEMS.TASK_CREATE( 
         SPTEST.TASK_NAME( 3 ), 
         4, 
         2048, 
         RTEMS.DEFAULT_MODES,
         RTEMS.DEFAULT_ATTRIBUTES,
         SPTEST.TASK_ID( 3 ),
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_CREATE OF TA3" );

      RTEMS.TASK_START(
         SPTEST.TASK_ID( 1 ),
         SPTEST.TASK_1'ACCESS,
         0,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_START OF TA1" );

      RTEMS.TASK_START(
         SPTEST.TASK_ID( 2 ),
         SPTEST.TASK_2'ACCESS,
         0,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_START OF TA2" );

      RTEMS.TASK_START(
         SPTEST.TASK_ID( 3 ),
         SPTEST.TASK_3'ACCESS,
         0,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_START OF TA3" );

      SPTEST.QUEUE_NAME( 1 ) := RTEMS.BUILD_NAME(  'Q', '1', ' ', ' ' );
      SPTEST.QUEUE_NAME( 2 ) := RTEMS.BUILD_NAME(  'Q', '2', ' ', ' ' );
      SPTEST.QUEUE_NAME( 3 ) := RTEMS.BUILD_NAME(  'Q', '3', ' ', ' ' );

      RTEMS.MESSAGE_QUEUE_CREATE(
         SPTEST.QUEUE_NAME( 1 ),
         0,
         RTEMS.DEFAULT_ATTRIBUTES,
         SPTEST.QUEUE_ID( 1 ),
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "QUEUE_CREATE OF Q1" );

      RTEMS.MESSAGE_QUEUE_CREATE(
         SPTEST.QUEUE_NAME( 2 ),
         10,
         RTEMS.PRIORITY + RTEMS.LIMIT,
         SPTEST.QUEUE_ID( 2 ),
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "QUEUE_CREATE OF Q2" );

      RTEMS.MESSAGE_QUEUE_CREATE(
         SPTEST.QUEUE_NAME( 3 ),
         0,
         RTEMS.DEFAULT_ATTRIBUTES,
         SPTEST.QUEUE_ID( 3 ),
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "QUEUE_CREATE OF Q3" );

      RTEMS.TASK_DELETE( RTEMS.SELF, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_DELETE OF SELF" );

   end INIT;

--PAGE
-- 
--  FILL_BUFFER
--

--
-- Depends on tricks to make the copy work.
--

   procedure FILL_BUFFER (
      SOURCE : in     STRING;
      BUFFER :    out RTEMS.BUFFER
   ) is
      SOURCE_BUFFER : RTEMS.BUFFER_POINTER;
   begin

      SOURCE_BUFFER := RTEMS.TO_BUFFER_POINTER( 
                          SOURCE( SOURCE'FIRST )'ADDRESS 
                       );

      BUFFER.FIELD1 := SOURCE_BUFFER.FIELD1;
      BUFFER.FIELD2 := SOURCE_BUFFER.FIELD2;
      BUFFER.FIELD3 := SOURCE_BUFFER.FIELD3;
      BUFFER.FIELD4 := SOURCE_BUFFER.FIELD4;
      
   end FILL_BUFFER;

--PAGE
-- 
--  PUT_BUFFER
--

--
-- Depends on tricks to make the output work.
--

   procedure PUT_BUFFER (
      BUFFER : in     RTEMS.BUFFER
   ) is
   begin

      TEST_SUPPORT.PUT_NAME( BUFFER.FIELD1, FALSE );
      TEST_SUPPORT.PUT_NAME( BUFFER.FIELD2, FALSE );
      TEST_SUPPORT.PUT_NAME( BUFFER.FIELD3, FALSE );
      TEST_SUPPORT.PUT_NAME( BUFFER.FIELD4, FALSE );
      
   end PUT_BUFFER;

--PAGE
-- 
--  TASK_1
--

   procedure TASK_1 (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      QID            : RTEMS.ID;
      BUFFER         : RTEMS.BUFFER;
      BUFFER_POINTER : RTEMS.BUFFER_POINTER;
      TIMES          : RTEMS.UNSIGNED32;
      COUNT          : RTEMS.UNSIGNED32;
      STATUS         : RTEMS.STATUS_CODES;
   begin

      BUFFER_POINTER := RTEMS.TO_BUFFER_POINTER( BUFFER'ADDRESS );

      RTEMS.MESSAGE_QUEUE_IDENT( 
         SPTEST.QUEUE_NAME( 1 ), 
         RTEMS.SEARCH_ALL_NODES, 
         QID, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_IDENT" );
      TEXT_IO.PUT( "TA1 - message_queue_ident - qid => " );
      UNSIGNED32_IO.PUT( QID, WIDTH => 8, BASE => 16 );
      TEXT_IO.NEW_LINE;

      SPTEST.FILL_BUFFER( "BUFFER 1 TO Q 1 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 1 TO Q 1" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 1 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );
   
      SPTEST.FILL_BUFFER( "BUFFER 2 TO Q 1 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 2 TO Q 1" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 1 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      TEXT_IO.PUT_LINE( "TA1 - task_wake_after - sleep 5 seconds" );
      RTEMS.TASK_WAKE_AFTER( 5 * TEST_SUPPORT.TICKS_PER_SECOND, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_WAKE_AFTER" );
          
      SPTEST.FILL_BUFFER( "BUFFER 3 TO Q 1 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 3 TO Q 1" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 1 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      TEXT_IO.PUT_LINE( "TA1 - task_wake_after - sleep 5 seconds" );
      RTEMS.TASK_WAKE_AFTER( 5 * TEST_SUPPORT.TICKS_PER_SECOND, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_WAKE_AFTER" );
          
TEST_SUPPORT.PAUSE;

      SPTEST.FILL_BUFFER( "BUFFER 1 TO Q 2 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 1 TO Q 2" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 2 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      TEXT_IO.PUT( 
         "TA1 - message_queue_receive - receive from queue 1 - "
      );
      TEXT_IO.PUT_LINE( "10 second timeout" );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 1 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         10 * TEST_SUPPORT.TICKS_PER_SECOND,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA1 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      TEXT_IO.PUT_LINE( "TA1 - task_delete - delete TA2" );
      RTEMS.TASK_DELETE( SPTEST.TASK_ID( 2 ), STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_DELETE" );

      SPTEST.FILL_BUFFER( "BUFFER 1 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 1 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      TEXT_IO.PUT_LINE( "TA1 - task_wake_after - sleep 5 seconds" );
      RTEMS.TASK_WAKE_AFTER( 5 * TEST_SUPPORT.TICKS_PER_SECOND, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_WAKE_AFTER" );
          
TEST_SUPPORT.PAUSE;

      SPTEST.FILL_BUFFER( "BUFFER 2 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 2 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      SPTEST.FILL_BUFFER( "BUFFER 3 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 3 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      SPTEST.FILL_BUFFER( "BUFFER 4 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 4 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      SPTEST.FILL_BUFFER( "BUFFER 5 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_urgent - BUFFER 5 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_URGENT( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_URGENT" );

      for TIMES in 1 .. 4 
      loop
         TEXT_IO.PUT( 
            "TA1 - message_queue_receive - receive from queue 3 - "
         );
         TEXT_IO.PUT_LINE( "WAIT FOREVER" );
         RTEMS.MESSAGE_QUEUE_RECEIVE(
            SPTEST.QUEUE_ID( 3 ),
            BUFFER_POINTER,
            RTEMS.DEFAULT_OPTIONS,
            RTEMS.NO_TIMEOUT,
            STATUS
         );
         TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
         TEXT_IO.PUT( "TA1 - buffer received: " );
         SPTEST.PUT_BUFFER( BUFFER );
         TEXT_IO.NEW_LINE;
      end loop;

      SPTEST.FILL_BUFFER( "BUFFER 3 TO Q 2 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_urgent - BUFFER 3 TO Q 2" );
      RTEMS.MESSAGE_QUEUE_URGENT( 
         SPTEST.QUEUE_ID( 2 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_URGENT" );

      TEXT_IO.PUT( 
        "TA1 - message_queue_receive - receive from queue 2 - " 
      );
      TEXT_IO.PUT_LINE( "WAIT FOREVER" );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 2 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA1 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

TEST_SUPPORT.PAUSE;

      TEXT_IO.PUT_LINE( "TA1 - message_queue_delete - delete queue 1" );
      RTEMS.MESSAGE_QUEUE_DELETE( SPTEST.QUEUE_ID( 1 ), STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_DELETE" );
   
      SPTEST.FILL_BUFFER( "BUFFER 3 TO Q 2 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_urgent - BUFFER 3 TO Q 2" );
      RTEMS.MESSAGE_QUEUE_URGENT( 
         SPTEST.QUEUE_ID( 2 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_URGENT" );

      TEXT_IO.PUT_LINE( "TA1 - message_queue_delete - delete queue 2" );
      RTEMS.MESSAGE_QUEUE_DELETE( SPTEST.QUEUE_ID( 2 ), STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_DELETE" );
   
      TEXT_IO.PUT_LINE( "TA1 - message_queue_flush - empty Q 3" );
      RTEMS.MESSAGE_QUEUE_FLUSH( SPTEST.QUEUE_ID( 3 ), COUNT, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_FLUSH" );
      TEXT_IO.PUT( "TA1 - " );
      UNSIGNED32_IO.PUT( COUNT, WIDTH => 3, BASE => 10 );
      TEXT_IO.PUT_LINE( " messages were flushed from Q 3" );
     
      SPTEST.FILL_BUFFER( "BUFFER 1 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 1 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      SPTEST.FILL_BUFFER( "BUFFER 2 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 2 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      SPTEST.FILL_BUFFER( "BUFFER 3 TO Q 3 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_send - BUFFER 3 TO Q 3" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 3 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );

      TEXT_IO.PUT_LINE( "TA1 - message_queue_flush - Q 3" );
      RTEMS.MESSAGE_QUEUE_FLUSH( SPTEST.QUEUE_ID( 3 ), COUNT, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_FLUSH" );
      TEXT_IO.PUT( "TA1 - " );
      UNSIGNED32_IO.PUT( COUNT, WIDTH => 3, BASE => 10 );
      TEXT_IO.PUT_LINE( " messages were flushed from Q 3" );
     
      TEXT_IO.PUT_LINE( 
         "TA1 - message_queue_send - until all message buffers consumed"
      );
      loop

         RTEMS.MESSAGE_QUEUE_SEND( 
            SPTEST.QUEUE_ID( 3 ), 
            BUFFER_POINTER, 
            STATUS 
         );
         
         exit when RTEMS.ARE_STATUSES_EQUAL( STATUS, RTEMS.UNSATISFIED );

         TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );
         
      end loop;
      TEXT_IO.PUT_LINE( 
         "TA1 - message_queue_send - all message buffers consumed"
      );
      TEXT_IO.PUT_LINE( "TA1 - message_queue_flush - Q 3" );
      RTEMS.MESSAGE_QUEUE_FLUSH( SPTEST.QUEUE_ID( 3 ), COUNT, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_FLUSH" );
      TEXT_IO.PUT( "TA1 - " );
      UNSIGNED32_IO.PUT( COUNT, WIDTH => 3, BASE => 10 );
      TEXT_IO.PUT_LINE( " messages were flushed from Q 3" );
     
      if COUNT /= BSP.CONFIGURATION.MAXIMUM_MESSAGES then
         TEXT_IO.PUT( "TA1 - ERROR - " );
         UNSIGNED32_IO.PUT( COUNT, WIDTH => 3, BASE => 10 );
         TEXT_IO.PUT_LINE( " messages flushed" );
      end if;

      TEXT_IO.PUT_LINE( "*** END OF TEST 13 ***" );
      RTEMS.SHUTDOWN_EXECUTIVE( 0 );

   end TASK_1;

--PAGE
-- 
--  TASK_2
--

   procedure TASK_2 (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      BUFFER            : RTEMS.BUFFER;
      BUFFER_POINTER    : RTEMS.BUFFER_POINTER;
      PREVIOUS_PRIORITY : RTEMS.TASK_PRIORITY;
      STATUS            : RTEMS.STATUS_CODES;
   begin

      BUFFER_POINTER := RTEMS.TO_BUFFER_POINTER( BUFFER'ADDRESS );

      TEXT_IO.PUT_LINE( 
         "TA2 - message_queue_receive - receive from queue 1 - NO_WAIT"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 1 ),
         BUFFER_POINTER,
         RTEMS.NO_WAIT,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA2 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      TEXT_IO.PUT_LINE( 
         "TA2 - message_queue_receive - receive from queue 1 - WAIT FOREVER"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 1 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA2 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      TEXT_IO.PUT_LINE( 
         "TA2 - message_queue_receive - receive from queue 1 - WAIT FOREVER"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 1 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA2 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      TEXT_IO.PUT_LINE( 
         "TA2 - task_set_priority - make self highest priority task"
      );
      RTEMS.TASK_SET_PRIORITY(
         RTEMS.SELF,
         3,
         PREVIOUS_PRIORITY,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_SET_PRIORITY" );

      TEXT_IO.PUT_LINE( 
         "TA2 - message_queue_receive - receive from queue 2 - WAIT FOREVER"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 2 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA2 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      SPTEST.FILL_BUFFER( "BUFFER 2 TO Q 2 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA2 - message_queue_send - BUFFER 2 TO Q 2" );
      RTEMS.MESSAGE_QUEUE_SEND( 
         SPTEST.QUEUE_ID( 2 ), 
         BUFFER_POINTER, 
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_SEND" );
   
      TEXT_IO.PUT_LINE( 
    "TA2 - message_queue_receive - receive from queue 1 - 10 second timeout"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 1 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         10 * TEST_SUPPORT.TICKS_PER_SECOND,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA2 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      TEXT_IO.PUT_LINE( 
         "TA2 - message_queue_receive - receive from queue 3 - WAIT FOREVER"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 3 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA2 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

   end TASK_2;

--PAGE
-- 
--  TASK_3
--

   procedure TASK_3 (
      ARGUMENT : in     RTEMS.TASK_ARGUMENT
   ) is
      BUFFER         : RTEMS.BUFFER;
      BUFFER_POINTER : RTEMS.BUFFER_POINTER;
      COUNT          : RTEMS.UNSIGNED32;
      STATUS         : RTEMS.STATUS_CODES;
   begin

      BUFFER_POINTER := RTEMS.TO_BUFFER_POINTER( BUFFER'ADDRESS );

      TEXT_IO.PUT_LINE( 
         "TA3 - message_queue_receive - receive from queue 2 - WAIT FOREVER"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 2 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA3 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      SPTEST.FILL_BUFFER( "BUFFER 3 TO Q 1 ", BUFFER );
      TEXT_IO.PUT_LINE( "TA3 - message_queue_broadcast - BUFFER 3 TO Q 1" );
      RTEMS.MESSAGE_QUEUE_BROADCAST( 
         SPTEST.QUEUE_ID( 1 ), 
         BUFFER_POINTER, 
         COUNT,
         STATUS 
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_BROADCAST" );
      TEXT_IO.PUT( "TA3 - number of tasks awakened = " );
      UNSIGNED32_IO.PUT( COUNT, WIDTH => 3, BASE => 10 );
      TEXT_IO.NEW_LINE;
     
      TEXT_IO.PUT_LINE( 
         "TA3 - message_queue_receive - receive from queue 3 - WAIT FOREVER"
      );
      RTEMS.MESSAGE_QUEUE_RECEIVE(
         SPTEST.QUEUE_ID( 3 ),
         BUFFER_POINTER,
         RTEMS.DEFAULT_OPTIONS,
         RTEMS.NO_TIMEOUT,
         STATUS
      );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "MESSAGE_QUEUE_RECEIVE" );
      TEXT_IO.PUT( "TA3 - buffer received: " );
      SPTEST.PUT_BUFFER( BUFFER );
      TEXT_IO.NEW_LINE;

      TEXT_IO.PUT_LINE( "TA3 - task_delete - delete self" );
      RTEMS.TASK_DELETE( RTEMS.SELF, STATUS );
      TEST_SUPPORT.DIRECTIVE_FAILED( STATUS, "TASK_DELETE OF SELF" );

   end TASK_3;

end SPTEST;
