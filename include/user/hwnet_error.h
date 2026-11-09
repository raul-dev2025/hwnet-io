#ifndef HWNET_IO_ERROR_H
#define HWNET_IO_ERROR_H

#include <errno.h>
#include <stddef.h>

#define HWNET_IO_SUCCESS 0
#define HWNET_IO_ERR_BASE 6000
#define HWNET_IO_ERR_SOCKET_INIT (HWNET_IO_ERR_BASE + 1)
#define HWNET_IO_ERR_IF_NOT_FOUND (HWNET_IO_ERR_BASE + 2)
#define HWNET_IO_ERR_IOCTL_FAILED (HWNET_IO_ERR_BASE + 3)

/**
 * @brief Traduce códigos de error POSIX y de dominio HWNET_IO a una cadena legible.
 *        Exclusivo para el espacio de usuario y utilidades de prueba.
 *
 * @param errnum Código de error (entero positivo o negativo)
 * @return const char* Cadena estática con la descripción del error
 */
const char *hwnet_io_strerror(int errnum);

#endif /* HWNET_IO_ERROR_H */