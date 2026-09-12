#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# ci-manifest.sh - Biblioteca de generación de manifiesto para build_state.env
#

# Genera el manifiesto para entregables de tipo KO
generate_ko_manifest() {
    local manifest_file="$1"
    local module_name="$2"
    local module_ko_path="$3"

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
    local manifest_file="$1"
    local runner_type="$2"
    local test_name="$3"
    local test_bin="$4"
    local module_name="$5"
    local module_ko_path="$6"

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
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

    echo "✅ Manifiesto LTP [${runner_type}] generado en: ${manifest_file}"
}