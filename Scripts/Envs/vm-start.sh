#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# vm-start.sh - Arranca una VM verificando exclusión mutua
#
set -e

VM_TARGET="$1"
DEBUG="${DEBUG:-1}" # Cambiar a 0 o eliminar cuando el pipeline esté validado

iv_virsh() {
    sudo -u virt-admin virsh --connect qemu:///system "$@"
}

# Validador técnico de parámetro para el orquestador
if [ -z "${VM_TARGET}" ]; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Error interno: Asignación de VM_TARGET vacía en la llamada."
    exit 1
fi

# VM's Group definition
is_lab_vm() {
  [ "$1" = "buildlab" ]
}

is_lan_vm() {
  [ "$1" = "sandbox" ] || [ "$1" = "router-node" ]
}

# 1. Comprobar si hay alguna VM en ejecución
ACTIVE_VMS=$(iv_virsh list --name | grep -v '^$' || true)

# Si el laboratorio ya está en marcha
if echo "${ACTIVE_VMS}" | grep -q "^${VM_TARGET}$"; then
  [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] La VM [${VM_TARGET}] ya se encuentra activa. Continuando..."
  exit 0
fi

# 2. Validación estricta de exclusión mutua según el grupo de destino
if is_lab_vm "${VM_TARGET}"; then
  for lan_vm in sandbox router-node; do
    if echo "${ACTIVE_VMS}" | grep -q "^${lan_vm}$"; then
      [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Conflicto de exclusión mutua: Imposible arrancar [${VM_TARGET}]. La VM LAN [${lan_vm}] se encuentra en ejecución."
      iv_virsh list --all --title
      exit 1
    fi
  done
elif is_lan_vm "${VM_TARGET}"; then
  if echo "${ACTIVE_VMS}" | grep -q "^buildlab$"; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Conflicto de exclusión mutua: Imposible arrancar [${VM_TARGET}]. El laboratorio [buildlab] se encuentra en ejecución."
    iv_virsh list --all --title
    exit 1
  fi
fi

# 2. Arrancar la máquina virtual solicitada
if ! echo "${ACTIVE_VMS}" | grep -q "^${VM_TARGET}$"; then
  iv_virsh start "${VM_TARGET}"
fi

# 3. Confirmación técnica de estado para el invocador
if ! iv_virsh list --name | grep -q "^${VM_TARGET}$"; then
    [ "${DEBUG}" -eq 1 ] && echo "[DEBUG] Error: La VM [${VM_TARGET}] no alcanzó el estado activo."
    exit 1
fi

[ "${DEBUG}" -eq 1 ] && echo "[DEBUG] VM [${VM_TARGET}] arrancada con éxito."