/*
 *
 *  This file contains the implementation of the function described in irq.h
 *
 *  Copyright (C) 1998, 1999 valette@crf.canon.fr
 *
 *  The license and distribution terms for this file may be
 *  found in found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  irq.c,v 1.4.2.8 2003/09/04 18:45:20 joel Exp
 */
  
#include <rtems/system.h>
#include <bsp.h>
#include <bsp/irq.h>
#if 0
#include <bsp/VME.h>
#include <bsp/openpic.h>
#endif
#include <stdlib.h>

#include <rtems/score/thread.h>
#include <rtems/score/apiext.h>
#include <libcpu/raw_exception.h>
#include <libcpu/io.h>
#include <bsp/vectors.h>

#include <rtems/bspIo.h> /* for printk */
#define RAVEN_INTR_ACK_REG 0xfeff0030

/*
 * pointer to the mask representing the additionnal irq vectors
 * that must be disabled when a particular entry is activated.
 * They will be dynamically computed from teh prioruty table given
 * in BSP_rtems_irq_mngt_set();
 * CAUTION : this table is accessed directly by interrupt routine
 * 	     prologue.
 */
rtems_i8259_masks 	irq_mask_or_tbl[BSP_IRQ_NUMBER];
/*
 * default handler connected on each irq after bsp initialization
 */
static rtems_irq_connect_data	default_rtems_entry;

/*
 * location used to store initial tables used for interrupt
 * management.
 */
static rtems_irq_global_settings* 	internal_config;
static rtems_irq_connect_data*		rtems_hdl_tbl;

/*
 * Check if IRQ is an ISA IRQ
 */
static inline int is_isa_irq(const rtems_irq_symbolic_name irqLine)
{
  return (((int) irqLine <= BSP_ISA_IRQ_MAX_OFFSET) &
	  ((int) irqLine >= BSP_ISA_IRQ_LOWEST_OFFSET)
	 );
}

/*
 * Check if IRQ is an OPENPIC IRQ
 */
static inline int is_pci_irq(const rtems_irq_symbolic_name irqLine)
{
  return (((int) irqLine <= BSP_PCI_IRQ_MAX_OFFSET) &
	  ((int) irqLine >= BSP_PCI_IRQ_LOWEST_OFFSET)
	 );
}

/*
 * Check if IRQ is a Porcessor IRQ
 */
static inline int is_processor_irq(const rtems_irq_symbolic_name irqLine)
{
  return (((int) irqLine <= BSP_PROCESSOR_IRQ_MAX_OFFSET) &
	  ((int) irqLine >= BSP_PROCESSOR_IRQ_LOWEST_OFFSET)
	 );
}


/*
 * ------------------------ RTEMS Irq helper functions ----------------
 */
 
/*
 * This function check that the value given for the irq line
 * is valid.
 */

static int isValidInterrupt(int irq)
{
  if ( (irq < BSP_LOWEST_OFFSET) || (irq > BSP_MAX_OFFSET))
    return 0;
  return 1;
}


/*
 * ------------------------ RTEMS Shared Irq Handler Mngt Routines ----------------
 */
int BSP_install_rtems_shared_irq_handler  (const rtems_irq_connect_data* irq)
{
  printk("BSP_insall_rtems_shared_irq_handler Not supported in psim\n");
  return 0;
}


/*
 * ------------------------ RTEMS Single Irq Handler Mngt Routines ----------------
 */

int BSP_install_rtems_irq_handler  (const rtems_irq_connect_data* irq)
{
    unsigned int level;
  
    if (!isValidInterrupt(irq->name)) {
      printk("Invalid interrupt vector %d\n",irq->name);
      return 0;
    }
    /*
     * Check if default handler is actually connected. If not issue an error.
     * You must first get the current handler via i386_get_current_idt_entry
     * and then disconnect it using i386_delete_idt_entry.
     * RATIONALE : to always have the same transition by forcing the user
     * to get the previous handler before accepting to disconnect.
     */
    _CPU_ISR_Disable(level);
    if (rtems_hdl_tbl[irq->name].hdl != default_rtems_entry.hdl) {
      _CPU_ISR_Enable(level);
      printk("IRQ vector %d already connected\n",irq->name);
      return 0;
    }

    /*
     * store the data provided by user
     */
    rtems_hdl_tbl[irq->name] = *irq;
    rtems_hdl_tbl[irq->name].next_handler = (void *)-1;
    
    if (is_isa_irq(irq->name)) {
      printk("What's a isa_irq on psim?");
    }

    if (is_processor_irq(irq->name)) {
      /*
       * Enable exception at processor level
       */
    }
    /*
     * Enable interrupt on device
     */
    irq->on(irq);
    
    _CPU_ISR_Enable(level);

    return 1;
}


