@c
@c  COPYRIGHT (c) 1988-1998.
@c  On-Line Applications Research Corporation (OAR).
@c  All rights reserved.
@c
@c  $Id$
@c

@chapter I/O Manager

@section Introduction

The input/output interface manager provides a
well-defined mechanism for accessing device drivers and a
structured methodology for organizing device drivers.  The
directives provided by the I/O manager are:

@itemize @bullet
@item @code{@value{DIRPREFIX}io_initialize} - Initialize a device driver
@item @code{@value{DIRPREFIX}io_register_name} - Register a device name
@item @code{@value{DIRPREFIX}io_lookup_name} - Look up a device name
@item @code{@value{DIRPREFIX}io_open} - Open a device
@item @code{@value{DIRPREFIX}io_close} - Close a device
@item @code{@value{DIRPREFIX}io_read} - Read from a device
@item @code{@value{DIRPREFIX}io_write} - Write to a device
@item @code{@value{DIRPREFIX}io_control} - Special device services
@end itemize

@section Background

@subsection Device Driver Table

Each application utilizing the RTEMS I/O manager must
specify the address of a Device Driver Table in its
Configuration Table.  This table contains each device driver's
entry points.  Each device driver may contain the following
entry points:

@itemize @bullet
@item Initialization
@item Open
@item Close
@item Read
@item Write
@item Control
@end itemize

If the device driver does not support a particular
entry point, then that entry in the Configuration Table should
be NULL.  RTEMS will return
@code{@value{RPREFIX}SUCCESSFUL} as the executive's and
zero (0) as the device driver's return code for these device
driver entry points.

@subsection Major and Minor Device Numbers

Each call to the I/O manager must provide a device's
major and minor numbers as arguments.  The major number is the
index of the requested driver's entry points in the Device
Driver Table, and is used to select a specific device driver.
The exact usage of the minor number is driver specific, but is
commonly used to distinguish between a number of devices
controlled by the same driver.

@subsection Device Names

The I/O Manager provides facilities to associate a
name with a particular device.  Directives are provided to
register the name of a device and to look up the major/minor
number pair associated with a device name.

@subsection Device Driver Environment

Application developers, as well as device driver
developers, must be aware of the following regarding the RTEMS
I/O Manager:

@itemize @bullet
@item A device driver routine executes in the context of the
invoking task.  Thus if the driver blocks, the invoking task
blocks.

@item The device driver is free to change the modes of the
invoking task, although the driver should restore them to their
original values.

@item Device drivers may be invoked from ISRs.

@item Only local device drivers are accessible through the I/O
manager.

@item A device driver routine may invoke all other RTEMS
directives, including I/O directives, on both local and global
objects.

@end itemize

Although the RTEMS I/O manager provides a framework
for device drivers, it makes no assumptions regarding the
construction or operation of a device driver.

@subsection Device Driver Interface

When an application invokes an I/O manager directive,
RTEMS determines which device driver entry point must be
invoked.  The information passed by the application to RTEMS is
then passed to the correct device driver entry point.  RTEMS
will invoke each device driver entry point assuming it is
compatible with the following prototype:

@ifset is-C
@example
rtems_device_driver io_entry(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument_block
);
@end example
@end ifset

@ifset is-Ada
@example
function IO_Entry (
  Major          : in     RTEMS.Device_Major_Number;
  Minor          : in     RTEMS.Device_Major_Number;
  Argument_Block : in     RTEMS.Address
) return RTEMS.Status_Code;
@end example
@end ifset

The format and contents of the parameter block are
device driver and entry point dependent.

It is recommended that a device driver avoid
generating error codes which conflict with those used by
application components.  A common technique used to generate
driver specific error codes is to make the most significant part
of the status indicate a driver specific code.

@subsection Device Driver Initialization

