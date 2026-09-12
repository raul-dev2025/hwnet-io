#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# ci-signer.sh - Firma de módulos y delegación de manifiesto en buildlab
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/ci-manifest.sh"

BUILD_TYPE="${1:-KO}"

REPO_DIR="/mnt/build-output/Repos/hwnet-io.git"
MANIFEST_FILE="${REPO_DIR}/build_state.env"

PRIV_KEY="/etc/secureboot/buildlab.priv"
DER_CERT="/etc/secureboot/buildlab.der"

if [ "${BUILD_TYPE}" = "KO" ]; then
    # 1. Localizar dinámicamente el archivo .ko en src/
    MODULE_KO=$(find "${REPO_DIR}/src" -type f -name "*.ko" | head -n 1)

    if [ -z "${MODULE_KO}" ] || [ ! -f "${MODULE_KO}" ]; then
        echo "❌ Error: No se encontró ningún archivo .ko compilado en ${REPO_DIR}/src/"
        exit 1
    fi

    MODULE_NAME=$(basename "${MODULE_KO}" .ko)

    # 2. Firmar el módulo de forma estricta
    echo "🔑 Firmando el módulo ${MODULE_KO}..."
    if ! sudo kmod-sign-file sha256 "${PRIV_KEY}" "${DER_CERT}" "${MODULE_KO}"; then
        echo "❌ Error: El módulo ${MODULE_NAME} no ha podido ser firmado. Omitiendo manifiesto..."
        exit 1
    fi

    # 3. Delegar la generación del manifiesto tras la firma exitosa
    generate_ko_manifest "${MANIFEST_FILE}" "${MODULE_NAME}" "${MODULE_KO}"

elif [ "${BUILD_TYPE}" = "LTP" ]; then
    # 1. Localizar prioritariamente el orquestador (*suite*); si no existe, tomar el primer binario
    TEST_BIN=$(find "${REPO_DIR}/tests" -type f -executable ! -name "*.sh" ! -name "Makefile*" -name "*suite*" | head -n 1)

    if [ -z "${TEST_BIN}" ]; then
        TEST_BIN=$(find "${REPO_DIR}/tests" -type f -executable ! -name "*.sh" ! -name "Makefile*" | head -n 1)
    fi

    if [ -z "${TEST_BIN}" ] || [ ! -x "${TEST_BIN}" ]; then
        echo "❌ Error: No se encontró ningún binario de test ejecutable en ${REPO_DIR}/tests/"
        exit 1
    fi

    TEST_NAME=$(basename "${TEST_BIN}")

    # 2. Determinar el perfil de runner e inspección de dependencias
    if echo "${TEST_BIN}" | grep -q "/tests/hwnet_io/"; then
        RUNNER_TYPE="KMOD_TEST"
        MODULE_KO=$(find "${REPO_DIR}/src" -type f -name "*.ko" | head -n 1)

        if [ -z "${MODULE_KO}" ] || [ ! -f "${MODULE_KO}" ]; then
            echo "❌ Error: El test ${TEST_NAME} requiere un módulo .ko, pero no se encontró en ${REPO_DIR}/src/"
            exit 1
        fi
        MODULE_NAME=$(basename "${MODULE_KO}" .ko)
    else
        RUNNER_TYPE="GENERIC"
        MODULE_NAME=""
        MODULE_KO=""
    fi

    # 3. Delegar la generación del manifiesto tras la inspección exitosa
    generate_ltp_manifest "${MANIFEST_FILE}" "${RUNNER_TYPE}" "${TEST_NAME}" "${TEST_BIN}" "${MODULE_NAME}" "${MODULE_KO}"

else
    echo "❌ Error: BUILD_TYPE desconocido [${BUILD_TYPE}]."
    exit 1
fi