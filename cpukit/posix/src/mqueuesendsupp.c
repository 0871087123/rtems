/*
 *  NOTE:  The structure of the routines is identical to that of POSIX
 *         Message_queues to leave the option of having unnamed message
 *         queues at a future date.  They are currently not part of the
 *         POSIX standard but unnamed message_queues are.  This is also
 *         the reason for the apparently unnecessary tracking of
 *         the process_shared attribute.  [In addition to the fact that
 *         it would be trivial to add pshared to the mq_attr structure
 *         and have process private message queues.]
 *
 *         This code ignores the O_RDONLY/O_WRONLY/O_RDWR flag at open
 *         time.
 *
 *  $Id$
 */

#if HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdarg.h>

#include <pthread.h>
#include <limits.h>
#include <errno.h>
#include <fcntl.h>
#include <mqueue.h>

#include <rtems/system.h>
#include <rtems/score/watchdog.h>
#include <rtems/seterr.h>
#include <rtems/posix/mqueue.h>
#include <rtems/posix/time.h>


/*PAGE
 *
 *  _POSIX_Message_queue_Send_support
 */

int _POSIX_Message_queue_Send_support(
  mqd_t               mqdes,
  const char         *msg_ptr,
  uint32_t            msg_len,
  uint32_t            msg_prio,
  Watchdog_Interval   timeout
)
{
  POSIX_Message_queue_Control    *the_mq;
  POSIX_Message_queue_Control_fd *the_mq_fd;
  Objects_Locations               location;
  CORE_message_queue_Status       msg_status;

  /*
   * Validate the priority.
   * XXX - Do not validate msg_prio is not less than 0.
   */

  if ( msg_prio > MQ_PRIO_MAX )
    rtems_set_errno_and_return_minus_one( EINVAL );

  the_mq_fd = _POSIX_Message_queue_Get_fd( mqdes, &location );
  switch ( location ) {
    case OBJECTS_ERROR:
      rtems_set_errno_and_return_minus_one( EBADF );

    case OBJECTS_REMOTE:
      _Thread_Dispatch();
      return POSIX_MP_NOT_IMPLEMENTED();
      rtems_set_errno_and_return_minus_one( EINVAL );

    case OBJECTS_LOCAL:
      if ( (the_mq_fd->oflag & O_ACCMODE) == O_RDONLY ) {
        _Thread_Enable_dispatch();
        rtems_set_errno_and_return_minus_one( EBADF );
      }

      the_mq = the_mq_fd->Queue;

      msg_status = _CORE_message_queue_Submit(
        &the_mq->Message_queue,
        (void *) msg_ptr,
        msg_len,
        mqdes,      /* mqd_t is an object id */
#if defined(RTEMS_MULTIPROCESSING)
        NULL,      /* XXX _POSIX_Message_queue_Core_message_queue_mp_support*/
#else
        NULL,
#endif
        _POSIX_Message_queue_Priority_to_core( msg_prio ),
         (the_mq_fd->oflag & O_NONBLOCK) ? FALSE : TRUE,
        timeout    /* no timeout */
      );

      _Thread_Enable_dispatch();

      /*
       *  If we had to block, then this is where the task returns
       *  after it wakes up.  The returned status is correct for
       *  non-blocking operations but if we blocked, then we need
       *  to look at the status in our TCB.
       */

      if ( msg_status == CORE_MESSAGE_QUEUE_STATUS_UNSATISFIED_WAIT )
        msg_status = _Thread_Executing->Wait.return_code;

      if ( !msg_status )
        return msg_status;

      rtems_set_errno_and_return_minus_one(
        _POSIX_Message_queue_Translate_core_message_queue_return_code(
          msg_status
        )
      );
  }
  return POSIX_BOTTOM_REACHED();
}
