#!/usr/bin/env bash
set -euo pipefail

echo "=== INFORMACIÓN DEL SISTEMA Y KERNEL ==="
uname -r
cat /etc/os-release | grep -E "^(NAME|VERSION)="

echo -e "\n=== MÓDULOS DE RED CARGADOS Y KERNEL SYSCTL ==="
lsmod | grep -E "ip_tables|nftables|bonding|8021q" || true
sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding

echo -e "\n=== INTERFACES DE RED DISPONIBLES ==="
ip -br link

echo -e "\n=== ESTADO DE ZONAS Y NAT (FIREWALLD / NFTABLES) ==="
firewall-cmd --get-active-zones || true
nft list ruleset | grep -i masquerade || true