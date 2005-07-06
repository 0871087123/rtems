/**
 *  @file bspstart.c
 *
 *  This file contains the GBA BSP startup package.
 *  It includes application, board, and monitor specific initialization and
 *  configuration. The generic CPU dependent initialization has been
 *  performed before this routine is invoked.
 */
/*
 *  RTEMS GBA BSP
 *
 *  Copyright (c) 2004  Markku Puro <markku.puro@kopteri.net>
 *
 *  The license and distribution terms for this file may be
 *  found in found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id$
 */

#include <stdio.h>
#include <bsp.h>
#include <rtems/bspIo.h>
#include <rtems/libio.h>
#include <rtems/libcsupport.h>
#include <gba.h>
#include <conio.h>

#define BSP_DEBUG  0

/* Global Variables, Defined in 'linkcmds' */
extern  void _end;
extern  void _stack_size;
extern  void _irq_max_vector;
extern  void __heap_limit;
extern  void __ro_start;
extern  void __ro_end;
extern  void __data_start;
extern  void __data_end;
extern  void __load_start_data;
extern  void __load_stop_data;
extern  void __ewram_start;
extern  void __ewram_end;
extern  void __load_start_ewram;
extern  void __load_stop_ewram;
extern  void __iwram_start;
extern  void __iwram_end;
extern  void __load_start_iwram;
extern  void __load_stop_iwram;
extern  void __bss_start;
extern  void __bss_end;

/**  The original BSP configuration table from the application. */
extern rtems_configuration_table  Configuration;
/** Our copy of BSP configuration table from the application. */
rtems_configuration_table  BSP_Configuration;

/* External Prototypes */
extern void bsp_cleanup( void );
extern void rtems_irq_mngt_init(void);
extern void bsp_libc_init( void *, rtems_unsigned32, int );
extern void bsp_postdriver_hook(void);


/** Chip registers */
volatile unsigned int *Regs = (unsigned int *)GBA_IO_REGS_ADDR;

/**
 *  Size of heap if it is 0 it will be dynamically defined by memory size,
 *  otherwise the value should be changed by binary patch
 */
rtems_unsigned32   _heap_size = 0;

/** Address of start of free memory - should be updated after creating new partitions or regions.*/
rtems_unsigned32   rtemsFreeMemStart;

/** CPU configuration table.    */
rtems_cpu_table    Cpu_table;
/** Program name - from main(). */
char              *rtems_progname;


/**
 *  @brief BSP pretasking hook.
 *
 *  Called just before drivers are initialized.
 *  Used to setup libc and install any BSP extensions.
 *
 *  NOTE: Must not use libc (to do io) from here, since drivers are not yet initialized.
 *
 *  @param  None
 *  @return None
 */
void bsp_pretasking_hook(void)
{

  if (_heap_size == 0) {
     _heap_size = (rtems_unsigned32)&__heap_limit - rtemsFreeMemStart;
  }

  bsp_libc_init((void *)rtemsFreeMemStart, _heap_size, 0);

  rtemsFreeMemStart += _heap_size;


#ifdef RTEMS_DEBUG
  rtems_debug_enable(RTEMS_DEBUG_ALL_MASK);
#endif /* RTEMS_DEBUG */

#if BSP_DEBUG
  /*  The following information is very useful when debugging. */
  printk("[bsp_pretasking_hook]\n");
  printk("_heap_size  = 0x%x\n", _heap_size);
  printk("_stack_size = 0x%x\n", (rtems_unsigned32)&_stack_size);
  printk("_irq_max_vector = 0x%x\n", (rtems_unsigned32)&_irq_max_vector);
  printk("__ro_start      = 0x%x : __ro_end     = 0x%x\n", (rtems_unsigned32)&__ro_start, (rtems_unsigned32)&__ro_end);
  printk("__ewram_start   = 0x%x : __ewram_end  = 0x%x\n", (rtems_unsigned32)&__ewram_start, (rtems_unsigned32)&__ewram_end);
  printk("__data_start    = 0x%x : __data_end   = 0x%x\n", (rtems_unsigned32)&__data_start, (rtems_unsigned32)&__data_end);
  printk("__bss_start     = 0x%x : __bss_end    = 0x%x\n", (rtems_unsigned32)&__bss_start,(rtems_unsigned32)&__bss_end);
  printk("__iwram_start   = 0x%x : __iwram_end  = 0x%x\n", (rtems_unsigned32)&__iwram_start,(rtems_unsigned32)&__iwram_end);
  printk("__load_start_iwram = 0x%x\n", (rtems_unsigned32)&__load_start_iwram);
  printk("__load_stop_iwram  = 0x%x\n", (rtems_unsigned32)&__load_stop_iwram);
  printk("__load_start_ewram = 0x%x\n", (rtems_unsigned32)&__load_start_ewram);
  printk("__load_stop_ewram  = 0x%x\n", (rtems_unsigned32)&__load_stop_ewram);
  printk("__load_start_data  = 0x%x\n", (rtems_unsigned32)&__load_start_data);
  printk("__load_stop_data   = 0x%x\n", (rtems_unsigned32)&__load_stop_data);
#endif
}


