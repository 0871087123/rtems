@c
@c  COPYRIGHT (c) 1988-1998.
@c  On-Line Applications Research Corporation (OAR).
@c  All rights reserved.
@c
@c  $Id$
@c

@ifinfo
@node Calling Conventions, Calling Conventions Introduction, CPU Model Dependent Features Low Power Model, Top
@end ifinfo
@chapter Calling Conventions
@ifinfo
@menu
* Calling Conventions Introduction::
* Calling Conventions Programming Model::
* Calling Conventions Call and Return Mechanism::
* Calling Conventions Calling Mechanism::
* Calling Conventions Register Usage::
* Calling Conventions Parameter Passing::
* Calling Conventions User-Provided Routines::
@end menu
@end ifinfo

@ifinfo
@node Calling Conventions Introduction, Calling Conventions Programming Model, Calling Conventions, Calling Conventions
@end ifinfo
@section Introduction

Each high-level language compiler generates
subroutine entry and exit code based upon a set of rules known
as the compiler's calling convention.   These rules address the
following issues:

@itemize @bullet
@item register preservation and usage

@item parameter passing

@item call and return mechanism
@end itemize

A compiler's calling convention is of importance when
interfacing to subroutines written in another language either
assembly or high-level.  Even when the high-level language and
target processor are the same, different compilers may use
different calling conventions.  As a result, calling conventions
are both processor and compiler dependent.

RTEMS supports the Embedded Application Binary Interface (EABI)
calling convention.  Documentation for EABI is available by sending
a message with a subject line of "EABI" to eabi@@goth.sis.mot.com.

@ifinfo
@node Calling Conventions Programming Model, Calling Conventions Non-Floating Point Registers, Calling Conventions Introduction, Calling Conventions
@end ifinfo
@section Programming Model
@ifinfo
@menu
* Calling Conventions Non-Floating Point Registers::
* Calling Conventions Floating Point Registers::
* Calling Conventions Special Registers::
@end menu
@end ifinfo

This section discusses the programming model for the
PowerPC architecture.

@ifinfo
@node Calling Conventions Non-Floating Point Registers, Calling Conventions Floating Point Registers, Calling Conventions Programming Model, Calling Conventions Programming Model
@end ifinfo
@subsection Non-Floating Point Registers

The PowerPC architecture defines thirty-two non-floating point registers
directly visible to the programmer.  In thirty-two bit implementations, each
register is thirty-two bits wide.  In sixty-four bit implementations, each
register is sixty-four bits wide.

These registers are referred to as @code{gpr0} to @code{gpr31}.

Some of the registers serve defined roles in the EABI programming model.  
The following table describes the role of each of these registers:

@ifset use-ascii
@example
@group
     +---------------+----------------+------------------------------+
     | Register Name | Alternate Name |         Description          |
     +---------------+----------------+------------------------------+
     |      r1       |      sp        |         stack pointer        |
     +---------------+----------------+------------------------------+
     |               |                |  global pointer to the Small |
     |      r2       |      na        |     Constant Area (SDA2)     |
     +---------------+----------------+------------------------------+
     |    r3 - r12   |      na        | parameter and result passing |
     +---------------+----------------+------------------------------+
     |               |                |  global pointer to the Small |
     |      r13      |      na        |         Data Area (SDA)      |
     +---------------+----------------+------------------------------+
@end group
@end example
@end ifset

