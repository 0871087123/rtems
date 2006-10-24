/*  bsp.h
 *  
 *  This include file contains all board IO definitions for eZKit533.
 *
 *  Copyright (c) 2006 by Atos Automacao Industrial Ltda.
 *             written by Alain Schaefer <alain.schaefer@easc.ch>
 *                    and Antonio Giovanini <antonio@atos.com.br>
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
#include <rtems/console.h>
#include <rtems/clockdrv.h>
#include <rtems/score/bfin.h>
#include <rtems/bfin/bf533.h> 


#define CLOCK_DRIVER_USE_FAST_IDLE

/* 
 * PLL and clock setup values:
 */

/*
 *  PLL configuration for ezkit533
 *
 *  XTL   =  27 MHz
 *  CLKIN =  13 MHz
 *  VCO   = 391 MHz
 *  CCLK  = 391 MHz
 *  SCLK  = 130 MHz
 */

#define PLL_CSEL    0x0000      /* CCLK = VCO      */
#define PLL_SSEL    0x0003      /* SCLK = CCLK/3   */
#define PLL_MSEL    0x3A00      /* VCO = 29xCLKIN  */
#define PLL_DF      0x0001      /* CLKIN = XTL/2   */

#define CCLK        391000000   /* CORE CLOCK     */
#define SCLK        130000000   /* SYSTEM CLOCK   */

/*
 * UART setup values
 */
#define BAUDRATE    57600       /* Console Baudrate   */
#define WORD_5BITS  0x00        /* 5 bits word        */
#define WORD_6BITS  0x01        /* 6 bits word        */
#define WORD_7BITS  0x02        /* 7 bits word        */
#define WORD_8BITS  0x03        /* 8 bits word        */
#define EVEN_PARITY 0x18        /* Enable EVEN parity */
#define ODD_PARITY  0x08        /* Enable ODD parity  */
#define TWO_STP_BIT 0x04        /* 2 stop bits        */

/*
 * Ezkit flash ports
 */
#define FlashA_PortB_Dir  0x20270007
#define FlashA_PortB_Data 0x20270005

// Blackfin environment memory map
//
#define L1_DATA_SRAM_A 0xff800000

#define FIFOLENGTH 0x100

/*
 *  confdefs.h overrides for this BSP:
 *   - number of termios serial ports (defaults to 1)
 *   - Interrupt stack space is not minimum if defined.
 */

/* #define CONFIGURE_NUMBER_OF_TERMIOS_PORTS 2 */
#define CONFIGURE_INTERRUPT_STACK_MEMORY  (4 * 1024)

/*
 *  Simple spin delay in microsecond units for device drivers.
 *  This is very dependent on the clock speed of the target.
 */

#define rtems_bsp_delay( microseconds ) \
  { \
  }

/* Constants */

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

/*
 * Helper Function to use the EzKits LEDS.
 * Can be used by the Application.
 */
void setLED (char value);

/*
 * Helper Function to use the EzKits LEDS
 */
char getLED (void);

void bsp_cleanup( void );

rtems_isr_entry set_vector(                    /* returns old vector */
  rtems_isr_entry     handler,                  /* isr routine        */
  rtems_vector_number vector,                   /* vector number      */
  int                 type                      /* RTEMS or RAW intr  */
);

#ifdef __cplusplus
}
#endif

#endif
