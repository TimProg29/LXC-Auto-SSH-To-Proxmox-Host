#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

need_cmd pct
need_cmd ssh-keygen
need_cmd sed
need_cmd grep

LXC_ID="${1:-}"
KEY_NAME="${2:-}"
PVE_USER="${PVE_USER:-lxcctl}"

if [[ -z "$LXC_ID" || -z "$KEY_NAME" ]]; then
  echo "Usage: sudo $0 <LXC_ID> <KEY_NAME>"
  echo "Example: sudo $0 105 app1"
  exit 1
fi

SSH_DIR="/home/$PVE_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

echo "→ Checking if container $LXC_ID is reachable"
pct status "$LXC_ID" >/dev/null

echo "→ Ensuring node is prepared (bootstrap)"
"$SCRIPT_DIR/bootstrap.sh" >/dev/null

KEY_PATH="/root/.ssh/${KEY_NAME}_ed25519"
KEY_PUB="${KEY_PATH}.pub"
COMMENT="${KEY_NAME}@lxc-${LXC_ID}"

echo "→ Generating key in LXC $LXC_ID: $KEY_PATH"
pct exec "$LXC_ID" -- bash -lc "
set -euo pipefail
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if [[ ! -f '$KEY_PATH' ]]; then
  ssh-keygen -t ed25519 -a 64 -f '$KEY_PATH' -N '' -C '$COMMENT' >/dev/null
fi
chmod 600 '$KEY_PATH'
chmod 644 '$KEY_PUB'
"

PUBKEY="$(pct exec "$LXC_ID" -- bash -lc "cat '$KEY_PUB'")"

# Optional: restrict per key (recommended)
RESTRICTED_LINE="no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty $PUBKEY"

echo "→ Adding key to $AUTHORIZED_KEYS (User: $PVE_USER)"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown -R "$PVE_USER:$PVE_USER" "$SSH_DIR"

# Avoid duplicates: if the same public key already exists, do nothing
if grep -Fq "$PUBKEY" "$AUTHORIZED_KEYS"; then
  echo "ℹ Key already exists in authorized_keys (no duplicate entry)"
else
  echo "$RESTRICTED_LINE" >> "$AUTHORIZED_KEYS"
fi

echo
echo "✔ Done"
echo "  LXC_ID:        $LXC_ID"
echo "  KEY_NAME:      $KEY_NAME"
echo "  LXC key path:  $KEY_PATH"
echo "  Node user:     $PVE_USER"
echo "  authorized:    $AUTHORIZED_KEYS"