int BSP_get_current_rtems_irq_handler	(rtems_irq_connect_data* irq)
{
     unsigned int level;

     if (!isValidInterrupt(irq->name)) {
      return 0;
     }
     _CPU_ISR_Disable(level);
     *irq = rtems_hdl_tbl[irq->name];
     _CPU_ISR_Enable(level);
     return 1;
}

int BSP_remove_rtems_irq_handler  (const rtems_irq_connect_data* irq)
{
   rtems_irq_connect_data *pchain= NULL, *vchain = NULL;
    unsigned int level;
  
    if (!isValidInterrupt(irq->name)) {
      return 0;
    }
    /*
     * Check if default handler is actually connected. If not issue an error.
     * You must first get the current handler via i386_get_current_idt_entry
     * and then disconnect it using i386_delete_idt_entry.
     * RATIONALE : to always have the same transition by forcing the user
     * to get the previous handler before accepting to disconnect.
     */
    _CPU_ISR_Disable(level);
    if (rtems_hdl_tbl[irq->name].hdl != irq->hdl) {
      _CPU_ISR_Enable(level);
      return 0;
    }

    if( (int)rtems_hdl_tbl[irq->name].next_handler != -1 )
    {
       int found = 0;

       for( (pchain= NULL, vchain = &rtems_hdl_tbl[irq->name]);
            (vchain->hdl != default_rtems_entry.hdl);
            (pchain= vchain, vchain = (rtems_irq_connect_data*)vchain->next_handler) )
       {
          if( vchain->hdl == irq->hdl )
          {
             found= -1; break;
          }
       }

       if( !found )
       {
          _CPU_ISR_Enable(level);
          return 0;
       }
    }
    else
    {
       if (rtems_hdl_tbl[irq->name].hdl != irq->hdl) 
       {
          _CPU_ISR_Enable(level);
         return 0;
       }
    }

    if (is_isa_irq(irq->name)) {
      printk("isa irq on psim?");
    }
    if (is_processor_irq(irq->name)) {
      /*
       * disable exception at processor level
       */
    }    

    /*
     * Disable interrupt on device
     */
    irq->off(irq);

    /*
     * restore the default irq value
     */
    if( !vchain )
    {
       /* single handler vector... */
       rtems_hdl_tbl[irq->name] = default_rtems_entry;
    }
    else
    {
       if( pchain )
       {
          /* non-first handler being removed */
          pchain->next_handler = vchain->next_handler;
       }
       else
       {
          /* first handler isn't malloc'ed, so just overwrite it.  Since
          the contents of vchain are being struct copied, vchain itself
          goes away */
          rtems_hdl_tbl[irq->name]= *vchain;
       }
       free(vchain);
    }

    _CPU_ISR_Enable(level);

    return 1;
}

/*
 * ------------------------ RTEMS Global Irq Handler Mngt Routines ----------------
 */

int BSP_rtems_irq_mngt_set(rtems_irq_global_settings* config)
{
   /*
    * Store various code accelerators
    */
    internal_config 		= config;
    default_rtems_entry 	= config->defaultEntry;
    rtems_hdl_tbl 		= config->irqHdlTbl;
    
    return 1;
}

int BSP_rtems_irq_mngt_get(rtems_irq_global_settings** config)
{
    *config = internal_config;
    return 0;
}    

int _BSP_vme_bridge_irq = -1;
 
unsigned BSP_spuriousIntr = 0;

/*
 * High level IRQ handler called from shared_raw_irq_code_entry
 */
void C_dispatch_irq_handler (CPU_Interrupt_frame *frame, unsigned int excNum)
{
  register unsigned msr;
  register unsigned new_msr;

  if (excNum == ASM_DEC_VECTOR) {
    _CPU_MSR_GET(msr);
    new_msr = msr | MSR_EE;
    _CPU_MSR_SET(new_msr);
    
    rtems_hdl_tbl[BSP_DECREMENTER].hdl(rtems_hdl_tbl[BSP_DECREMENTER].handle);

    _CPU_MSR_SET(msr);
    return;
    
  }
}
    
    
  
void _ThreadProcessSignalsFromIrq (BSP_Exception_frame* ctx)
{
  /*
   * Process pending signals that have not already been
   * processed by _Thread_Displatch. This happens quite
   * unfrequently : the ISR must have posted an action
   * to the current running thread.
   */
  if ( _Thread_Do_post_task_switch_extension ||
       _Thread_Executing->do_post_task_switch_extension ) {
    _Thread_Executing->do_post_task_switch_extension = FALSE;
    _API_extensions_Run_postswitch();
  }
  /*
   * I plan to process other thread related events here.
   * This will include DEBUG session requested from keyboard...
   */
}
