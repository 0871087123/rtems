/*  bspstart.c
 *
 *  This set of routines starts the application.  It includes application,
 *  board, and monitor specific initialization and configuration.
 *  The generic CPU dependent initialization has been performed
 *  before this routine is invoked.
 *
 *  COPYRIGHT (c) 1989-1998.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  SS555 port sponsored by Defence Research and Development Canada - Suffield
 *  Copyright (C) 2004, Real-Time Systems Inc. (querbach@realtime.bc.ca)
 *
 *  Derived from c/src/lib/libbsp/powerpc/mbx8xx/startup/bspstart.c:
 *
 *  Modifications for MBX860:
 *  Copyright (c) 1999, National Research Council of Canada
 *
 *  $Id$
 */

#include <string.h>

#include <rtems/libio.h>
#include <rtems/libcsupport.h>
#include <rtems/bspIo.h>

#include <libcpu/cpuIdent.h>
#include <libcpu/spr.h>

#include <bsp/irq.h>
#include <bsp.h>

SPR_RW(SPRG0)
SPR_RW(SPRG1)

/*
 *  The original table from the application (in ROM) and our copy of it with
 *  some changes. Configuration is defined in <confdefs.h>. Make sure that
 *  our configuration tables are uninitialized so that they get allocated in
 *  the .bss section (RAM).
 */
extern rtems_configuration_table Configuration;
extern unsigned long intrStackPtr;
rtems_configuration_table  BSP_Configuration;

rtems_cpu_table Cpu_table;

char *rtems_progname;

/*
 *  Use the shared implementations of the following routines.
 *  Look in rtems/c/src/lib/libbsp/shared/bsppost.c and
 *  rtems/c/src/lib/libbsp/shared/bsplibc.c.
 */
void bsp_postdriver_hook(void);
void bsp_libc_init( void *, uint32_t, int );

void BSP_panic(char *s)
{
  printk("%s PANIC %s\n",_RTEMS_version, s);
  __asm__ __volatile ("sc");
}

void _BSP_Fatal_error(unsigned int v)
{
  printk("%s PANIC ERROR %x\n",_RTEMS_version, v);
  __asm__ __volatile ("sc");
}

/*
 *  bsp_pretasking_hook
 *
 *  Called when RTEMS initialization is complete but before interrupts and
 *  tasking are enabled. Used to setup libc and install any BSP extensions.
 *
 *  Must not use libc (to do io) from here, since drivers are not yet
 *  initialized.
 *
 *  Installed in the rtems_cpu_table defined in
 *  rtems/c/src/exec/score/cpu/powerpc/rtems/new-exceptions/cpu.h by main()
 *  below.  Called from rtems_initialize_executive() defined in
 *  rtems/c/src/exec/sapi/src/init.c
 *
 *  Input parameters: NONE
 *
 *  Output parameters: NONE
 *
 *  Return values: NONE
 */
void bsp_pretasking_hook(void)
{
  /*
   *  These are assigned addresses in the linkcmds file for the BSP. This
   *  approach is better than having these defined as manifest constants and
   *  compiled into the kernel, but it is still not ideal when dealing with
   *  multiprocessor configuration in which each board as a different memory
   *  map. A better place for defining these symbols might be the makefiles.
   *  Consideration should also be given to developing an approach in which
   *  the kernel and the application can be linked and burned into ROM
   *  independently of each other.
   */
    unsigned char *_HeapStart =
      (char*)BSP_Configuration.work_space_start
           + BSP_Configuration.work_space_size;
    extern unsigned char _HeapEnd[];

    bsp_libc_init( _HeapStart, _HeapEnd - _HeapStart, 0 );

#ifdef RTEMS_DEBUG
  rtems_debug_enable( RTEMS_DEBUG_ALL_MASK );
#endif
}

/*
 *  bsp_start()
 *
 *  Board-specific initialization code. Called from the generic boot_card()
 *  function defined in rtems/c/src/lib/libbsp/shared/main.c. That function
 *  does some of the board independent initialization. It is called from the
 *  SS555 entry point _start() defined in
 *  rtems/c/src/lib/libbsp/powerpc/ss555/startup/start.S
 *
 *  _start() has set up a stack, has zeroed the .bss section, has set up the
 *  .data section from contents stored in ROM, has turned off interrupts,
 *  and placed the processor in the supervisor mode.  boot_card() has left
 *  the processor in that state when bsp_start() was called.
 *
 *  Input parameters: NONE
 *
 *  Output parameters: NONE
 *
 *  Return values: NONE
 */
void bsp_start(void)
{
  extern char _WorkspaceBase[];

  ppc_cpu_id_t myCpu;
  ppc_cpu_revision_t myCpuRevision;
  register unsigned char* intrStack;

  /*
   * Get CPU identification dynamically.  Note that the get_ppc_cpu_type()
   * function stores the result in global variables so that it can be used
   * later.
   */
  myCpu 	= get_ppc_cpu_type();
  myCpuRevision = get_ppc_cpu_revision();

  /*
   * Initialize some SPRG registers related to irq handling
   */
  intrStack = (((unsigned char*)&intrStackPtr) - CPU_MINIMUM_STACK_FRAME_SIZE);
  _write_SPRG1((unsigned int)intrStack);
  /* signal them that we have fixed PR288 - eventually, this should go away */
  _write_SPRG0(PPC_BSP_HAS_FIXED_PR288);

  /*
   * Install our own set of exception vectors
   */
  initialize_exceptions();

  /*
   *  Allocate the memory for the RTEMS Work Space.  This can come from
   *  a variety of places: hard coded address, malloc'ed from outside
   *  RTEMS world (e.g. simulator or primitive memory manager), or (as
   *  typically done by stock BSPs) by subtracting the required amount
   *  of work space from the last physical address on the CPU board.
   *
   *  In this case, the memory is not malloc'ed.  It is just
   *  "pulled from the air".
   */
  BSP_Configuration.work_space_start = _WorkspaceBase;

  /*
   *  initialize the CPU table for this BSP
   */
  Cpu_table.pretasking_hook = bsp_pretasking_hook;  /* init libc, etc. */
  Cpu_table.postdriver_hook = bsp_postdriver_hook;
  if( Cpu_table.interrupt_stack_size < 4 * 1024 )
      Cpu_table.interrupt_stack_size = 4 * 1024;

  Cpu_table.clicks_per_usec = BSP_CRYSTAL_HZ / 4 / 1000000;
  Cpu_table.clock_speed = BSP_CLOCK_HZ;	/* for SCI baud rate generator */

  /*
   * Call this in case we use TERMIOS for console I/O
   */
  m5xx_uart_reserve_resources( &BSP_Configuration );

  /*
   * Initalize RTEMS IRQ system
   */
  BSP_rtems_irq_mng_init(0);
}
