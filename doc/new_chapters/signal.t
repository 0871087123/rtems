@c
@c  COPYRIGHT (c) 1988-1998.
@c  On-Line Applications Research Corporation (OAR).
@c  All rights reserved.
@c
@c  $Id$
@c

@chapter Signal Manager

@section Introduction

The signal manager ...

The directives provided by the signal manager are:

@itemize @bullet
@item @code{sigaddset} - Add a Signal to a Signal Set
@item @code{sigdelset} - Delete a Signal from a Signal Set
@item @code{sigfillset} - Fill a Signal Set
@item @code{sigismember} - Is Signal a Member of a Signal Set
@item @code{sigemptyset} - Empty a Signal Set
@item @code{sigaction} - Examine and Change Signal Action
@item @code{pthread_kill} - Send a Signal to a Thread
@item @code{sigprocmask} - Examine and Change Process Blocked Signals
@item @code{pthread_sigmask} - Examine and Change Thread Blocked Signals
@item @code{kill} - Send a Signal to a Process
@item @code{sigpending} - Examine Pending Signals
@item @code{sigsuspend} - Wait for a Signal
@item @code{pause} - Suspend Process Execution
@item @code{sigwait} - Synchronously Accept a Signal
@item @code{sigwaitinfo} - Synchronously Accept a Signal
@item @code{sigtimedwait} - Synchronously Accept a Signal with Timeout
@item @code{sigqueue} - Queue a Signal to a Process
@item @code{alarm} - Schedule Alarm
@end itemize

@section Background

@subsection Signal Delivery

Signals directed at a thread are delivered to the specified thread.

Signals directed at a process are delivered to a thread which is selected
based on the following algorithm:

@enumerate
@item If the action for this signal is currently @code{SIG_IGN},
then the signal is simply ignored.

@item If the currently executing thread has the signal unblocked, then
the signal is delivered to it.

@item If any threads are currently blocked waiting for this signal 
(@code{sigwait()}), then the signal is delivered to the highest priority 
thread waiting for this signal.

@item If any other threads are willing to accept delivery of the signal, then
the signal is delivered to the highest priority thread of this set.  In the
event, multiple threads of the same priority are willing to accept this
signal, then priority is given first to ready threads, then to threads
blocked on calls which may be interrupted, and finally to threads blocked
on non-interruptible calls.

@item In the event the signal still can not be delivered, then it is left
pending.  The first thread to unblock the signal (@code{sigprocmask()} or
@code{pthread_sigprocmask()}) or to wait for this signal
(@code{sigwait()}) will be the recipient of the signal.

@end enumerate

@section Operations

There is currently no text in this section.

@section Directives

This section details the signal manager's directives.
A subsection is dedicated to each of this manager's directives
and describes the calling sequence, related constants, usage,
and status codes.

@page
@subsection sigaddset - Add a Signal to a Signal Set

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigaddset(
  sigset_t   *set,
  int         signo
);
@end example

@subheading STATUS CODES:

@table @b
@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This function adds the @code{signo} to the specified signal @code{set}.

@subheading NOTES:

@page
@subsection sigdelset - Delete a Signal from a Signal Set

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigdelset(
  sigset_t   *set,
  int         signo
);
@end example

@subheading STATUS CODES:

@table @b
@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This function deletes the @code{signo} to the specified signal @code{set}.

@subheading NOTES:

NONE

@page
@subsection sigfillset - Fill a Signal Set

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigfillset(
  sigset_t   *set
);
@end example

@subheading STATUS CODES:

@table @b

@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This function fills the specified signal @code{set} such that all
signals are set.

@subheading NOTES:

NONE

@page
@subsection sigismember - Is Signal a Member of a Signal Set

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigismember(
  const sigset_t   *set,
  int               signo
);
@end example

@subheading STATUS CODES:

@table @b

@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This function returns returns 1 if @code{signo} is a member of @code{set}
and 0 otherwise.

@subheading NOTES:

NONE

@page
@subsection sigemptyset - Empty a Signal Set

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigemptyset(
  sigset_t   *set
);
@end example

@subheading STATUS CODES:

@table @b

@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This function fills the specified signal @code{set} such that all
signals are cleared.

