#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="router-node"
REMOTE_REPO_DIR="/home/builder/Repos/hwnet-io.git"
SCRIPT_PATH="${REMOTE_REPO_DIR}/Scripts/Tools"
SCRIPT_NAME="/dataGrabber.sh"
OUTPUT_LOG="/tmp/out.log"

# Asegurar sincronización previa del repositorio mediante git push
git push "${REMOTE_HOST}" feature/skb-dummy-netdev

# Archivo de log
echo "Log actualizado en ${OUTPUT_LOG}:"

## Ejecución remota y captura de salida
ssh "${REMOTE_HOST}" "bash ${SCRIPT_PATH}/${SCRIPT_NAME}" > "${OUTPUT_LOG}" 2>&1