#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# net-preflight-check.sh - función complementaria para la comprobación de red
#
set -e

TARGET_NET="192.168.100"

# Descubrimiento del dispositivo de red
HWNET_IFACE=$(ip -o link show | awk -F': ' '/hwnet/ {print $2}' | head -n1)
echo "🔍 Dispositivo detectado tras la carga: ${HWNET_IFACE}"

# Prueba de comunicación entre nodos
ROUTER_IP="${ROUTER_IP:-192.168.100.1}"

echo "📡 Verificando conectividad L3 hacia router-node (${ROUTER_IP})..."
if ! ping -c 2 -W 2 "${ROUTER_IP}" > /dev/null 2>&1; then
    echo "❌ Error crítico: Sin respuesta L3 de ${ROUTER_IP}. Abortando ejecución."
    exit 1
fi
echo "✅ Conectividad L3 confirmada con ${ROUTER_IP}."
# Obtención dinámica de la IP
SANDBOX_IP=$(ip -4 addr show dev enp11s0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Pertenencia al segmento de red
if [[ "${SANDBOX_IP}" != ${TARGET_NET}.* ]]; then
    echo "❌ Error: La dirección IP de la interfaz (${SANDBOX_IP}) no pertenece al rango de red de pruebas (${TARGET_NET}.0/24)."
    exit 1
fi

# Descrubimiento de la puerta de enlace
ROUTER_IP=$(ip route show dev enp11s0 | grep default | awk '{print $3}')
# Fallback al GW predeterminado de la subred si no hay ruta por defecto dedicada
ROUTER_IP="${ROUTER_IP:-192.168.100.1}"