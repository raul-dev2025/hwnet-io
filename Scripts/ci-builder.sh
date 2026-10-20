#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# ci-builder.sh - Orquestador de compilación desde WS hacia buildlab
#
set -e

REMOTE_HOST="builder@buildlab"
REMOTE_ROOT="/mnt/build-output/Repos/hwnet-io.git"

# Opciones: "KO" | "LTP"
BUILD_TYPE="LTP"
BINARY_NAME="hwnet_io"

# Rutas de logs (WS y Lab)
LOCAL_LOG_DIR="/mnt/datos_raul/Logs/Buildlab/hwnet-io"
REMOTE_LOG_DIR="/var/log/BuilderLogs/hwnet-io"

# Definición dinámica según el target activo
if [ "${BUILD_TYPE}" = "KO" ]; then
    LOG_NAME="build_ko_latest.log"
elif [ "${BUILD_TYPE}" = "LTP" ]; then
    LOG_NAME="build_ltp_latest.log"
else
    LOG_NAME="build_latest.log"
fi

LOCAL_BUILD_LOG="${LOCAL_LOG_DIR}/${LOG_NAME}"
REMOTE_BUILD_LOG="${REMOTE_LOG_DIR}/${LOG_NAME}"


# =============================
# 0. GESTIÓN DE INFRAESTRUCTURA
# =============================

echo "=================================================="
echo "🚀 Arrancando entorno de compilación (buildlab)..."
echo "=================================================="

Scripts/Envs/vm-start.sh buildlab
Scripts/Envs/vm-poll.sh buildlab 22 30

# ==========
# EJECUCIÓN
# ==========

# 1. Purgado defensivo de logs anteriores
mkdir -p "${LOCAL_LOG_DIR}"
rm -f "${LOCAL_BUILD_LOG}"
ssh "${REMOTE_HOST}" "mkdir -p ${REMOTE_LOG_DIR} && rm -f ${REMOTE_BUILD_LOG}"

# 2. Construcción del comando make según BUILD_TYPE
if [ "${BUILD_TYPE}" = "KO" ]; then
    echo "🧹 Compilando Módulo Kernel (.ko): ${BINARY_NAME}..."
    MAKE_CMD="make -C ${REMOTE_ROOT} clean && make -C ${REMOTE_ROOT} module"    
elif [ "${BUILD_TYPE}" = "LTP" ]; then
    echo "🧹 Compilando Test LTP: ${BINARY_NAME}..."
    MAKE_CMD="make -C ${REMOTE_ROOT}/tests clean && make -C ${REMOTE_ROOT} test"
else
    echo "❌ Error: BUILD_TYPE no reconocido [${BUILD_TYPE}]. Use 'KO' o 'LTP'."
    exit 1
fi

# 3. Invocación de make en buildlab
if ssh "${REMOTE_HOST}" "{ ${MAKE_CMD}; } > ${REMOTE_BUILD_LOG} 2>&1; cat ${REMOTE_BUILD_LOG}" > "${LOCAL_BUILD_LOG}" 2>&1; then
    echo "✅ BUILD SUCCESSFUL [${BUILD_TYPE}] --> ${LOCAL_BUILD_LOG}"
else
    echo "❌ BUILD FAILED [${BUILD_TYPE}] -> Ver: ${LOCAL_BUILD_LOG}"
    echo "⚠️ Mantenida la VM buildlab encendida para inspección."
    exit 1
fi

echo "====================================================="
echo "🔏 Procesando entrega e inspección [${BUILD_TYPE}]..."
echo "====================================================="

# 4. Transición a la fase de post-procesado (firma e inspección)
if ssh "${REMOTE_HOST}" "${REMOTE_ROOT}/Scripts/ci-signer.sh ${BUILD_TYPE}"; then
    echo "✅ ENTREGA PROCESADA Y MANIFIESTO REGISTRADO CORRECTAMENTE"
else
    echo "❌ ERROR EN PROCESADO DE ENTREGA / FIRMA"
    exit 1
fi

# =========================
# 5. LIBERACIÓN DE RECURSO
# =========================

echo "🛑 Liberando infraestructura de compilación..."
echo "build(ci): select target type TARGET for pipeline run"

STOP_OUTPUT=$(Scripts/Envs/vm-stop.sh buildlab)
echo "${STOP_OUTPUT}"

if echo "${STOP_OUTPUT}" | grep -q "apagada con éxito"; then
    echo "✅ Infraestructura buildlab liberada correctamente."
else
    echo "⚠️ Advertencia: Revisa el estado de la VM mediante ./vm-status.sh"
fi