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

void outbyte( char );
char inbyte( void );

/*
 *  console_outbyte_polled
 *
 *  This routine transmits a character using polling.
 */

void console_outbyte_polled(
  int  port,
  char ch
)
{
  int status;
  int nwritten;

  status = _sys_write (1, &ch, 1, &nwritten);
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
  int status;
  int nread;
  char c;

  status = _sys_read (0, &c, 1, &nread);
  if ( status == 0 ) 
    return c;
  return -1;
}

