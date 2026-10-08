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

# Genera el manifiesto para entregables de tipo LTP con soporte de clase de red
generate_ltp_manifest() {
    local manifest_file="$1"
    local runner_type="$2"
    local test_name="$3"
    local test_bin="$4"
    local module_name="$5"
    local module_ko_path="$6"
    local target_class="${7:-C}"            # A, B, C, D, E
    local target_prefix="${8:-192.168.100.0/24}"
    local router_ip="${9:-192.168.100.1}"
    local test_iface="${10:-enp11s0}"

    # Purgado preventivo para asegurar atomicidad
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
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

    echo "✅ Manifiesto LTP [${runner_type}] generado en: ${manifest_file}"
}