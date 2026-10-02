#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# vm-stop.sh - Apaga una VM con espera activa
#
set -e

DEBUG="${DEBUG:-1}"
TARGET_VMS=("acme-sandbox" "router-node")

iv_virsh() {
    sudo -u virt-admin virsh --connect qemu:///system "$@"
}

if [ -z "${TARGET_VMS[*]}" ]; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Error interno: Asignación de ${TARGET_VMS[*]} vacía en la llamada."
    exit 1
fi

for vm in "${TARGET_VMS[@]}"; do
    if iv_virsh list --name | grep -q "^${vm}$"; then
        [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Apagando VM [${vm}]..."
        iv_virsh shutdown "${vm}"

        # Espera activa hasta que la VM pase a estado shut off
        while iv_virsh list --name | grep -q "^${vm}$"; do
            sleep 1
        done
        [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] VM [${vm}] apagada con éxito."
    else
        [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] La VM [${vm}] ya se encuentra apagada."
    fi
done

[ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Entorno multinodo [${TARGET_VMS[*]}] liberado con éxito."