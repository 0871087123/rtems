/*
 *  This include file contains all board IO definitions.
 *
 *  sh4 simulator bsp
 *
 *  Copyright (C) 2001 OKTET Ltd., St.-Petersburg, Russia
 *  Author: Victor V. Vengerov <vvv@oktet.ru>
 *          Alexandra Kossovsky <sasha@oktet.ru>
 *
 *  Based on work:
 *  Author: Ralf Corsepius (corsepiu@faw.uni-ulm.de)
 *
 *  COPYRIGHT (c) 1997-1998, FAW Ulm, Germany
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *
 *  COPYRIGHT (c) 1998-2001.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  Minor adaptations for sh2 by:
 *  John M. Mills (jmills@tga.com)
 *  TGA Technologies, Inc.
 *  100 Pinnacle Way, Suite 140
 *  Norcross, GA 30071 U.S.A.
 *
 *  This modified file may be copied and distributed in accordance
 *  the above-referenced license. It is provided for critique and
 *  developmental purposes without any warranty nor representation
 *  by the authors or by TGA Technologies.
 *
 *  $Id$
 */

#ifndef __simsh4_h
#define __simsh4_h

#ifdef __cplusplus
extern "C" {
#endif

#include <rtems.h>
#include <rtems/clockdrv.h>
#include <rtems/console.h>
#include <ramdisk.h>

#include <bspopts.h>

/*
 *  confdefs.h overrides for this BSP:
 *   - number of termios serial ports (defaults to 1)
 *   - Interrupt stack space is not minimum if defined.
 */

#define CONFIGURE_NUMBER_OF_TERMIOS_PORTS 1
#define CONFIGURE_INTERRUPT_STACK_MEMORY  (4 * 1024)

/* !!! Should be defined in accordance to simulator considerations.*/
#define CLOCK_VECTOR 32

/*
 *  Define the time limits for RTEMS Test Suite test durations.
 *  Long test and short test duration limits are provided.  These
 *  values are in seconds and need to be converted to ticks for the
 *  application.
 *
 */

#define MAX_LONG_TEST_DURATION       300 /* 5 minutes = 300 seconds */
#define MAX_SHORT_TEST_DURATION      3   /* 3 seconds */

/*
 *  Stuff for Time Test 27
 */

#define MUST_WAIT_FOR_INTERRUPT 0

#define Install_tm27_vector( handler ) \
{ \
  rtems_isr_entry ignored ; \
  rtems_interrupt_catch( (handler), 0, &ignored ) ; \
}

#define Cause_tm27_intr()

#define Clear_tm27_intr()

#define Lower_tm27_intr()

/* Constants */

/*
 *  Simple spin delay in microsecond units for device drivers.
 *  This is very dependent on the clock speed of the target.
 */

#define delay( microseconds ) CPU_delay(microseconds)
#define sh_delay( microseconds ) CPU_delay( microseconds )


/*
 * Defined in the linker script 'linkcmds'
 */

extern uint32_t         HeapStart ;
extern uint32_t         HeapEnd ;
extern uint32_t         WorkSpaceStart ;
extern uint32_t         WorkSpaceEnd ;

extern void *CPU_Interrupt_stack_low ;
extern void *CPU_Interrupt_stack_high ;


/* miscellaneous stuff assumed to exist */

extern rtems_configuration_table BSP_Configuration;

extern rtems_cpu_table           Cpu_table;

extern void bsp_cleanup( void );

/*
 *  Device Driver Table Entries
 */

#undef CONSOLE_DRIVER_TABLE_ENTRY
#define CONSOLE_DRIVER_TABLE_ENTRY \
  { console_initialize, console_open, console_close, \
      console_read, console_write, console_control }

#define RAMDISK_DRIVER_TABLE_ENTRY \
  { ramdisk_initialize, ramdisk_open, ramdisk_close, \
        ramdisk_read, ramdisk_write, ramdisk_control }


/*
 * NOTE: Use the standard Clock driver entry
 */

/*
 * Trap interface with simulator
 */
int __trap34();

#ifdef __cplusplus
}
#endif

#endif
/* end of include file */
