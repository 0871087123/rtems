/*  bsp.h
 *
 *  This include file contains all Papyrus board IO definitions.
 *
 *  Author:	Andrew Bray <andy@i-cubed.co.uk>
 *
 *  COPYRIGHT (c) 1995 by i-cubed ltd.
 *
 *  To anyone who acknowledges that this file is provided "AS IS"
 *  without any express or implied warranty:
 *      permission to use, copy, modify, and distribute this file
 *      for any purpose is hereby granted without fee, provided that
 *      the above copyright notice and this notice appears in all
 *      copies, and that the name of i-cubed limited not be used in
 *      advertising or publicity pertaining to distribution of the
 *      software without specific, written prior permission.
 *      i-cubed limited makes no representations about the suitability
 *      of this software for any purpose.
 *
 *  Derived from c/src/lib/libbsp/no_cpu/no_bsp/include/bsp.h
 *
 *  COPYRIGHT (c) 1989, 1990, 1991, 1992, 1993, 1994.
 *  On-Line Applications Research Corporation (OAR).
 *  All rights assigned to U.S. Government, 1994.
 *
 *  This material may be reproduced by or for the U.S. Government pursuant
 *  to the copyright license under the clause at DFARS 252.227-7013.  This
 *  notice must appear in all copies of this file and its derivatives.
 *
 *  $Id$
 */

#ifndef __PAPYRUS_h
#define __PAPYRUS_h

#ifdef __cplusplus
extern "C" {
#endif

#ifdef ASM
/* Definition of where to store registers in alignment handler */
#define ALIGN_REGS 0x0140

#else
#include <rtems.h>
#include <console.h>
#include <clockdrv.h>
#include <console.h>
#include <iosupp.h>

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

#define Install_tm27_vector( handler ) set_vector( (handler), PPC_IRQ_SCALL, 1 )

#define Cause_tm27_intr()  asm volatile ("sc")

#define Clear_tm27_intr()

#define Lower_tm27_intr()

/*
 *  Simple spin delay in microsecond units for device drivers.
 *  This is very dependent on the clock speed of the target.
 */

#define delay( microseconds ) \
  { \
    unsigned32 start, ticks, now; \
    asm volatile ("mfspr %0, 0x3dd" : "=r" (start)); /* TBLO */ \
    ticks = (microseconds) * Cpu_table.clicks_per_usec; \
    do \
      asm volatile ("mfspr %0, 0x3dd" : "=r" (now)); /* TBLO */ \
    while (now - start < ticks); \
  }


/* Constants */

#define RAM_START 0
#define RAM_END   0x00200000


/* Some useful LED debugging bits */
/* LED numbers are from 0-2 */
#define __led_base	((volatile int *)0x7F200000)

/* Turn a LED on */
#define led_on(n)	(__led_base[n] = 0)

/* Turn a LED off */
#define led_off(n)	(__led_base[n] = 1)

/* miscellaneous stuff assumed to exist */

extern rtems_configuration_table BSP_Configuration;     /* owned by BSP */
extern rtems_cpu_table           Cpu_table;             /* owned by BSP */

/*
 *  Device Driver Table Entries
 */
 
/*
 * NOTE: Use the standard Console driver entry
 */
 
/*
 * NOTE: Use the standard Clock driver entry
 */
 
/*
 * How many libio files we want
 */
 
#define BSP_LIBIO_MAX_FDS       20

/* functions */

int bsp_start(
  int   argc,
  char **argv,
  char **environp
);

void bsp_cleanup( void );

rtems_isr_entry set_vector(                    /* returns old vector */
  rtems_isr_entry     handler,                  /* isr routine        */
  rtems_vector_number vector,                   /* vector number      */
  int                 type                      /* RTEMS or RAW intr  */
);
#endif /* ASM */

#ifdef __cplusplus
}
#endif

#endif
/* end of include file */
