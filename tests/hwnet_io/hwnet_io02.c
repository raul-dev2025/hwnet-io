// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * hwnet_io02.c - Suite de pruebas de validación para hwnet_io
 *
 * Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
 */

#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include <sys/socket.h>
#include <net/if.h>

#include "tst_test.h"
#include "user/hwnet_error.h"

static void setup(void)
{
  unsigned int ifindex = if_nametoindex("hwnet_io");
  if (ifindex == 0)
  {
    tst_brk(TBROK, "La interfaz de red 'hwnet_io' no se encuentra registrada");
  }
  tst_res(TPASS, "Interfaz de red 'hwnet_io' detectada con índice: %u", ifindex);
}

static void test_hwnet_io_interface(void)
{
  int sock;
  struct ifreq ifr;

  sock = socket(AF_INET, SOCK_DGRAM, 0);
  if (sock < 0)
  {
    tst_brk(TBROK | TERRNO, "Fallo al inicializar el socket de control [Código base: %d]",
            HWNET_IO_ERR_SOCKET_INIT);
  }

  memset(&ifr, 0, sizeof(ifr));
  strncpy(ifr.ifr_name, "hwnet_io", IFNAMSIZ - 1);

  if (ioctl(sock, SIOCGIFFLAGS, &ifr) < 0)
  {
    close(sock);
    tst_brk(TBROK | TERRNO, "Fallo en la operación ioctl para la interfaz hwnet_io [Código base: %d]",
            HWNET_IO_ERR_IOCTL_FAILED);
  }

  close(sock);
  tst_res(TPASS, "Los flags de la interfaz hwnet_io se validaron correctamente.");
}

static void cleanup(void)
{
  tst_res(TINFO, "Limpieza de recursos de la prueba completada.");
}

static void run_tests(void)
{
  test_hwnet_io_interface();
}

static struct tst_test test = {
    .setup = setup,
    .cleanup = cleanup,
    .test_all = run_tests,
};