RTEMS automatically initializes all device drivers
when multitasking is initiated via the
@code{@value{DIRPREFIX}initialize_executive}
directive.  RTEMS initializes the device drivers by invoking
each device driver initialization entry point with the following
parameters:

@table @asis
@item major
the major device number for this device driver.

@item minor
zero.

@item argument_block
will point to  the Configuration Table.

@end table

The returned status will be ignored by RTEMS.  If the driver
cannot successfully initialize the device, then it should invoke
the fatal_error_occurred directive.

@section Operations

@subsection Register and Lookup Name

The @code{@value{DIRPREFIX}io_register} directive associates a name with the
specified device (i.e. major/minor number pair).  Device names
are typically registered as part of the device driver
initialization sequence.  The @code{@value{DIRPREFIX}io_lookup}
directive is used to
determine the major/minor number pair associated with the
specified device name.  The use of these directives frees the
application from being dependent on the arbitrary assignment of
major numbers in a particular application.  No device naming
conventions are dictated by RTEMS.

@subsection Accessing an Device Driver

The I/O manager provides directives which enable the
application program to utilize device drivers in a standard
manner.  There is a direct correlation between the RTEMS I/O
manager directives
@code{@value{DIRPREFIX}io_initialize},
@code{@value{DIRPREFIX}io_open},
@code{@value{DIRPREFIX}io_close},
@code{@value{DIRPREFIX}io_read},
@code{@value{DIRPREFIX}io_write}, and
@code{@value{DIRPREFIX}io_control}
and the underlying device driver entry points.

@section Directives

This section details the I/O manager's directives.  A
subsection is dedicated to each of this manager's directives and
describes the calling sequence, related constants, usage, and
status codes.

