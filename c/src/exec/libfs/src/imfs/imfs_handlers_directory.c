/*
 *  Operations Table for Directories for the IMFS
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

#include <errno.h>

#include "imfs.h"

/*
 *  Set of operations handlers for operations on directories.
 */

rtems_filesystem_file_handlers_r IMFS_directory_handlers = {
  imfs_dir_open,
  imfs_dir_close,
  imfs_dir_read,
  NULL,             /* write */
  NULL,             /* ioctl */
  imfs_dir_lseek,
  imfs_dir_fstat,
  IMFS_fchmod,
  NULL,             /* ftruncate */
  NULL,             /* fpathconf */
  NULL,             /* fsync */
  IMFS_fdatasync,
  IMFS_fcntl
};
