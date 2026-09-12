# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# Makefile - Pruebas del controlador hwnet-io bajo LTP
#
LTP_SRC ?= /home/builder/Repos/ltp

# Regla para hacer visible el modulo si lo requiere el test
MODULE_DIR ?= /mnt/build-output/Repos/hwnet-io.git/src/core
CPPFLAGS += -DMODULE_DIR='"$(MODULE_DIR)"'

CFLAGS += -Wall -I../../include -I$(LTP_SRC)/include
LDFLAGS += -L$(LTP_SRC)/lib
LDLIBS += -lltp

# Detecta todas las fuentes y  permite invocar objetos individuales
SRCS := $(wildcard hwnet_io*.c)
TARGETS := $(SRCS:.c=)

.PHONY: all clean symlink

# Compila todo con 'make' o 'make all'
all: symlink $(TARGETS)

# regla implicita para compilar individualmente
symlink:
	@if [ -f (MODULE_DIR)/hwnet_io.ko ]; then \
		ln -sf $(MODULE_DIR)/hwnet_io.ko .; \
	fi

%: %.c	
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@



clean:
	rm -f $(TARGETS) *.ko *.o hwnet_io.ko