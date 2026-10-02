#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# vm-start.sh - Arranca una VM verificando exclusión mutua
#
set -e

DEBUG="${DEBUG:-1}" # Cambiar a 0 o eliminar cuando el pipeline esté validado
TARGET_VMS=("router-node" "acme-sandbox")

iv_virsh() {
    sudo -u virt-admin virsh --connect qemu:///system "$@"
}

# Validador técnico de parámetro para el orquestador
if [ -z "${TARGET_VMS}" ]; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Error interno: Asignación de VM_TARGET vacía en la llamada."
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