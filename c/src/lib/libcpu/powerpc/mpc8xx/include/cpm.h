/* 
 * cpm.h
 * 
 * This include file contains definitions pertaining 
 * to the Communications Processor Module (CPM) on the MPC8xx.
 *
 * Copyright (c) 1999, National Research Council of Canada
 *
 * The license and distribution terms for this file may be
 * found in the file LICENSE in this distribution or at
 * http://www.OARcorp.com/rtems/license.html.
 */

#ifndef __M8xx_CPM_h
#define __M8xx_CPM_h

#ifdef __cplusplus
extern "C" {
#endif

#include <bsp.h>

/* Functions */

void m8xx_cp_execute_cmd( unsigned16 command );
void *m8xx_dpram_allocate( unsigned int byte_count );

#define m8xx_bd_allocate(count)		\
		m8xx_dpram_allocate( (count) * sizeof(m8xxBufferDescriptor_t) )
#define m8xx_RISC_timer_table_allocate(count)	\
		m8xx_dpram_allocate( (count) * 4 )

#ifdef __cplusplus
}
#endif

#endif
/* end of include file */
