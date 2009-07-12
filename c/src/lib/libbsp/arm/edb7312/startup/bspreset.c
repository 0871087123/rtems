/*
 *  Copyright (c) 2002 by Jay Monkman <jtm@smoothsmoothie.com>
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

#include <bsp.h>

void bsp_reset(void)
{
  #if ON_SKYEYE
    /* TBD use Skyeye reset device */
  #else
    asm volatile ("b _start");
  #endif
}
