#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# vm-status.sh - Helper de consulta para virt-admin
#
set -e

iv_user() {
    sudo -u virt-admin virsh --connect qemu:///system "$@"
}

# Si no se pasan argumentos, muestra la lista completa de VMs con encabezado
if [ $# -eq 0 ]; then
    iv_user list --all --title
else
    iv_user "$@"
fi