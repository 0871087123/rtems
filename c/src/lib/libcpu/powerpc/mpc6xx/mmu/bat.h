/*
 * bat.h
 *
 *	    This file contains declaration of C function to
 *          Instantiate 60x/7xx ppc Block Address Translation (BAT) registers.
 *	    More detailed information can be found on motorola
 *	    site and more precisely in the following book :
 *
 *		MPC750 
 *		Risc Microporcessor User's Manual
 *		Mtorola REF : MPC750UM/AD 8/97
 *
 * Copyright (C) 1999  Eric Valette (valette@crf.canon.fr)
 *                     Canon Centre Recherche France.
 *
 *  The license and distribution terms for this file may be
 *  found in found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 * $Id$
 */

#ifndef _LIBCPU_BAT_H
#define _LIBCPU_BAT_H

#include <libcpu/mmu.h>
#include <libcpu/pgtable.h>
#include <rtems/bspIo.h>

#define IO_PAGE	(_PAGE_NO_CACHE | _PAGE_GUARDED | _PAGE_RW)

extern void setdbat(int bat_index, unsigned long virt, unsigned long phys,
		    unsigned int size, int flags);

extern void asm_setdbat1(unsigned int uperPart, unsigned int lowerPart);
extern void asm_setdbat2(unsigned int uperPart, unsigned int lowerPart);
extern void asm_setdbat3(unsigned int uperPart, unsigned int lowerPart);
extern void asm_setdbat4(unsigned int uperPart, unsigned int lowerPart);

#endif /* _LIBCPU_BAT_H */
