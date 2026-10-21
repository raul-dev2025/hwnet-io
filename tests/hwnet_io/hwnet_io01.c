// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * hwnet_io00.c - Template base para pruebas de red del driver hwnet_io
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

#include "tst_test.h" // Macroestructuras y API principal del framework de pruebas

// static void setup(void)
// {
//   return;
// }

// static void cleanup(void)
// {
//   return;
// }

static void run_test(void)
{
  unsigned int ifindex;

  // Probamos de obtener el indice de la interfaz
  ifindex = if_nametoindex("hwnet_io");

  if (ifindex == 0)
  {
    tst_res(TFAIL, "La interfaz de red 'hwnet_io' no se registro");
  }
  else
  {
    tst_res(TPASS, "Interfaz de red 'hwnet_io' encontrada: %u", ifindex);
  }
}
static struct tst_test test = {
    // .setup = setup,
    // .cleanup = cleanup,
    .test_all = run_test,
};