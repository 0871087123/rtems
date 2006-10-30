/*
 *  $Id$
 */

#if HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdarg.h>

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <semaphore.h>
#include <limits.h>

#include <rtems/system.h>
#include <rtems/score/object.h>
#include <rtems/posix/semaphore.h>
#include <rtems/posix/time.h>
#include <rtems/seterr.h>

/*PAGE
 *
 *  _POSIX_Semaphore_Wait_support
 */

int _POSIX_Semaphore_Wait_support(
  sem_t                          *sem,
  Core_semaphore_Blocking_option  blocking,
  Watchdog_Interval               timeout
)
{
  POSIX_Semaphore_Control *the_semaphore;
  Objects_Locations        location;

  the_semaphore = _POSIX_Semaphore_Get( sem, &location );
  switch ( location ) {
    case OBJECTS_ERROR:
      rtems_set_errno_and_return_minus_one( EINVAL );
    case OBJECTS_REMOTE:
      _Thread_Dispatch();
      rtems_set_errno_and_return_minus_one( EINVAL );
    case OBJECTS_LOCAL:
      _CORE_semaphore_Seize(
        &the_semaphore->Semaphore,
        the_semaphore->Object.id,
        blocking,
        timeout
      );
      _Thread_Enable_dispatch();
      switch ( _Thread_Executing->Wait.return_code ) {
        case CORE_SEMAPHORE_STATUS_SUCCESSFUL:
	  break;
        case CORE_SEMAPHORE_STATUS_UNSATISFIED_NOWAIT:
          rtems_set_errno_and_return_minus_one( EAGAIN );
        case CORE_SEMAPHORE_WAS_DELETED:
          rtems_set_errno_and_return_minus_one( EAGAIN );
        case CORE_SEMAPHORE_TIMEOUT:
          rtems_set_errno_and_return_minus_one( ETIMEDOUT );
	  break;
        case CORE_SEMAPHORE_MAXIMUM_COUNT_EXCEEDED:
          /*
           *  This error can not occur since we set the maximum
           *  count to the largest value the count can hold.
           */
 	  break;
	case CORE_SEMAPHORE_BAD_TIMEOUT_VALUE:
          rtems_set_errno_and_return_minus_one( EINVAL );
	  break;
      }
  }
  return 0;
}
