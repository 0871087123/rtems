/*
 *  A simple main which can be used on any embedded target.
 *
 *  This style of initialization insures that the C++ global 
 *  constructors are executed after RTEMS is initialized.
 *
 *  Thanks to Chris Johns <cjohns@plessey.com.au> for this idea.
 *
 *  COPYRIGHT (c) 1989-1998.
 *  On-Line Applications Research Corporation (OAR).
 *  Copyright assigned to U.S. Government, 1994.
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */

#include <bsp.h>

extern void bsp_start( void );
extern void bsp_cleanup( void );

extern rtems_configuration_table  Configuration;
extern rtems_configuration_table  BSP_Configuration;
extern rtems_cpu_table            Cpu_table;

rtems_api_configuration_table BSP_RTEMS_Configuration;

#ifdef RTEMS_POSIX_API
posix_api_configuration_table BSP_POSIX_Configuration;
#endif

/* Initialize C++ global Ctor/Dtor and initializes exception handling. */
#if defined(USE_INIT_FINI)
extern void _fini( void );
extern void _init( void );
#endif

rtems_interrupt_level bsp_isr_level;

/*
 *  Since there is a forward reference
 */

int main(int argc, char **argv);

int boot_card(int argc, char **argv)
{
  int status;

  /*
   *  Set default values for the CPU Table fields all ports must have.
   *  These values can be overridden in bsp_start() but they are
   *  right most of the time.
   */

  Cpu_table.pretasking_hook                 = NULL;
  Cpu_table.predriver_hook                  = NULL;
  Cpu_table.postdriver_hook                 = NULL;
  Cpu_table.idle_task                       = NULL;
  Cpu_table.do_zero_of_workspace            = TRUE;
  Cpu_table.interrupt_stack_size            = RTEMS_MINIMUM_STACK_SIZE;
  Cpu_table.extra_mpci_receive_server_stack = 0;
  Cpu_table.stack_allocate_hook             = NULL;
  Cpu_table.stack_free_hook                 = NULL;


  /*
   *  Copy the configuration table so we and the BSP wants to change it.
   */

  BSP_Configuration       = Configuration;

  BSP_RTEMS_Configuration = *Configuration.RTEMS_api_configuration;
  BSP_Configuration.RTEMS_api_configuration = &BSP_RTEMS_Configuration;

#ifdef RTEMS_POSIX_API
  BSP_POSIX_Configuration = *Configuration.POSIX_api_configuration;
  BSP_Configuration.POSIX_api_configuration = &BSP_POSIX_Configuration;
#endif

  /*
   *  The atexit hook will be before the static destructor list's entry
   *  point.
   */

  bsp_start();

  /*
   *  Initialize RTEMS but do NOT start multitasking.
   */

  bsp_isr_level =
    rtems_initialize_executive_early( &BSP_Configuration, &Cpu_table );

  /*
   *  Call main() and get the global constructors invoked if there
   *  are any.
   */
#ifdef USE_INIT_FINI 
   atexit( _fini );
   _init();
#endif

  status = main(argc, argv);

  /*
   *  Perform any BSP specific shutdown actions.
   */

  bsp_cleanup();  

  /*
   *  Now return to the start code.
   */

  return status;
}
