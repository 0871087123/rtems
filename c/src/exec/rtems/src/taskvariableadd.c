/*
 *  rtems_task_variable_add - Add a per-task variable
 *
 *
 *  COPYRIGHT (c) 1989-1998.
 *  On-Line Applications Research Corporation (OAR).
 *  Copyright assigned to U.S. Government, 1994.
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.OARcorp.com/rtems/license.html.
 *
 *  $Id$
 */

#include <rtems/system.h>
#include <rtems/rtems/tasks.h>
#include <rtems/score/wkspace.h>

/*
 *  rtems_task_variable_add
 *
 *  This directive registers a task variable. 
 */

rtems_status_code rtems_task_variable_add(
  rtems_id tid,
  int *ptr
)
{
  Thread_Control        *the_thread;
  Objects_Locations      location;
  RTEMS_API_Control     *api;
  rtems_task_variable_t *tvp, *new;

  the_thread = _Thread_Get (tid, &location);
  switch (location) {
  case OBJECTS_REMOTE:
#if defined(RTEMS_MULTIPROCESSING)
    _Thread_Dispatch();
    return RTEMS_ILLEGAL_ON_REMOTE_OBJECT;
#endif

  case OBJECTS_ERROR:
    return RTEMS_INVALID_ID;

  default:
    return RTEMS_INTERNAL_ERROR;

  case OBJECTS_LOCAL:
    api = the_thread->API_Extensions[ THREAD_API_RTEMS ];

    /*
     *  Figure out if the variable is already in this task's list.
     */

    tvp = api->task_variables;
    while (tvp) {
      if (tvp->ptr == ptr) {
        _Thread_Enable_dispatch();
        return RTEMS_SUCCESSFUL;
      }
      tvp = tvp->next;
    }

    /*
     *  Now allocate memory for this task variable.
     */

    new = (struct rtems_task_variable_t *)
       _Workspace_Allocate(sizeof(struct rtems_task_variable_t));
    if (new == NULL) {
      _Thread_Enable_dispatch();
      return RTEMS_NO_MEMORY;
    }
    new->var = 0;
    new->ptr = ptr;

    new->next = api->task_variables;
    api->task_variables = new;
    _Thread_Enable_dispatch();
    return RTEMS_SUCCESSFUL;
  }
  return RTEMS_INTERNAL_ERROR;   /* unreached - only to remove warnings */
}

