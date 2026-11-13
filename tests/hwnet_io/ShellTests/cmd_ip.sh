#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# 
# hwnet_io01.c - Plantilla base para pruebas de red del driver hwnet_io
# 
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
# ----------------------
# Test for a foo bar.
#
# This test is testing foo by checking that bar is doing xyz.
# ----------------------
# env
# {
# "needs_root": true,
# "needs_tmpdir": true,
# "needs_kconfigs": ["CONFIG_NUMA=y"],
# "tags": [
# ["linux-git", "cf01fb9985e8deb25ccf0ea54d916b8871ae0e62"]
# ]
# }
# 
ip link show hwnet_io

# ip link set dev hwnet_io up