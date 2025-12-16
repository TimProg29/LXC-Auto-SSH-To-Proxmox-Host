#!/usr/bin/env bash
set -euo pipefail

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "FEHLT: $1"; exit 1; }
}

ensure_line_in_file() {
  local line="$1" file="$2"
  touch "$file"
  grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

ensure_dir_perms() {
  local dir="$1" mode="$2" owner="$3"
  mkdir -p "$dir"
  chmod "$mode" "$dir"
  chown "$owner" "$dir"
}