@subheading NOTES:

NONE

@page
@subsection sigaction - Examine and Change Signal Action

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigaction(
  int                     sig,
  const struct sigaction *act,
  struct sigaction       *oact
);
@end example

@subheading STATUS CODES:

@table @b
@item EINVAL
Invalid argument passed.

@item ENOTSUP
Realtime Signals Extension option not supported.

@end table

@subheading DESCRIPTION:

This function is used to change the action taken by a process on 
receipt of the specfic signal @code{sig}.  The new action is 
specified by @code{act} and the previous action is returned
via @code{oact}.

@subheading NOTES:

The signal number cannot be SIGKILL.

@page
@subsection pthread_kill - Send a Signal to a Thread

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int pthread_kill(
  pthread_t   thread,
  int         sig
);
@end example

@subheading STATUS CODES:

@table @b

@item ESRCH
The thread indicated by the parameter thread is invalid.

@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This functions sends the specified signal @code{sig} to @code{thread}.

@subheading NOTES:

NONE

@page
@subsection sigprocmask - Examine and Change Process Blocked Signals
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int sigprocmask(
  int               how,
  const sigset_t   *set,
  sigset_t         *oset
);
@end example
 
@subheading STATUS CODES:

@table @b

@item EINVAL
Invalid argument passed.
 
@end table
 
@subheading DESCRIPTION:
 
This function is used to alter the set of currently blocked signals
on a process wide basis.  A blocked signal will not be received by the
process.  The behavior of this function is dependent on the value of
@code{how} which may be one of the following:

@itemize @code
@item SIG_BLOCK
The set of blocked signals is set to the union of @code{set} and 
those signals currently blocked.

@item SIG_UNBLOCK
The signals specific in @code{set} are removed from the currently
blocked set.

@item SIG_SETMASK
The set of currently blocked signals is set to @code{set}.

@end itemize

If @code{oset} is not @code{NULL}, then the set of blocked signals
prior to this call is returned in @code{oset}.

@subheading NOTES:

It is not an error to unblock a signal which is not blocked.

@page
@subsection pthread_sigmask - Examine and Change Thread Blocked Signals

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int pthread_sigmask(
  int               how,
  const sigset_t   *set,
  sigset_t         *oset
);
@end example

@subheading STATUS CODES:
@table @b
@item EINVAL
Invalid argument passed.

@end table

@subheading DESCRIPTION:

This function is used to alter the set of currently blocked signals
for the calling thread.  A blocked signal will not be received by the
process.  The behavior of this function is dependent on the value of
@code{how} which may be one of the following:

@table @code
@item SIG_BLOCK
The set of blocked signals is set to the union of @code{set} and
those signals currently blocked.

@item SIG_UNBLOCK
The signals specific in @code{set} are removed from the currently
blocked set.

@item SIG_SETMASK
The set of currently blocked signals is set to @code{set}.

@end table

If @code{oset} is not @code{NULL}, then the set of blocked signals
prior to this call is returned in @code{oset}.

@subheading NOTES:

It is not an error to unblock a signal which is not blocked.


@page
@subsection kill - Send a Signal to a Process

@subheading CALLING SEQUENCE:

@example
#include <sys/types.h>
#include <signal.h>

int kill(
  pid_t pid,
  int   sig
);
@end example

@subheading STATUS CODES:
@table @b
@item EINVAL
Invalid argument passed.

@item EPERM
Process does not have permission to send the signal to any receiving process.

@item ESRCH
The process indicated by the parameter pid is invalid.

@end table

@subheading DESCRIPTION:

This function sends the signal @code{sig} to the process @code{pid}.

@subheading NOTES:

NONE
 
@page
@subsection sigpending - Examine Pending Signals
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int sigpending(
  const sigset_t  *set
);
@end example
 
@subheading STATUS CODES:

On error, this routine returns -1 and sets errno to one of the following:
 
@table @b

@item EFAULT
Invalid address for set.

@end table

@subheading DESCRIPTION:

This function allows the caller to examine the set of currently pending
signals.  A pending signal is one which has been raised but is currently
blocked.  The set of pending signals is returned in @code{set}.
 
