@c
@c  COPYRIGHT (c) 1988-1998.
@c  On-Line Applications Research Corporation (OAR).
@c  All rights reserved.
@c
@c  $Id$
@c

@chapter Timer Manager

@section Introduction

The timer manager provides support for timer
facilities.  The directives provided by the timer manager are:

@itemize @bullet
@item @code{@value{DIRPREFIX}timer_create} - Create a timer
@item @code{@value{DIRPREFIX}timer_ident} - Get ID of a timer
@item @code{@value{DIRPREFIX}timer_cancel} - Cancel a timer
@item @code{@value{DIRPREFIX}timer_delete} - Delete a timer
@item @code{@value{DIRPREFIX}timer_fire_after} - Fire timer after interval
@item @code{@value{DIRPREFIX}timer_fire_when} - Fire timer when specified
@item @code{@value{DIRPREFIX}timer_reset} - Reset an interval timer
@end itemize


@section Background

@subsection Required Support

A clock tick is required to support the functionality provided by this manager.

@subsection Timers

A timer is an RTEMS object which allows the
application to schedule operations to occur at specific times in
the future.  User supplied timer service routines are invoked by
the @code{@value{DIRPREFIX}clock_tick} directive
when the timer fires.  Timer service routines may perform
any operations or directives which normally
would be performed by the application code which invoked the
@code{@value{DIRPREFIX}clock_tick} directive.

The timer can be used to implement watchdog routines
which only fire to denote that an application error has
occurred.  The timer is reset at specific points in the
application to insure that the watchdog does not fire.  Thus, if
the application does not reset the watchdog timer, then the
timer service routine will fire to indicate that the application
has failed to reach a reset point.  This use of a timer is
sometimes referred to as a "keep alive" or a "deadman" timer.

@subsection Timer Service Routines

The timer service routine should adhere to @value{LANGUAGE} calling
conventions and have a prototype similar to the following:

@ifset is-C
@example
rtems_timer_service_routine user_routine(
  rtems_id   timer_id,
  void      *user_data
);
@end example
@end ifset

@ifset is-Ada
@example
procedure User_Routine(
  Timer_ID  : in     RTEMS.ID;
  User_Data : in     System.Address
);
@end example
@end ifset

Where the timer_id parameter is the RTEMS object ID
of the timer which is being fired and user_data is a pointer to
user-defined information which may be utilized by the timer
service routine.  The argument user_data may be NULL.

@section Operations

@subsection Creating a Timer

The @code{@value{DIRPREFIX}timer_create} directive creates a timer by
allocating a Timer Control Block (TMCB), assigning the timer a
user-specified name, and assigning it a timer ID.  Newly created
timers do not have a timer service routine associated with them
and are not active.

@subsection Obtaining Timer IDs

When a timer is created, RTEMS generates a unique
timer ID and assigns it to the created timer until it is
deleted.  The timer ID may be obtained by either of two methods.
First, as the result of an invocation of the
@code{@value{DIRPREFIX}timer_create}
directive, the timer ID is stored in a user provided location.
Second, the timer ID may be obtained later using the
@code{@value{DIRPREFIX}timer_ident} directive.  The timer ID
is used by other directives to manipulate this timer.

@subsection Initiating an Interval Timer

The @code{@value{DIRPREFIX}timer_fire_after} directive initiates a timer to
fire a user provided timer service routine after the specified
number of clock ticks have elapsed.  When the interval has
elapsed, the timer service routine will be invoked from the
@code{@value{DIRPREFIX}clock_tick} directive.

@subsection Initiating a Time of Day Timer

The @code{@value{DIRPREFIX}timer_fire_when} directive initiates a timer to
fire a user provided timer service routine when the specified
time of day has been reached.  When the interval has elapsed,
the timer service routine will be invoked from the
@code{@value{DIRPREFIX}clock_tick} directive.

@subsection Canceling a Timer

The @code{@value{DIRPREFIX}timer_cancel} directive is used to halt the
specified timer.  Once canceled, the timer service routine will
not fire unless the timer is reinitiated.  The timer can be
reinitiated using the @code{@value{DIRPREFIX}timer_reset},
@code{@value{DIRPREFIX}timer_fire_after}, and
@code{@value{DIRPREFIX}timer_fire_when} directives.

@subsection Resetting a Timer

The @code{@value{DIRPREFIX}timer_reset} directive is used to restore an
interval timer initiated by a previous invocation of
@code{@value{DIRPREFIX}timer_fire_after} to
its original interval length.  If the
timer has not been used or the last usage of this timer
was by a @code{@value{DIRPREFIX}timer_fire_when} directive, then an error is
returned.  The timer service routine is not changed or
fired by this directive.

@subsection Deleting a Timer

The @code{@value{DIRPREFIX}timer_delete} directive is used to delete a timer.
If the timer is running and has not expired, the timer is
automatically canceled.  The timer's control block is returned
to the TMCB free list when it is deleted.  A timer can be
deleted by a task other than the task which created the timer.
Any subsequent references to the timer's name and ID are invalid.

@section Directives

This section details the timer manager's directives.
A subsection is dedicated to each of this manager's directives
and describes the calling sequence, related constants, usage,
and status codes.

