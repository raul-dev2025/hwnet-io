#!/usr/bin/env bash
set -euo pipefail

echo "=== APLICANDO CONFIGURACIÓN DE ROUTER EN ROUTER-NODE ==="

# 1. Asegurar zonas en NetworkManager
nmcli connection modify enp1s0 connection.zone external
nmcli connection modify LAN connection.zone internal

# 2. Habilitar Masquerade en Firewalld
firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --reload

# 3. Persistencia de IP Forwarding
if ! grep -q "^net.ipv4.ip_forward = 1" /etc/sysctl.d/99-ipforward.conf 2>/dev/null; then
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ipforward.conf
    sysctl -p /etc/sysctl.d/99-ipforward.conf
fi

echo "=== ESTADO DE LAS ZONAS Y REGLAS DE REENVÍO ==="
firewall-cmd --get-active-zones
nft list ruleset | grep -i masquerade