// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * hwnet_io01.c - Plantilla base para pruebas de red del driver hwnet_io
 *
 * Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
 */
#include <errno.h>     // Gestión de error devultos por mmap e ioctl
#include <fcntl.h>     // Definición de flags de apertura de archivos como O_RDWR
#include <stdint.h>    // Tipos de datos de ancho fijo para estructuras del driver
#include <stdio.h>     // Funciones estándar de entrada y salida para mensajes auxiliares
#include <stdlib.h>    // Utilidades generales del sistema y gestión de memoria
#include <string.h>    // Manipulación y formateo de cadenas de texto
#include <sys/types.h> // Definiciones de tipos primitivos de sistema como off_t
#include <unistd.h>    // Invocación de llamadas al sistema posix como close()

/* Cabeceras específicas del subsistema de red de Linux */
#include <sys/socket.h>    // Definiciones base de sockets
#include <net/if.h>        // Estructuras para interfaces de red (ifreq, etc.)
#include <linux/netlink.h> // Definicioines para futuros sockets Netlink

#include "tst_test.h"         // Macroestructuras y API principal del framework de pruebas
#include "user/hwnet_error.h" // Esquema de códigos de error personalizado

static void setup(void)
{
  unsigned int ifindex = if_nametoindex("hwnet_io");
  if (ifindex == 0)
  {
    tst_brk(TBROK, "The network interface 'hwnet_io' was not registered");
  }
  tst_res(TPASS, "Network interface 'hwnet_io' found: %u", ifindex);
}

typedef struct hwnet_ctx
{
  int sock;
  struct ifreq ifr;
  int initialized;
} hwnet_ctx_t;

static hwnet_ctx_t test_ctx = {
    .sock = -1,
    .initialized = 0};

static void cleanup(void)
{
  if (test_ctx.sock >= 0)
  {
    close(test_ctx.sock);
    test_ctx.sock = -1;
    tst_res(TINFO, "Socket descriptor closed.");
  }
}

static void check_hwnet_io_flags()
{
  test_ctx.sock = socket(AF_INET, SOCK_DGRAM, 0);
  if (test_ctx.sock < 0)
  {
    tst_brk(TBROK | TERRNO, "Failed to initialize control socket [Base code: %d]",
            HWNET_IO_ERR_SOCKET_INIT);
  }
  memset(&test_ctx.ifr, 0, sizeof(test_ctx.ifr));
  strncpy(test_ctx.ifr.ifr_name, "hwnet_io", IFNAMSIZ - 1);

  if (ioctl(test_ctx.sock, SIOCGIFFLAGS, &test_ctx.ifr) < 0)
  {
    // cleanup();
    tst_brk(TBROK | TERRNO, "Failed ioctl operation for hwnet_io interface [Base code: %d]",
            HWNET_IO_ERR_IOCTL_FAILED);
  }
  tst_res(TPASS, "The hwnet_io interface flags were successfully validated.");
  cleanup();
}

static void run_test(void)
{
  check_hwnet_io_flags();
}

static struct tst_test test = {
    .setup = setup,
    .cleanup = cleanup,
    .test_all = run_test,
};