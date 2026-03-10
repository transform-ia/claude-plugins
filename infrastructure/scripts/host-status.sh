#!/bin/bash
# Check infrastructure status by SSHing into hosts
# Usage: host-status.sh [--host hostname]
set -euo pipefail

ANSIBLE_DIR="$("$(dirname "$0")/read-config.sh")"

# Parse arguments
TARGET_HOST=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      TARGET_HOST="$2"
      shift 2
      ;;
    *)
      TARGET_HOST="$1"
      shift
      ;;
  esac
done

# Get host list from inventory
HOSTS_FILE="${ANSIBLE_DIR}/inventory/hosts.yaml"
if [[ ! -f "$HOSTS_FILE" ]]; then
    echo "Error: hosts.yaml not found at ${HOSTS_FILE}" >&2
    exit 1
fi

# Extract hostnames from inventory (lines under 'hosts:' that have a colon)
get_hosts() {
    grep -A 100 'hosts:' "$HOSTS_FILE" | grep -E '^\s+\w' | sed 's/:.*//' | tr -d ' '
}

# Read host connection details from host_vars
get_host_info() {
    local host="$1"
    local host_vars="${ANSIBLE_DIR}/inventory/host_vars/${host}.yaml"
    if [[ ! -f "$host_vars" ]]; then
        echo "Warning: No host_vars for ${host}" >&2
        return 1
    fi
    local ip=$(grep -m1 '^ansible_host:' "$host_vars" | sed 's/^ansible_host:[[:space:]]*//')
    local port=$(grep -m1 '^ansible_port:' "$host_vars" | sed 's/^ansible_port:[[:space:]]*//')
    port="${port:-22}"
    echo "${ip}:${port}"
}

check_host() {
    local host="$1"
    local info
    info=$(get_host_info "$host") || return 1
    local ip="${info%%:*}"
    local port="${info##*:}"

    echo "=== ${host} (${ip}:${port}) ==="
    echo ""

    # Check containers
    echo "--- Containers ---"
    ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p "$port" "root@${ip}" \
        "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null || \
        echo "  (SSH connection failed or docker not available)"

    echo ""
}

if [[ -n "$TARGET_HOST" ]]; then
    check_host "$TARGET_HOST"
else
    for host in $(get_hosts); do
        check_host "$host"
    done
fi
