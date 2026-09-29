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

echo -e "\n=== VERIFICACIÓN DE PAQUETES Y GRUPOS RPM ==="
rpm -qa | grep -E "^(iproute|iptables|nftables|dnsmasq|firewalld|NetworkManager|bind-utils|net-tools)" | sort

echo -e "\n=== GRUPOS DE PAQUETES DE RED INSTALADOS ==="
dnf group list installed