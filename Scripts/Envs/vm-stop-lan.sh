#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# vm-stop.sh - Apaga una VM con espera activa
#
set -e

DEBUG="${DEBUG:-1}"
TARGET_VMS=("acme-sandbox" "router-node")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

iv_virsh() {
    sudo -u virt-admin virsh --connect qemu:///system "$@"
}

if [ -z "${TARGET_VMS[*]}" ]; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Error interno: Asignación de ${TARGET_VMS[*]} vacía en la llamada."
    exit 1
fi

for vm in "${TARGET_VMS[@]}"; do
  "${SCRIPT_DIR}/vm-stop.sh" "${vm}"
done

[ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Entorno LAN [${TARGET_VMS[*]}] liberado con éxito."