@page
@subsection TIMER_CREATE - Create a timer

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_create(
  rtems_name  name,
  rtems_id   *id
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Create (
   Name   : in     RTEMS.Name;
   ID     :    out RTEMS.ID;
   Result :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer created successfully@*
@code{@value{RPREFIX}INVALID_NAME} - invalid timer name@*
@code{@value{RPREFIX}TOO_MANY} - too many timers created

@subheading DESCRIPTION:

This directive creates a timer.  The assigned timer
id is returned in id.  This id is used to access the timer with
other timer manager directives.  For control and maintenance of
the timer, RTEMS allocates a TMCB from the local TMCB free pool
and initializes it.

@subheading NOTES:

This directive will not cause the calling task to be
preempted.

@page
@subsection TIMER_IDENT - Get ID of a timer

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_ident(
  rtems_name  name,
  rtems_id   *id
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Ident (
   Name   : in     RTEMS.Name;
   ID     :    out RTEMS.ID;
   Result :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer identified successfully@*
@code{@value{RPREFIX}INVALID_NAME} - timer name not found

@subheading DESCRIPTION:

This directive obtains the timer id associated with
the timer name to be acquired.  If the timer name is not unique,
then the timer id will match one of the timers with that name.
However, this timer id is not guaranteed to correspond to the
desired timer.  The timer id is used to access this timer in
other timer related directives.

@subheading NOTES:

This directive will not cause the running task to be
preempted.

@page
@subsection TIMER_CANCEL - Cancel a timer

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_cancel(
  rtems_id id
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Cancel (
   ID     : in     RTEMS.ID;
   Result :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer canceled successfully@*
@code{@value{RPREFIX}INVALID_ID} - invalid timer id

@subheading DESCRIPTION:

This directive cancels the timer id.  This timer will
be reinitiated by the next invocation of @code{@value{DIRPREFIX}timer_reset},
@code{@value{DIRPREFIX}timer_fire_after}, or
@code{@value{DIRPREFIX}timer_fire_when} with id.

@subheading NOTES:

This directive will not cause the running task to be preempted.

@page
@subsection TIMER_DELETE - Delete a timer

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_delete(
  rtems_id id
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Delete (
   ID     : in     RTEMS.ID;
   Result :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer deleted successfully@*
@code{@value{RPREFIX}INVALID_ID} - invalid timer id

@subheading DESCRIPTION:

This directive deletes the timer specified by id.  If
the timer is running, it is automatically canceled.  The TMCB
for the deleted timer is reclaimed by RTEMS.

@subheading NOTES:

This directive will not cause the running task to be
preempted.

A timer can be deleted by a task other than the task
which created the timer.

@page
@subsection TIMER_FIRE_AFTER - Fire timer after interval

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_fire_after(
  rtems_id                           id,
  rtems_interval                     ticks,
  rtems_timer_service_routine_entry  routine,
  void                              *user_data
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Fire_After (
   ID        : in     RTEMS.ID;
   Ticks     : in     RTEMS.Interval;
   Routine   : in     RTEMS.Timer_Service_Routine;
   User_Data : in     RTEMS.Address;
   Result    :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer initiated successfully@*
@code{@value{RPREFIX}INVALID_ID} - invalid timer id@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid interval

@subheading DESCRIPTION:

This directive initiates the timer specified by id.
If the timer is running, it is automatically canceled before
being initiated.  The timer is scheduled to fire after an
interval ticks clock ticks has passed.  When the timer fires,
the timer service routine routine will be invoked with the
argument user_data.

@subheading NOTES:

This directive will not cause the running task to be
preempted.

@page
@subsection TIMER_FIRE_WHEN - Fire timer when specified

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_fire_when(
  rtems_id                           id,
  rtems_time_of_day                 *wall_time,
  rtems_timer_service_routine_entry  routine,
  void                              *user_data
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Fire_When (
   ID        : in     RTEMS.ID;
   Wall_Time : in     RTEMS.Time_Of_Day;
   Routine   : in     RTEMS.Timer_Service_Routine;
   User_Data : in     RTEMS.Address;
   Result    :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer initiated successfully@*
@code{@value{RPREFIX}INVALID_ID} - invalid timer id@*
@code{@value{RPREFIX}NOT_DEFINED} - system date and time is not set@*
@code{@value{RPREFIX}INVALID_CLOCK} - invalid time of day

@subheading DESCRIPTION:

This directive initiates the timer specified by id.
If the timer is running, it is automatically canceled before
being initiated.  The timer is scheduled to fire at the time of
day specified by wall_time.  When the timer fires, the timer
service routine routine will be invoked with the argument
user_data.

@subheading NOTES:

This directive will not cause the running task to be
preempted.

@page
@subsection TIMER_RESET - Reset an interval timer

@subheading CALLING SEQUENCE:

@ifset is-C
@example
rtems_status_code rtems_timer_reset(
  rtems_id   id
);
@end example
@end ifset

@ifset is-Ada
@example
procedure Timer_Reset (
   ID     : in     RTEMS.ID;
   Result :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - timer reset successfully@*
@code{@value{RPREFIX}INVALID_ID} - invalid timer id@*
@code{@value{RPREFIX}NOT_DEFINED} - attempted to reset a when or newly created timer

@subheading DESCRIPTION:

This directive resets the timer associated with id.
This timer must have been previously initiated with a
@code{@value{DIRPREFIX}timer_fire_after}
directive.  If active the timer is canceled,
after which the timer is reinitiated using the same interval and
timer service routine which the original
@code{@value{DIRPREFIX}timer_fire_after}
directive used.

@subheading NOTES:

If the timer has not been used or the last usage of this timer
was by a @code{@value{DIRPREFIX}timer_fire_when}
directive, then the @code{@value{RPREFIX}NOT_DEFINED} error is
returned. 

Restarting a cancelled after timer results in the timer being 
reinitiated with its previous timer service routine and interval.

This directive will not cause the running task to be preempted.

