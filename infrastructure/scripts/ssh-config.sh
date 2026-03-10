#!/bin/bash
# Sync Ansible inventory hosts into ~/.ssh/config
# Usage: ssh-config.sh [--dry-run]
set -euo pipefail

ANSIBLE_DIR="$("$(dirname "$0")/read-config.sh")"

# Parse arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

SSH_CONFIG="${HOME}/.ssh/config"
BLOCK_START="# BEGIN ansible-inventory-hosts"
BLOCK_END="# END ansible-inventory-hosts"

# Get host list from inventory
HOSTS_FILE="${ANSIBLE_DIR}/inventory/hosts.yaml"
if [[ ! -f "$HOSTS_FILE" ]]; then
    echo "Error: hosts.yaml not found at ${HOSTS_FILE}" >&2
    exit 1
fi

# Extract hostnames
get_hosts() {
    grep -A 100 'hosts:' "$HOSTS_FILE" | grep -E '^    \w' | sed 's/:.*//' | tr -d ' '
}

# Build the managed block
build_block() {
    echo "$BLOCK_START"
    for host in $(get_hosts); do
        local host_vars="${ANSIBLE_DIR}/inventory/host_vars/${host}.yaml"
        if [[ ! -f "$host_vars" ]]; then
            echo "Warning: No host_vars for ${host}, skipping" >&2
            continue
        fi

        local ip=$(grep -m1 '^ansible_host:' "$host_vars" | sed 's/^ansible_host:[[:space:]]*//')
        local port=$(grep -m1 '^ansible_port:' "$host_vars" | sed 's/^ansible_port:[[:space:]]*//')
        port="${port:-22}"

        if [[ -z "$ip" ]]; then
            echo "Warning: No ansible_host for ${host}, skipping" >&2
            continue
        fi

        echo ""
        echo "Host ${host}"
        echo "    HostName ${ip}"
        echo "    Port ${port}"
        echo "    User root"
    done
    echo ""
    echo "$BLOCK_END"
}

NEW_BLOCK="$(build_block)"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "--- Preview of managed SSH config block ---"
    echo ""
    echo "$NEW_BLOCK"
    echo ""
    echo "(dry-run: no changes written)"
    exit 0
fi

# Ensure ~/.ssh/config exists
mkdir -p "$(dirname "$SSH_CONFIG")"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

# Remove existing managed block if present, then append new one
if grep -qF "$BLOCK_START" "$SSH_CONFIG"; then
    # Remove old block (sed between markers inclusive)
    TEMP=$(mktemp)
    sed "/$BLOCK_START/,/$BLOCK_END/d" "$SSH_CONFIG" > "$TEMP"
    mv "$TEMP" "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
fi

# Append new block
echo "" >> "$SSH_CONFIG"
echo "$NEW_BLOCK" >> "$SSH_CONFIG"

# Count hosts added
HOST_COUNT=$(echo "$NEW_BLOCK" | grep -c '^Host ' || true)
echo "Synced ${HOST_COUNT} hosts from Ansible inventory into ${SSH_CONFIG}"
echo ""
echo "$NEW_BLOCK"
