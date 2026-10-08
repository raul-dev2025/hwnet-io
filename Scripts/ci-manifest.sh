#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# ci-manifest.sh - Biblioteca de generación de manifiesto para build_state.env
#
MANIFEST_FILE="/mnt/build-output/Repos/hwnet-io.git/build_state.env"

# Genera el manifiesto para entregables de tipo KO
generate_ko_manifest() {
    local manifest_file="${USER_FILE:-${MANIFEST_FILE}}"
    local module_name="$1"
    local module_ko_path="$2"

    # Purgado preventivo para asegurar atomicidad
    rm -f "${manifest_file}"

    cat <<EOF > "${manifest_file}"
BUILD_STATUS="SUCCESS"
TARGET_TYPE="KO"
MODULE_NAME="${module_name}"
MODULE_KO_PATH="${module_ko_path}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

    echo "✅ Manifiesto KO generado en: ${manifest_file}"
}

# Genera el manifiesto para entregables de tipo LTP
generate_ltp_manifest() {
    local manifest_file="${USER_FILE:-${MANIFEST_FILE}}"

    # Variables de build y runner
    local runner_type="${RUNNER_TYPE:-GENERIC}"
    local test_name="${TEST_NAME:-}"
    local test_bin="${TEST_BIN:-}"
    local module_name="${MODULE_NAME:-}"
    local module_ko_path="${MODULE_KO_PATH:-}"
    
    # Declaración de Topología de Red para Preflight
    local target_class="${TARGET_NET_CLASS:-C}"
    local target_prefix="${TARGET_NET_PREFIX:-192.168.100}"
    local router_ip="${ROUTER_IP:-192.168.100.1}"
    local test_iface="${TEST_IFACE:-enp11s0}"
    local sandbox_ip="${SANDBOX_IP:-}"

    rm -f "${manifest_file}"

    cat <<EOF > "${manifest_file}"
BUILD_STATUS="SUCCESS"
TARGET_TYPE="LTP"
RUNNER_TYPE="${runner_type}"
TEST_BINARY_NAME="${test_name}"
TEST_BINARY_PATH="${test_bin}"
MODULE_NAME="${module_name}"
MODULE_KO_PATH="${module_ko_path}"
TARGET_NET_CLASS="${target_class}"
TARGET_NET_PREFIX="${target_prefix}"
ROUTER_IP="${router_ip}"
TEST_IFACE="${test_iface}"
SANDBOX_IP="${sandbox_ip}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

    echo "✅ Manifiesto LTP [${runner_type}] generado en: ${manifest_file}"
}