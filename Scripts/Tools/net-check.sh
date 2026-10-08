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

    generate_ltp_manifest
}

# Ejecución del bloque principal
run_net_preflight