/**
 *  @brief BSP Start
 *
 *  Called before main is invoked.
 *
 *  @param  None
 *  @return None
 */
void bsp_start_default( void )
{
  /* set the value of start of free memory. */
  rtemsFreeMemStart = (rtems_unsigned32)&_end;

  /* If we don't have command line arguments set default program name. */
  Cpu_table.pretasking_hook         = bsp_pretasking_hook; /* init libc, etc. */
  Cpu_table.predriver_hook          = NULL;                /* use system's    */
  Cpu_table.postdriver_hook         = bsp_postdriver_hook;
  Cpu_table.idle_task               = NULL; /* don't override system IDLE task */
  Cpu_table.do_zero_of_workspace    = TRUE;
  Cpu_table.interrupt_stack_size    = 0;
  Cpu_table.extra_mpci_receive_server_stack = 0;


  /* Place RTEMS workspace at beginning of free memory. */
  BSP_Configuration.work_space_start = (void *)rtemsFreeMemStart;
  rtemsFreeMemStart += BSP_Configuration.work_space_size;

  /* Init conio  */
  gba_textmode(CO60);

  /* Init rtems exceptions management  */
  /*!!!!!GBA - Can't use exception vectors in GBA because they are already in GBA ROM BIOS */
  /* rtems_exception_init_mngt(); */

  /* Init rtems interrupt management */
  rtems_irq_mngt_init();

#if BSP_DEBUG
  /* The following information is very useful when debugging. */
  printk("[bsp_start]\n");
  printk("rtemsFreeMemStart= 0x%x\n", rtemsFreeMemStart);
  printk("__heap_limit     = 0x%x\n", (rtems_unsigned32)&__heap_limit);
  printk("work_space_start = 0x%x size = 0x%x\n", BSP_Configuration.work_space_start,BSP_Configuration.work_space_size);
  printk("maximum_extensions    = 0x%x\n", BSP_Configuration.maximum_extensions);
  printk("microseconds_per_tick = 0x%x\n", BSP_Configuration.microseconds_per_tick);
  printk("ticks_per_timeslice   = 0x%x\n", BSP_Configuration.ticks_per_timeslice);
  printk("maximum_devices          = 0x%x\n", BSP_Configuration.maximum_devices);
  printk("number_of_device_drivers = 0x%x\n", BSP_Configuration.number_of_device_drivers);
  printk("Device_driver_table      = 0x%x\n", BSP_Configuration.Device_driver_table);
#endif

  /* Do we have enough memory */
  if ((rtems_unsigned32)&__heap_limit < rtemsFreeMemStart) {
     printk("\nFatal Error: Memory overflow[0x%x]!\n",rtemsFreeMemStart);
     bsp_cleanup();
  }

}


/**
 *  @brief weak alias for bsp_start_default
 *
 *  By making this a weak alias for bsp_start_default, a brave soul
 *  can override the actual bsp_start routine used.
 */
void bsp_start (void) __attribute__ ((weak, alias("bsp_start_default")));
