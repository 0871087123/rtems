/*
 *  This file contains the hardware specific portions of the TTY driver
 *  for the serial ports on the erc32.
 *
 *  COPYRIGHT (c) 1989-1997.
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
#include <rtems/libio.h>
#include <stdlib.h>
#include <assert.h>

/* external prototypes for monitor interface routines */

/*
 *  console_outbyte_polled
 *
 *  This routine transmits a character using polling.
 */

extern int armulator_stdin;
extern int armulator_stdout;
extern int armulator_stderr;

void console_outbyte_polled(
  int  port,
  char ch
)
{
  int nwritten;
  int _swiwrite (int, char *, int);

  nwritten = _swiwrite (armulator_stdout, &ch , 1);

  /* error if (nwritten == -1 || nwritten == len) */
}

/*
 *  console_inbyte_nonblocking 
 *
 *  This routine polls for a character.
 */

int console_inbyte_nonblocking(
  int port
)
{
  int nread;
  char c;
  int _swiread (int, char *, int);

  nread = _swiread (armulator_stdin, &c, 1);
  if ( nread != 1 )
    return -1;

  return c;
}

#include <bspIo.h>

void Armulator_BSP_output_char(char c) { console_outbyte_polled( 0, c ); }

BSP_output_char_function_type           BSP_output_char = Armulator_BSP_output_char;
BSP_polling_getchar_function_type       BSP_poll_char = NULL;

