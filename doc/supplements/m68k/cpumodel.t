@c
@c  COPYRIGHT (c) 1988-1998.
@c  On-Line Applications Research Corporation (OAR).
@c  All rights reserved.
@c
@c  $Id$
@c

@ifinfo
@node CPU Model Dependent Features, CPU Model Dependent Features Introduction, Preface, Top
@end ifinfo
@chapter CPU Model Dependent Features
@ifinfo
@menu
* CPU Model Dependent Features Introduction::
* CPU Model Dependent Features CPU Model Name::
* CPU Model Dependent Features Floating Point Unit::
* CPU Model Dependent Features BFFFO Instruction::
* CPU Model Dependent Features Vector Base Register::
* CPU Model Dependent Features Separate Stacks::
* CPU Model Dependent Features Pre-Indexing Address Mode::
* CPU Model Dependent Features Extend Byte to Long Instruction::
@end menu
@end ifinfo

@ifinfo
@node CPU Model Dependent Features Introduction, CPU Model Dependent Features CPU Model Name, CPU Model Dependent Features, CPU Model Dependent Features
@end ifinfo
@section Introduction

Microprocessors are generally classified into
families with a variety of CPU models or implementations within
that family.  Within a processor family, there is a high level
of binary compatibility.  This family may be based on either an
architectural specification or on maintaining compatibility with
a popular processor.  Recent microprocessor families such as the
SPARC or PA-RISC are based on an architectural specification
which is independent or any particular CPU model or
implementation.  Older families such as the M68xxx and the iX86
evolved as the manufacturer strived to produce higher
performance processor models which maintained binary
compatibility with older models.

RTEMS takes advantage of the similarity of the
various models within a CPU family.  Although the models do vary
in significant ways, the high level of compatibility makes it
possible to share the bulk of the CPU dependent executive code
across the entire family.  Each processor family supported by
RTEMS has a list of features which vary between CPU models
within a family.  For example, the most common model dependent
feature regardless of CPU family is the presence or absence of a
floating point unit or coprocessor.  When defining the list of
features present on a particular CPU model, one simply notes
that floating point hardware is or is not present and defines a
single constant appropriately.  Conditional compilation is
utilized to include the appropriate source code for this CPU
model's feature set.  It is important to note that this means
that RTEMS is thus compiled using the appropriate feature set
and compilation flags optimal for this CPU model used.  The
alternative would be to generate a binary which would execute on
all family members using only the features which were always
present.

This chapter presents the set of features which vary
across SPARC implementations and are of importance to RTEMS.
The set of CPU model feature macros are defined in the file
c/src/exec/score/cpu/m68k/m68k.h based upon the particular CPU
model defined on the compilation command line.

@ifinfo
@node CPU Model Dependent Features CPU Model Name, CPU Model Dependent Features Floating Point Unit, CPU Model Dependent Features Introduction, CPU Model Dependent Features
@end ifinfo
@section CPU Model Name

The macro CPU_MODEL_NAME is a string which designates
the name of this CPU model.  For example, for the MC68020
processor, this macro is set to the string "mc68020".

@ifinfo
@node CPU Model Dependent Features Floating Point Unit, CPU Model Dependent Features BFFFO Instruction, CPU Model Dependent Features CPU Model Name, CPU Model Dependent Features
@end ifinfo
@section Floating Point Unit

The macro M68K_HAS_FPU is set to 1 to indicate that
this CPU model has a hardware floating point unit and 0
otherwise.  It does not matter whether the hardware floating
point support is incorporated on-chip or is an external
coprocessor.

@ifinfo
@node CPU Model Dependent Features BFFFO Instruction, CPU Model Dependent Features Vector Base Register, CPU Model Dependent Features Floating Point Unit, CPU Model Dependent Features
@end ifinfo
@section BFFFO Instruction

The macro M68K_HAS_BFFFO is set to 1 to indicate that
this CPU model has the bfffo instruction.

@ifinfo
@node CPU Model Dependent Features Vector Base Register, CPU Model Dependent Features Separate Stacks, CPU Model Dependent Features BFFFO Instruction, CPU Model Dependent Features
@end ifinfo
@section Vector Base Register

The macro M68K_HAS_VBR is set to 1 to indicate that
this CPU model has a vector base register (vbr).

@ifinfo
@node CPU Model Dependent Features Separate Stacks, CPU Model Dependent Features Pre-Indexing Address Mode, CPU Model Dependent Features Vector Base Register, CPU Model Dependent Features
@end ifinfo
@section Separate Stacks

The macro M68K_HAS_SEPARATE_STACKS is set to 1 to
indicate that this CPU model has separate interrupt, user, and
supervisor mode stacks.

@ifinfo
@node CPU Model Dependent Features Pre-Indexing Address Mode, CPU Model Dependent Features Extend Byte to Long Instruction, CPU Model Dependent Features Separate Stacks, CPU Model Dependent Features
@end ifinfo
@section Pre-Indexing Address Mode

The macro M68K_HAS_PREINDEXING is set to 1 to indicate that
this CPU model has the pre-indexing address mode.

@ifinfo
@node CPU Model Dependent Features Extend Byte to Long Instruction, Calling Conventions, CPU Model Dependent Features Pre-Indexing Address Mode, CPU Model Dependent Features
@end ifinfo
@section Extend Byte to Long Instruction
 
The macro M68K_HAS_EXTB_L is set to 1 to indicate that this CPU model 
has the extb.l instruction.  This instruction is supposed to be available
in all models based on the cpu32 core as well as mc68020 and up models.