@ifset use-tex
@sp 1
@tex
\centerline{\vbox{\offinterlineskip\halign{
\vrule\strut#&
\hbox to 1.75in{\enskip\hfil#\hfil}&
\vrule#&
\hbox to 1.75in{\enskip\hfil#\hfil}&
\vrule#&
\hbox to 2.50in{\enskip\hfil#\hfil}&
\vrule#\cr
\noalign{\hrule}
&\bf Register Name &&\bf Alternate Names&&\bf Description&\cr\noalign{\hrule}
&r1&&sp&&stack pointer&\cr\noalign{\hrule}
&r2&&NA&&global pointer to the Small&\cr
&&&&&Constant Area (SDA2)&\cr\noalign{\hrule}
&r3 - r12&&NA&&parameter and result passing&\cr\noalign{\hrule}
&r13&&NA&&global pointer to the Small&\cr
&&&&&Data Area (SDA2)&\cr\noalign{\hrule}
}}\hfil}
@end tex
@end ifset
 
@ifset use-html
@html
<CENTER>
  <TABLE COLS=3 WIDTH="80%" BORDER=2>
<TR><TD ALIGN=center><STRONG>Register Name</STRONG></TD>
    <TD ALIGN=center><STRONG>Alternate Name</STRONG></TD>
    <TD ALIGN=center><STRONG>Description</STRONG></TD></TR>
<TR><TD ALIGN=center>r1</TD>
    <TD ALIGN=center>sp</TD>
    <TD ALIGN=center>stack pointer</TD></TR>
<TR><TD ALIGN=center>r2</TD>
    <TD ALIGN=center>na</TD>
    <TD ALIGN=center>global pointer to the Small Constant Area (SDA2)</TD></TR>
<TR><TD ALIGN=center>r3 - r12</TD>
    <TD ALIGN=center>NA</TD>
    <TD ALIGN=center>parameter and result passing</TD></TR>
<TR><TD ALIGN=center>r13</TD>
    <TD ALIGN=center>NA</TD>
    <TD ALIGN=center>global pointer to the Small Data Area (SDA)</TD></TR>
  </TABLE>
</CENTER>
@end html
@end ifset


@ifinfo
@node Calling Conventions Floating Point Registers, Calling Conventions Special Registers, Calling Conventions Non-Floating Point Registers, Calling Conventions Programming Model
@end ifinfo
@subsection Floating Point Registers

The PowerPC architecture includes thirty-two, sixty-four bit
floating point registers.  All PowerPC floating point instructions 
interpret these registers as 32 double precision floating point registers,
regardless of whether the processor has 64-bit or 32-bit implementation.

The floating point status and control register (fpscr) records exceptions
and the type of result generated by floating-point operations.
Additionally, it controls the rounding mode of operations and allows the
reporting of floating exceptions to be enabled or disabled.

@ifinfo
@node Calling Conventions Special Registers, Calling Conventions Call and Return Mechanism, Calling Conventions Floating Point Registers, Calling Conventions Programming Model
@end ifinfo
@subsection Special Registers

The PowerPC architecture includes a number of special registers
which are critical to the programming model:

@table @b

@item Machine State Register

The MSR contains the processor mode, power management mode, endian mode,
exception information, privilege level, floating point available and
floating point excepiton mode, address translation information and
the exception prefix.

@item Link Register

The LR contains the return address after a function call.  This register
must be saved before a subsequent subroutine call can be made.  The
use of this register is discussed further in the @b{Call and Return
Mechanism} section below.

@item Count Register

The CTR contains the iteration variable for some loops.  It may also be used
for indirect function calls and jumps.

@end table

@ifinfo
@node Calling Conventions Call and Return Mechanism, Calling Conventions Calling Mechanism, Calling Conventions Special Registers, Calling Conventions
@end ifinfo
@section Call and Return Mechanism

The PowerPC architecture supports a simple yet effective call
and return mechanism.  A subroutine is invoked
via the "branch and link" (@code{bl}) and
"brank and link absolute" (@code{bla})
instructions.  This instructions place the return address
in the Link Register (LR).  The callee returns to the caller by 
executing a "branch unconditional to the link register" (@code{blr})
instruction.  Thus the callee returns to the caller via a jump
to the return address which is stored in the LR.

The previous contents of the LR are not automatically saved 
by either the @code{bl} or @code{bla}.  It is the responsibility
of the callee to save the contents of the LR before invoking
another subroutine.  If the callee invokes another subroutine,
it must restore the LR before executing the @code{blr} instruction
to return to the caller.

It is important to note that the PowerPC subroutine
call and return mechanism does not automatically save and
restore any registers.

The LR may be accessed as special purpose register 8 (@code{SPR8}) using the
"move from special register" (@code{mfspr}) and
"move to special register" (@code{mtspr}) instructions.

@ifinfo
@node Calling Conventions Calling Mechanism, Calling Conventions Register Usage, Calling Conventions Call and Return Mechanism, Calling Conventions
@end ifinfo
@section Calling Mechanism

All RTEMS directives are invoked using the regular
PowerPC EABI calling convention via the @code{bl} or
@code{bla} instructions.

@ifinfo
@node Calling Conventions Register Usage, Calling Conventions Parameter Passing, Calling Conventions Calling Mechanism, Calling Conventions
@end ifinfo
@section Register Usage

As discussed above, the call instruction does not
automatically save any registers.  It is the responsibility
of the callee to save and restore any registers which must be preserved
across subroutine calls.  The callee is responsible for saving 
callee-preserved registers to the program stack and restoring them
before returning to the caller.

@ifinfo
@node Calling Conventions Parameter Passing, Calling Conventions User-Provided Routines, Calling Conventions Register Usage, Calling Conventions
@end ifinfo
@section Parameter Passing

RTEMS assumes that arguments are placed in the
general purpose registers with the first argument in 
register 3 (@code{r3}), the second argument in general purpose
register 4 (@code{r4}), and so forth until the seventh
argument is in general purpose register 10 (@code{r10}).  
If there are more than seven arguments, then subsequent arguments
are placed on the program stack.  The following pseudo-code
illustrates the typical sequence used to call a RTEMS directive
with three (3) arguments:

@example
load third argument into r5
load second argument into r4
load first argument into r3
invoke directive
@end example

@ifinfo
@node Calling Conventions User-Provided Routines, Memory Model, Calling Conventions Parameter Passing, Calling Conventions
@end ifinfo
@section User-Provided Routines

All user-provided routines invoked by RTEMS, such as
user extensions, device drivers, and MPCI routines, must also
adhere to these same calling conventions.


