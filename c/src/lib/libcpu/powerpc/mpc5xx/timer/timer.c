/*  timer.c
 *
 *  This file manages the interval timer on the PowerPC MPC5xx.
 *  NOTE: This is not the PIT, but rather the RTEMS interval
 *        timer
 *  We shall use the bottom 32 bits of the timebase register,
 *
 *  The following was in the 403 version of this file. I don't
 *  know what it means. JTM 5/19/98
 *  NOTE: It is important that the timer start/stop overhead be
 *        determined when porting or modifying this code.
 *
 *
 *  MPC5xx port sponsored by Defence Research and Development Canada - Suffield
 *  Copyright (C) 2004, Real-Time Systems Inc. (querbach@realtime.bc.ca)
 *
 *  Derived from c/src/lib/libcpu/powerpc/mpc8xx/timer/timer.c:
 *
 *  Author: Jay Monkman (jmonkman@frasca.com)
 *  Copywright (C) 1998 by Frasca International, Inc.
 *
 *  Derived from c/src/lib/libcpu/ppc/ppc403/timer/timer.c:
 *
 *  Author:     Andrew Bray <andy@i-cubed.co.uk>
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
 *  Derived from c/src/lib/libcpu/hppa1_1/timer/timer.c:
 *
 *  COPYRIGHT (c) 1989-1998.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

#include <rtems.h>
#include <mpc5xx.h>

static volatile uint32_t Timer_starting;
static rtems_boolean Timer_driver_Find_average_overhead;

/*
 *  This is so small that this code will be reproduced where needed.
 */
static inline uint32_t get_itimer(void)
{
   uint32_t ret;

   asm volatile ("mftb %0" : "=r" ((ret))); /* TBLO */

   return ret;
}

void Timer_initialize(void)
{
  /* set interrupt level and enable timebase. This should never */
  /*  generate an interrupt however. */
  usiu.tbscrk = USIU_UNLOCK_KEY;
  usiu.tbscr |= USIU_TBSCR_TBIRQ(4) 	/* interrupt priority level */
              | USIU_TBSCR_TBF 		/* freeze timebase during debug */
              | USIU_TBSCR_TBE;		/* enable timebase */
  usiu.tbscrk = 0;
  
  Timer_starting = get_itimer();
}

#ifndef  rtems_cpu_configuration_get_timer_least_valid
#define  rtems_cpu_configuration_get_timer_least_valid() 0
#endif

#ifndef  rtems_cpu_configuration_get_timer_average_overhead
#define  rtems_cpu_configuration_get_timer_average_overhead() 0
#endif

int Read_timer(void)
{
  uint32_t clicks;
  uint32_t total;

  clicks = get_itimer();

  total = clicks - Timer_starting;

  if ( Timer_driver_Find_average_overhead == 1 )
    return total;          /* in XXX microsecond units */

  else {
    if ( total < rtems_cpu_configuration_get_timer_least_valid() ) {
      return 0;            /* below timer resolution */
    }
    return (total - rtems_cpu_configuration_get_timer_average_overhead());
  }
}

rtems_status_code Empty_function(void)
{
  return RTEMS_SUCCESSFUL;
}

void Set_find_average_overhead(rtems_boolean find_flag)
{
  Timer_driver_Find_average_overhead = find_flag;
}
