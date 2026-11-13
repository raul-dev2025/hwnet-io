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

#include "tst_test.h"         // Macroestructuras y API principal del framework de pruebas
#include "user/hwnet_error.h" // Esquema de códigos de error personalizado

static void setup(void)
{
  unsigned int ifindex = if_nametoindex("hwnet_io");
  if (ifindex == 0)
  {
    tst_brk(TBROK, "La interfaz de red 'hwnet_io' no se registro");
  }
  tst_res(TPASS, "Interfaz de red 'hwnet_io' encontrada: %u", ifindex);
}

static void check_hwnet_io_flags()
typedef struct hwnet_ctx
{
  int sock;
  struct ifreq ifr;
  int initialized;
} hwnet_ctx_t;

static hwnet_ctx_t test_ctx = {
    .sock = -1,
    .initialized = 0};


  sock = socket(AF_INET, SOCK_DGRAM, 0);
  if (sock < 0)
  {
    tst_brk(TBROK | TERRNO, "Fallo al inicializar el socket de control [Codigo base: %d]",
            HWNET_IO_ERR_SOCKET_INIT);
  }
  memset(&ifr, 0, sizeof(ifr));
  strncpy(ifr.ifr_name, "hwnet_io", IFNAMSIZ - 1);

  if (ioctl(sock, SIOCGIFFLAGS, &ifr) < 0)
  {
    close(sock);
    tst_brk(TBROK | TERRNO, "Fallo en la operacion ioctl par la interfaz hwnet_io [Codigo base: %d]", HWNET_IO_ERR_IOCTL_FAILED);
  }
  close(sock);
  tst_res(TPASS, "Los flags de la interfaz hwnet_io se validaron correctamente.");
}

static void cleanup(void)
{
  tst_res(TINFO, "La tarea de Limpieza sucedera aqui.");
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