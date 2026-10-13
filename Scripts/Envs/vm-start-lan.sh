#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# vm-start-lan.sh - Arranca el entorno LAN respetando exclusión mutua mediante vm-start.sh
#
set -e

DEBUG="${DEBUG:-1}"
TARGET_VMS=("router-node" "sandbox")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

iv_virsh() {
    sudo -u virt-admin virsh --connect qemu:///system "$@"
}

# 1. Comprobación de exclusión mutua global previa: El entorno LAN no puede arrancar si buildlab está activo
ACTIVE_VMS=$(iv_virsh list --name | grep -v '^$' || true)
if echo "${ACTIVE_VMS}" | grep -q "^buildlab$"; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Conflicto de exclusión mutua: Imposible arrancar el entorno LAN. El laboratorio [buildlab] se encuentra en ejecución."
    iv_virsh list --all --title
    exit 1
fi

for vm in "${TARGET_VMS[@]}"; do
    ACTIVE_VMS=$(iv_virsh list --name | grep -v '^$' || true)

    if echo "${ACTIVE_VMS}" | grep -q "^${vm}$"; then
        [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] La VM [${vm}] ya se encuentra activa."
    else
        [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Iniciando VM [${vm}]..."
        iv_virsh start "${vm}"
    fi

    # Confirmación de estado activo
    if ! iv_virsh list --name | grep -q "^${vm}$"; then
        [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Error: La VM [${vm}] no alcanzó el estado activo."
        exit 1
    fi
done

[ "${DEBUG}" -eq 1 ] && echo "[DEBUG] VM [${TARGET_VMS}] arrancada con éxito."