#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <tu-email@dominio.com>
#
# vm-poll.sh - Espera a que la pila de red/SSH de una VM esté disponible
#
set -e

HOST="${1:-buildlab}"
PORT="${2:-22}"
TIMEOUT="${3:-30}"

echo "[INFO] Esperando disponibilidad SSH en ${HOST}:${PORT}..."

ELAPSED=0
until ssh -p "${PORT}" \
  -o BatchMode=yes \
  -o ConnectTimeout=2 \
  "${HOST}" "exit" 2>/dev/null; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    if [ "${ELAPSED}" -ge "${TIMEOUT}" ]; then
        echo "❌ Timeout: El servicio SSH en ${HOST}:${PORT} no respondió tras ${TIMEOUT}s."
        exit 1
    fi
done

echo "✅ Entorno ${HOST} activo y respondiendo por SSH."