@page
@subsection IO_INITIALIZE - Initialize a device driver

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_initialize
@example
rtems_status_code rtems_io_initialize(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Initialize (
   Major        : in     RTEMS.Device_Major_Number;
   Minor        : in     RTEMS.Device_Minor_Number;
   Argument     : in     RTEMS.Address;
   Return_Value :    out RTEMS.Unsigned32;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid major device number

@subheading DESCRIPTION:

This directive calls the device driver initialization
routine specified in the Device Driver Table for this major
number. This directive is automatically invoked for each device
driver when multitasking is initiated via the
initialize_executive directive.

A device driver initialization module is responsible
for initializing all hardware and data structures associated
with a device. If necessary, it can allocate memory to be used
during other operations.

@subheading NOTES:

This directive may or may not cause the calling task
to be preempted.  This is dependent on the device driver being
initialized.

@page
@subsection IO_REGISTER_NAME - Register a device

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_register_name
@example
rtems_status_code rtems_io_register_name(
  char                      *name,
  rtems_device_major_number  major,
  rtems_device_minor_number  minor
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Register_Name (
   Name   : in     String;
   Major  : in     RTEMS.Device_Major_Number;
   Minor  : in     RTEMS.Device_Minor_Number;
   Result :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}TOO_MANY} - too many devices registered

@subheading DESCRIPTION:

This directive associates name with the specified
major/minor number pair.

@subheading NOTES:

This directive will not cause the calling task to be
preempted.

@page
@subsection IO_LOOKUP_NAME - Lookup a device

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_lookup_name
@example
rtems_status_code rtems_io_lookup_name(
  const char                *name,
  rtems_driver_name_t      **device_info
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Lookup_Name (
   Name         : in     String;
   Device_Info  :    out RTEMS.Driver_Name_t;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}UNSATISFIED} - name not registered

@subheading DESCRIPTION:

This directive returns the major/minor number pair
associated with the given device name in device_info.

@subheading NOTES:

This directive will not cause the calling task to be
preempted.

@page
@subsection IO_OPEN - Open a device

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_open
@example
rtems_status_code rtems_io_open(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Open (
   Major        : in     RTEMS.Device_Major_Number;
   Minor        : in     RTEMS.Device_Minor_Number;
   Argument     : in     RTEMS.Address;
   Return_Value :    out RTEMS.Unsigned32;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid major device number

@subheading DESCRIPTION:

This directive calls the device driver open routine
specified in the Device Driver Table for this major number.  The
open entry point is commonly used by device drivers to provide
exclusive access to a device.

@subheading NOTES:

This directive may or may not cause the calling task
to be preempted.  This is dependent on the device driver being
invoked.

@page
@subsection IO_CLOSE - Close a device

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_close
@example
rtems_status_code rtems_io_close(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Close (
   Major        : in     RTEMS.Device_Major_Number;
   Minor        : in     RTEMS.Device_Minor_Number;
   Argument     : in     RTEMS.Address;
   Return_Value :    out RTEMS.Unsigned32;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid major device number

@subheading DESCRIPTION:

This directive calls the device driver close routine
specified in the Device Driver Table for this major number.  The
close entry point is commonly used by device drivers to
relinquish exclusive access to a device.

@subheading NOTES:

This directive may or may not cause the calling task
to be preempted.  This is dependent on the device driver being
invoked.

@page
@subsection IO_READ - Read from a device

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_read
@example
rtems_status_code rtems_io_read(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Read (
   Major        : in     RTEMS.Device_Major_Number;
   Minor        : in     RTEMS.Device_Minor_Number;
   Argument     : in     RTEMS.Address;
   Return_Value :    out RTEMS.Unsigned32;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid major device number

@subheading DESCRIPTION:

This directive calls the device driver read routine
specified in the Device Driver Table for this major number.
Read operations typically require a buffer address as part of
the argument parameter block.  The contents of this buffer will
be replaced with data from the device.

@subheading NOTES:

This directive may or may not cause the calling task
to be preempted.  This is dependent on the device driver being
invoked.

@page
@subsection IO_WRITE - Write to a device

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_write
@example
rtems_status_code rtems_io_write(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Write (
   Major        : in     RTEMS.Device_Major_Number;
   Minor        : in     RTEMS.Device_Minor_Number;
   Argument     : in     RTEMS.Address;
   Return_Value :    out RTEMS.Unsigned32;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid major device number

@subheading DESCRIPTION:

This directive calls the device driver write routine
specified in the Device Driver Table for this major number.
Write operations typically require a buffer address as part of
the argument parameter block.  The contents of this buffer will
be sent to the device.

@subheading NOTES:

This directive may or may not cause the calling task
to be preempted.  This is dependent on the device driver being
invoked.

@page
@subsection IO_CONTROL - Special device services

@subheading CALLING SEQUENCE:

@ifset is-C
@c @findex rtems_io_control
@example
rtems_status_code rtems_io_control(
  rtems_device_major_number  major,
  rtems_device_minor_number  minor,
  void                      *argument
);
@end example
@end ifset

@ifset is-Ada
@example
procedure IO_Control (
   Major        : in     RTEMS.Device_Major_Number;
   Minor        : in     RTEMS.Device_Minor_Number;
   Argument     : in     RTEMS.Address;
   Return_Value :    out RTEMS.Unsigned32;
   Result       :    out RTEMS.Status_Codes
);
@end example
@end ifset

@subheading DIRECTIVE STATUS CODES:
@code{@value{RPREFIX}SUCCESSFUL} - successfully initialized@*
@code{@value{RPREFIX}INVALID_NUMBER} - invalid major device number

@subheading DESCRIPTION:

This directive calls the device driver I/O control
routine specified in the Device Driver Table for this major
number.  The exact functionality of the driver entry called by
this directive is driver dependent.  It should not be assumed
that the control entries of two device drivers are compatible.
For example, an RS-232 driver I/O control operation may change
the baud rate of a serial line, while an I/O control operation
for a floppy disk driver may cause a seek operation.

@subheading NOTES:

This directive may or may not cause the calling task
to be preempted.  This is dependent on the device driver being
invoked.



