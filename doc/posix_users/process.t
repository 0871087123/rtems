@c
@c COPYRIGHT (c) 1988-1999.
@c On-Line Applications Research Corporation (OAR).
@c All rights reserved.
@c
@c $Id$
@c

@chapter Process Creation and Execution Manager

@section Introduction

The process creation and execution manager is ...

The directives provided by the process creation and execution manager are:

@itemize @bullet
@item @code{fork} - Create a Process
@item @code{execl} - Execute a File
@item @code{execv} - Execute a File
@item @code{execle} - Execute a File
@item @code{execve} - Execute a File
@item @code{execlp} - Execute a File
@item @code{execvp} - Execute a File
@item @code{pthread_atfork} - Register Fork Handlers
@item @code{wait} - Wait for Process Termination
@item @code{waitpid} - Wait for Process Termination
@item @code{_exit} - Terminate a Process
@end itemize

@section Background

There is currently no text in this section.

@section Operations

There is currently no text in this section.

@section Directives

This section details the process creation and execution manager's directives.
A subsection is dedicated to each of this manager's directives
and describes the calling sequence, related constants, usage,
and status codes.

@c
@c
@c
@page
@subsection fork - Create a Process

@findex fork
@cindex  create a process

@subheading CALLING SEQUENCE:

@ifset is-C
@example
#include <sys/types.h>

int fork( void );
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection execl - Execute a File

@findex execl
@cindex  execute a file

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int execl(
const char *path,
const char *arg,
...
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection execv - Execute a File

@findex execv
@cindex  execute a file

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int execv(
const char *path,
char const *argv[],
...
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection execle - Execute a File

@findex execle
@cindex  execute a file

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int execle(
const char *path,
const char *arg,
...
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection execve - Execute a File

@findex execve
@cindex  execute a file

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int execve(
const char *path,
char *const argv[],
char *const envp[]
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection execlp - Execute a File

@findex execlp
@cindex  execute a file

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int execlp(
const char *file,
const char *arg,
...
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection execvp - Execute a File

@findex execvp
@cindex  execute a file

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int execvp(
const char *file,
char *const argv[]
...
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection pthread_atfork - Register Fork Handlers

@findex pthread_atfork
@cindex  register fork handlers

@subheading CALLING SEQUENCE:

@ifset is-C
@example
#include <sys/types.h>

int pthread_atfork(
void (*prepare)(void),
void (*parent)(void),
void (*child)(void)
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection wait - Wait for Process Termination

@findex wait
@cindex  wait for process termination

@subheading CALLING SEQUENCE:

@ifset is-C
@example
#include <sys/types.h>
#include <sys/wait.h>

int wait(
int *stat_loc
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection waitpid - Wait for Process Termination

@findex waitpid
@cindex  wait for process termination

@subheading CALLING SEQUENCE:

@ifset is-C
@example
int wait(
pid_t pid,
int *stat_loc,
int options
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

@table @b
@item ENOSYS
This routine is not supported by RTEMS.

@end table

@subheading DESCRIPTION:

This routine is not supported by RTEMS.

@subheading NOTES:

NONE

@c
@c
@c
@page
@subsection _exit - Terminate a Process

@findex _exit
@cindex  terminate a process

@subheading CALLING SEQUENCE:

@ifset is-C
@example
void _exit(
int status
);
@end example
@end ifset

@ifset is-Ada
@end ifset

@subheading STATUS CODES:

NONE

@subheading DESCRIPTION:

The @code{_exit()} function terminates the calling process.

@subheading NOTES:

In RTEMS, a process is equivalent to the entire application on a single
processor. Invoking this service terminates the application.
