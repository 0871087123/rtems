/*
 *  ITRON 3.0 Mailbox Manager
 *
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */

#include <itron.h>

#include <rtems/itron/mbox.h>
#include <rtems/itron/task.h>

/*
 *  rcv_msg - Receive Message from Mailbox 
 */

ER rcv_msg(
  T_MSG **ppk_msg,
  ID      mbxid
)
{
  return trcv_msg( ppk_msg, mbxid, TMO_FEVR );
}
