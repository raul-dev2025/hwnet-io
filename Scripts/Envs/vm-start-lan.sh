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

[ "${DEBUG}" -eq 1 ] && echo "==============================================="
[ "${DEBUG}" -eq 1 ] && echo "🚀 Arrancando entorno LAN [router-node, sandbox]..."
[ "${DEBUG}" -eq 1 ] && echo "==============================================="

# 2. Delegación estricta y exclusiva en el script de arranque validado
for vm in "${TARGET_VMS[@]}"; do
    "${SCRIPT_DIR}/vm-start.sh" "${vm}"
done

[ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Entorno LAN [router-node sandbox] arrancado con éxito."