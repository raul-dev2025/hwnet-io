/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * hwnet_io_error.h - Definición de códigos de error para el driver hwnet_io (Kernel Space)
 *
 * Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
 */

#ifndef HWNET_IO_ERROR_H
#define HWNET_IO_ERROR_H

#include <linux/errno.h>
#include <linux/types.h>

#define HWNET_IO_SUCCESS 0
#define HWNET_IO_ERR_BASE 6000

#define HWNET_IO_ERR_INIT (HWNET_IO_ERR_BASE + 1)
#define HWNET_IO_ERR_NETDEV (HWNET_IO_ERR_BASE + 2)
#define HWNET_IO_ERR_IOCTL (HWNET_IO_ERR_BASE + 3)
#define HWNET_IO_ERR_QUEUE (HWNET_IO_ERR_BASE + 4)

#endif /* HWNET_IO_ERROR_H */