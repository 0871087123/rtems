/* 
 * vectors_init.c Exception hanlding initialisation (and generic handler).
 *
 *  This include file describe the data structure and the functions implemented
 *  by rtems to handle exceptions.
 *
 *  CopyRight (C) 1999 valette@crf.canon.fr
 *
 *  The license and distribution terms for this file may be
 *  found in found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */
#include <bsp/vectors.h>
#include <libcpu/raw_exception.h>
#include <bsp.h>

static rtems_raw_except_global_settings exception_config;
static rtems_raw_except_connect_data    exception_table[LAST_VALID_EXC + 1];

void C_exception_handler(exception_frame* excPtr)
{
  int recoverable = 0;
  
  printk("exception handler called for exception %d\n", excPtr->_EXC_number);
  printk("\t Next PC or Address of fault = %x\n", excPtr->EXC_SRR0);
  printk("\t Saved MSR = %x\n", excPtr->EXC_SRR1);
  printk("\t R0 = %x\n", excPtr->GPR0);
  printk("\t R1 = %x\n", excPtr->GPR1);
  printk("\t R2 = %x\n", excPtr->GPR2);
  printk("\t R3 = %x\n", excPtr->GPR3);
  printk("\t R4 = %x\n", excPtr->GPR4);
  printk("\t R5 = %x\n", excPtr->GPR5);
  printk("\t R6 = %x\n", excPtr->GPR6);
  printk("\t R7 = %x\n", excPtr->GPR7);
  printk("\t R8 = %x\n", excPtr->GPR8);
  printk("\t R9 = %x\n", excPtr->GPR9);
  printk("\t R10 = %x\n", excPtr->GPR10);
  printk("\t R11 = %x\n", excPtr->GPR11);
  printk("\t R12 = %x\n", excPtr->GPR12);
  printk("\t R13 = %x\n", excPtr->GPR13);
  printk("\t R14 = %x\n", excPtr->GPR14);
  printk("\t R15 = %x\n", excPtr->GPR15);
  printk("\t R16 = %x\n", excPtr->GPR16);
  printk("\t R17 = %x\n", excPtr->GPR17);
  printk("\t R18 = %x\n", excPtr->GPR18);
  printk("\t R19 = %x\n", excPtr->GPR19);
  printk("\t R20 = %x\n", excPtr->GPR20);
  printk("\t R21 = %x\n", excPtr->GPR21);
  printk("\t R22 = %x\n", excPtr->GPR22);
  printk("\t R23 = %x\n", excPtr->GPR23);
  printk("\t R24 = %x\n", excPtr->GPR24);
  printk("\t R25 = %x\n", excPtr->GPR25);
  printk("\t R26 = %x\n", excPtr->GPR26);
  printk("\t R27 = %x\n", excPtr->GPR27);
  printk("\t R28 = %x\n", excPtr->GPR28);
  printk("\t R29 = %x\n", excPtr->GPR29);
  printk("\t R30 = %x\n", excPtr->GPR30);
  printk("\t R31 = %x\n", excPtr->GPR31);
  printk("\t CR = %x\n", excPtr->EXC_CR);
  printk("\t CTR = %x\n", excPtr->EXC_CTR);
  printk("\t XER = %x\n", excPtr->EXC_XER);
  printk("\t LR = %x\n", excPtr->EXC_LR);
  printk("\t MSR = %x\n", excPtr->EXC_MSR);
  if ( (excPtr->_EXC_number == ASM_DEC_VECTOR) ||
       (excPtr->_EXC_number == ASM_SYS_VECTOR)
     )
       recoverable = 1;
  if (!recoverable) BSP_panic("unrecoverable exception!!! Push reset button\n");
}

void nop_except_enable(const rtems_raw_except_connect_data* ptr)
{
}
int except_always_enabled(const rtems_raw_except_connect_data* ptr)
{
  return 1;
}

void initialize_exceptions()
{
  int i;
  
  exception_config.exceptSize 		= LAST_VALID_EXC + 1;
  exception_config.rawExceptHdlTbl 	= &exception_table[0];
  exception_config.defaultRawEntry.exceptIndex	= 0;
  exception_config.defaultRawEntry.hdl.vector	= 0;
  exception_config.defaultRawEntry.hdl.raw_hdl	= default_exception_vector_code_prolog;
  /*
   * Note that next line the '&' before default_exception_vector_code_prolog_size
   * is not a bug as it is defined a .set directly in asm...
   */
  exception_config.defaultRawEntry.hdl.raw_hdl_size = (unsigned) &default_exception_vector_code_prolog_size;
  for (i=0; i <= exception_config.exceptSize; i++) {
    if (!mpc750_vector_is_valid (i)) {
      continue;
    }
    exception_table[i].exceptIndex	= i;
    exception_table[i].hdl		= exception_config.defaultRawEntry.hdl;
    exception_table[i].hdl.vector	= i;
    exception_table[i].on		= nop_except_enable;
    exception_table[i].off		= nop_except_enable;
    exception_table[i].isOn		= except_always_enabled;
  }
  if (!mpc60x_init_exceptions(&exception_config)) {
    BSP_panic("Exception handling initialization failed\n");
  }
  else {
    printk("Exception handling initialization done\n");
  }
}
