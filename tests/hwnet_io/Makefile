# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# Makefile - Pruebas del controlador hwnet-io bajo LTP
#

LTP_SRC ?= /home/builder/Repos/ltp

MODULE_DIR ?= /mnt/build-output/Repos/hwnet-io.git/src/core
CPPFLAGS += -DMODULE_DIR='"$(MODULE_DIR)"'

CFLAGS += -Wall -I../../include -I$(LTP_SRC)/include
LDFLAGS += -L$(LTP_SRC)/lib
LDLIBS += -lltp

# Declaración explícita de los binarios de prueba individuales
TARGETS := hwnet_io01 hwnet_io02

.PHONY: all clean symlink

all: symlink $(TARGETS)

symlink:
	@if [ -f $(MODULE_DIR)/hwnet_io.ko ]; then \
		ln -sf $(MODULE_DIR)/hwnet_io.ko .; \
	fi

# Reglas estrictamente aisladas para cada test
hwnet_io01: hwnet_io01.o
	$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@

hwnet_io02: hwnet_io02.o
	$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGETS) *.ko *.o hwnet_io.ko