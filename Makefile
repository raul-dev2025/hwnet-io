# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# Makefile - Build instructions for hwnet-io
#
# Forzar la ruta del BTF base de la imagen en ejecución para Kbuild
export KBUILD_BPF_BOOT_BTF ?= /sys/kernel/btf/vmlinux

.PHONY: module test clean help

CURDIR  := $(shell pwd)
KDIR ?= /lib/modules/$(shell uname -r)/build

# Subdirectorio de módulo activo (configurado en el propio Makefile)
CORE_DIR ?= src/core
# DRIVER_DIR ?= src/driver

# Compilación explícita del módulo
module:
	$(MAKE) -C $(KDIR) M=$(PWD)/$(CORE_DIR) modules
# $(MAKE) -C $(KDIR) M=$(PWD)/$(DRIVER_DIR) modules

# Compilación explícita de pruebas delegando en la jerarquía tests/
test:
	$(MAKE) -C tests test

# Limpieza global sin fallar si un directorio no existe o está limpio
clean:
	$(MAKE) -C $(KDIR) M=$(PWD)/$(CORE_DIR) clean 2>/dev/null || true
	$(MAKE) -C $(KDIR) M=$(PWD)/$(DRIVER_DIR) clean 2>/dev/null || true
	$(MAKE) -C tests clean 2>/dev/null || true


help: 
	@echo "Objetivos disponibles:"
	@echo "  make module - Compila los módulos del kernel bajo src/"
	@echo "  make test	 - Compila la suite de pruebas bajo tests/"
	@echo "  make clean	 - Limpia artefactos de compilación"