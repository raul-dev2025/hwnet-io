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

    generate_ltp_manifest
}

# Ejecución del bloque principal
run_net_preflight