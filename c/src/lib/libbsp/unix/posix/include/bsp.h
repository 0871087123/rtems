/*  bsp.h
 *
 *  This include file contains all POSIX BSP definitions.
 *
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

#ifndef _BSP_H
#define _BSP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <bspopts.h>

#include <rtems.h>
#include <rtems/clockdrv.h>
#include <rtems/console.h>
#include <rtems/iosupp.h>

/*
 *  confdefs.h overrides for this BSP:
 *   - number of termios serial ports (defaults to 1)
 *   - Interrupt stack space is not minimum if defined.
 */

/* #define CONFIGURE_NUMBER_OF_TERMIOS_PORTS 2 */
#define CONFIGURE_INTERRUPT_STACK_MEMORY  (4 * 1024)

#define RAM_START 0
#define RAM_END   0x100000

/* miscellaneous stuff assumed to exist */

extern rtems_configuration_table BSP_Configuration;

/*
 *  Device Driver Table Entries
 */

/*
 * NOTE: Use the standard Console driver entry
 */

/*
 * NOTE: Use the standard Clock driver entry
 */

/* functions */

rtems_isr_entry set_vector(rtems_isr_entry, rtems_vector_number, int);
void bsp_start( void );
void bsp_cleanup( void );

/* miscellaneous stuff assumed to exist */

extern rtems_configuration_table BSP_Configuration;     /* owned by BSP */
extern rtems_cpu_table           Cpu_table;             /* owned by BSP */

extern int                       rtems_argc;
extern char                    **rtems_argv;

extern uint32_t                  bsp_isr_level;

extern char *rtems_progname;    /* UNIX executable name */

extern int cpu_number;

#ifdef __cplusplus
}
#endif

#endif
/* end of include file */
