#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# net-preflight-check.sh - función complementaria para la comprobación de red
#
set -e

run_net_preflight() {
    local manifest_file="${USER_FILE:-/mnt/build-output/Repos/hwnet-io.git/build_state.env}"
    local required_vars=("TEST_IFACE" "ROUTER_IP" "TARGET_NET_CLASS" "TARGET_NET_PREFIX")
    local missing_vars=()

    # ==========================================
    # Punto 1: Carga e Inspección del Manifiesto
    # ==========================================
    if [ ! -f "${manifest_file}" ]; then
        echo "❌ Error: No se encontró el manifiesto de build en ${manifest_file}"
        exit 1
    fi

    source "${manifest_file}"

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("${var}")
        fi
    done

    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "❌ Error de manifiesto: Faltan las siguientes variables críticas de red: ${missing_vars[*]}"
        echo "💡 Asegúrese de que el orquestador ha volcado la topología del router-node en ${manifest_file}"
        exit 1
    fi

    # =================================================
    # Punto 2: Descubrimiento L3 Dinámico en el Sandbox
    # =================================================
    if ! ip link show dev "${TEST_IFACE}" > /dev/null 2>&1; then
        echo "❌ Error: La interfaz de red '${TEST_IFACE}' no está disponible en el sistema."
        exit 1
    fi

    SANDBOX_IP=$(ip -4 addr show dev "${TEST_IFACE}" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

    if [ -z "${SANDBOX_IP}" ]; then
        echo "❌ Error: No se detectó ninguna dirección IPv4 asignada a la interfaz '${TEST_IFACE}'."
        exit 1
    fi

    echo "🔍 IP detectada en ${TEST_IFACE}: ${SANDBOX_IP}"

    generate_ltp_manifest
}

# Ejecución del bloque principal
run_net_preflight