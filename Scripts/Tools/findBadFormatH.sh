#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
#
# findDupHeader.sh - Busca coincidencias en la declaracion de cabeceras
#
find . -type f \( -name "*.c" -o -name "*.h" \) -exec sh -c '
  for file; do
    if ! grep -E "^[[:space:]]*#include" "$file" | diff -u - <(grep -E "^[[:space:]]*#include" "$file" | sort) > /dev/null 2>&1; then
      echo "Includes desordenados o mal formateados en: $file"
    fi
  done
' sh {} +