@subheading NOTES:

NONE

@page
@subsection sigsuspend - Wait for a Signal
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int sigsuspend(
  const sigset_t  *sigmask
);
@end example
 
@subheading STATUS CODES:

@table @b
Returns -1 and sets errno.

@item EINTR
Signal interrupted this function.
 
@end table
 
@subheading DESCRIPTION:

This function temporarily replaces the signal mask for the process
with that specified by @code{sigmask} and blocks the calling thread
until the signal is raised.
 
@subheading NOTES:

NONE

@page
@subsection pause - Suspend Process Execution
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int pause( void );
@end example
 
@subheading STATUS CODES:

@table @b
Returns -1 and sets errno.
 
@item EINTR
Signal interrupted this function.
 
@end table
 
@subheading DESCRIPTION:

This function causes the calling thread to be blocked until the signal
is received.
 
@subheading NOTES:

NONE
 
@page
@subsection sigwait - Synchronously Accept a Signal

@subheading CALLING SEQUENCE:

@example
#include <signal.h>

int sigwait(
  const sigset_t  *set,
  int             *sig
);
@end example

@subheading STATUS CODES:
@table @b
@item EINVAL
Invalid argument passed.

@item EINTR
Signal interrupted this function.

@end table

@subheading DESCRIPTION:

This function selects a pending signal based on the set specified in
@code{set}, atomically clears it from the set of pending signals, and
returns the signal number for that signal in @code{sig}.


@subheading NOTES:

NONE

@page
@subsection sigwaitinfo - Synchronously Accept a Signal
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int sigwaitinfo(
  const sigset_t  *set,
  siginfo_t       *info
);
@end example
 
@subheading STATUS CODES:
@table @b
@item EINTR
Signal interrupted this function.
 
@end table
 
@subheading DESCRIPTION:
 
This function selects a pending signal based on the set specified in
@code{set}, atomically clears it from the set of pending signals, and
returns information about that signal in @code{info}.

@subheading NOTES:

NONE

@page
@subsection sigtimedwait - Synchronously Accept a Signal with Timeout
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int sigtimedwait(
  const sigset_t         *set,
  siginfo_t              *info,
  const struct timespec  *timeout
);
@end example
 
@subheading STATUS CODES:
@table @b
@item EAGAIN
Timed out while waiting for the specified signal set.
 
@item EINVAL
Nanoseconds field of the timeout argument is invalid.
 
@item EINTR
Signal interrupted this function.
 
@end table
 
@subheading DESCRIPTION:
 
This function selects a pending signal based on the set specified in
@code{set}, atomically clears it from the set of pending signals, and
returns information about that signal in @code{info}.  The calling thread
will block up to @code{timeout} waiting for the signal to arrive.

@subheading NOTES:

If @code{timeout} is NULL, then the calling thread will wait forever for
the specified signal set.

@page
@subsection sigqueue - Queue a Signal to a Process
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
int sigqueue(
  pid_t               pid,
  int                 signo,
  const union sigval  value
);
@end example
 
@subheading STATUS CODES:

@table @b

@item EAGAIN
No resources available to queue the signal.  The process has already
queued SIGQUEUE_MAX signals that are still pending at the receiver
or the systemwide resource limit has been exceeded.
 
@item EINVAL
The value of the signo argument is an invalid or unsupported signal
number.
 
@item EPERM
The process does not have the appropriate privilege to send the signal
to the receiving process.

@item ESRCH
The process pid does not exist.
 
@end table
 
@subheading DESCRIPTION:

This function sends the signal specified by @code{signo} to the
process @code{pid}
 
@subheading NOTES:

NONE

@page
@subsection alarm - Schedule Alarm
 
@subheading CALLING SEQUENCE:
 
@example
#include <signal.h>
 
unsigned int alarm(
  unsigned int  seconds
);
@end example
 
@subheading STATUS CODES:

This call always succeeds.
 
@subheading DESCRIPTION:
 
If there was a previous @code{alarm()} request with time remaining,
then this routine returns the number of seconds until that outstanding
alarm would have fired.  If no previous @code{alarm()} request was
outstanding, then zero is returned.

@subheading NOTES:

NONE
