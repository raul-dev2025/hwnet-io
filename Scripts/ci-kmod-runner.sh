#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# ELA - Ejecutor Local Autónomo
# ci-kmod-runner.sh - ELA para desarrollo de módulos.
#
set -e

MANIFEST_FILE="${1:-/mnt/build-output/Repos/hwnet-io.git/build_state.env}"

LOG_DIR="/var/log/Sandbox/hwnet-io"
RUN_LOG="${LOG_DIR}/ltp_latest.log"

# 1. Validar existencia del manifiesto
if [ ! -f "${MANIFEST_FILE}" ]; then
    echo "❌ Error: No se encontró el manifiesto de build en ${MANIFEST_FILE}"
    exit 1
fi

# 2. Cargar variables del manifiesto
source "${MANIFEST_FILE}"

mkdir -p "${LOG_DIR}"
rm -f "${RUN_LOG}"

# 3. Validar existencia de artefactos
if [ ! -f "${MODULE_KO_PATH}" ]; then
    echo "❌ Error: El módulo kernel no existe en ${MODULE_KO_PATH}"
    exit 1
fi

if [ ! -x "${TEST_BINARY_PATH}" ]; then
    echo "❌ Error: El binario LTP no existe o no es ejecutable: ${TEST_BINARY_PATH}"
    exit 1
fi

echo "=============================================="
echo "🧪 Ejecutando Test LTP sobre Módulo Kernel..."
echo "=============================================="

# Funció de limpieza para garantizar rmmod al salir
cleanup() {
    if lsmod | grep -q "^${MODULE_NAME} "; then
        echo "🧹 Descargando módulo kernel: ${MODULE_NAME}..."
        sudo rmmod "${MODULE_NAME}" || true
    fi
}
trap cleanup EXIT


# 4. Desinstalación previa por seguridad
if lsmod | grep -q "^${MODULE_NAME} "; then
    echo "🧹 Desinstalando instancia previa de ${MODULE_NAME}..."
    sudo rmmod "${MODULE_NAME}"
fi

# 5. Carga del módulo
echo "🆙 Cargando módulo kernel: ${MODULE_NAME}..."
sudo insmod "${MODULE_KO_PATH}"

# 6. Ejecución de la prueba LTP
echo "🚀 Ejecutando test LTP: ${TEST_BINARY_NAME}..."

if [[ "${TEST_BINARY_NAME}" == *r ]]; then
    echo "🔑 Test con gestión de módulo detectado (*r): ejecutando con sudo..."
    sudo "${TEST_BINARY_PATH}" 2> "${RUN_LOG}" || true
else
    echo "👤 Test estándar detectado: ejecutando en usuario..."
    "${TEST_BINARY_PATH}" 2> "${RUN_LOG}" || true
fi