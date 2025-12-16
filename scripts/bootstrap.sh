#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

need_cmd pct
need_cmd sudo
need_cmd id
need_cmd useradd
need_cmd visudo

PVE_USER="${PVE_USER:-lxcctl}"
HOME_DIR="/home/$PVE_USER"
SSH_DIR="$HOME_DIR/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SUDOERS_FILE="/etc/sudoers.d/$PVE_USER-pct"

if ! id "$PVE_USER" >/dev/null 2>&1; then
  echo "→ Creating user: $PVE_USER"
  useradd -m -s /bin/bash "$PVE_USER"
fi

echo "→ Setting up SSH directory"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown -R "$PVE_USER:$PVE_USER" "$SSH_DIR"

echo "→ Setting sudo rule for pct (NOPASSWD)"
cat > "$SUDOERS_FILE" <<EOF
$PVE_USER ALL=(root) NOPASSWD: /usr/sbin/pct
EOF
chmod 440 "$SUDOERS_FILE"

echo "✔ Bootstrap complete (User: $PVE_USER)"
