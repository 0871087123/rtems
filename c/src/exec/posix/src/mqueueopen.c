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

#include <stdarg.h>

#include <pthread.h>
#include <limits.h>
#include <errno.h>
#include <fcntl.h>
#include <mqueue.h>

#include <rtems/system.h>
#include <rtems/score/watchdog.h>
#include <rtems/posix/seterr.h>
#include <rtems/posix/mqueue.h>
#include <rtems/posix/time.h>

/*PAGE
 *
 *  15.2.2 Open a Message Queue, P1003.1b-1993, p. 272
 */

mqd_t mq_open(
  const char *name,
  int         oflag,
  ...
  /* mode_t mode, */
  /* struct mq_attr  attr */
)
{
  va_list                        arg;
  mode_t                         mode;
  struct mq_attr                *attr;
  int                            status;
  Objects_Id                     the_mq_id;
  POSIX_Message_queue_Control   *the_mq;
 
  if ( oflag & O_CREAT ) {
    va_start(arg, oflag);
    mode = (mode_t) va_arg( arg, mode_t );
    attr = (struct mq_attr *) va_arg( arg, struct mq_attr * );
    va_end(arg);
  }
 
  status = _POSIX_Message_queue_Name_to_id( name, &the_mq_id );
 
  /*
   *  If the name to id translation worked, then the message queue exists
   *  and we can just return a pointer to the id.  Otherwise we may
   *  need to check to see if this is a "message queue does not exist"
   *  or some other miscellaneous error on the name.
   */
 
  if ( status ) {
 
    if ( status == EINVAL ) {      /* name -> ID translation failed */
      if ( !(oflag & O_CREAT) ) {  /* willing to create it? */
        set_errno_and_return_minus_one( ENOENT );
        return (mqd_t) -1;
      }
      /* we are willing to create it */
    }
    set_errno_and_return_minus_one( status ); /* some type of error */
    return (mqd_t) -1;
 
  } else {                /* name -> ID translation succeeded */
 
    if ( (oflag & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL) ) {
      set_errno_and_return_minus_one( EEXIST );
      return (mqd_t) -1;
    }
 
    /*
     * XXX In this case we need to do an ID->pointer conversion to
     *     check the mode.   This is probably a good place for a subroutine.
     */
 
    the_mq->open_count += 1;
 
    return (mqd_t)&the_mq->Object.id;
 
  }
 
  /* XXX verify this comment...
   *
   *  At this point, the message queue does not exist and everything has been
   *  checked. We should go ahead and create a message queue.
   */
 
  status = _POSIX_Message_queue_Create_support(
    name,
    TRUE,         /* shared across processes */
    oflag,
    attr,
    &the_mq
  );
 
  if ( status == -1 )
    return (mqd_t) -1;
 
  return (mqd_t) &the_mq->Object.id;
}

