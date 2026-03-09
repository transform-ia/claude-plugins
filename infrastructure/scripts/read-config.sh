#!/bin/bash
# Read ansible_directory from ~/.claude/infrastructure.local.md
# Outputs the path to stdout. Exits with error if not configured.
set -euo pipefail

CONFIG_FILE="${HOME}/.claude/infrastructure.local.md"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Infrastructure plugin not configured." >&2
    echo "" >&2
    echo "Create ${CONFIG_FILE} with:" >&2
    echo "---" >&2
    echo "ansible_directory: /path/to/your/ansible/repo" >&2
    echo "---" >&2
    exit 1
fi

ANSIBLE_DIR=$(grep -m1 '^ansible_directory:' "$CONFIG_FILE" | sed 's/^ansible_directory:[[:space:]]*//')

if [[ -z "$ANSIBLE_DIR" ]]; then
    echo "Error: ansible_directory not set in ${CONFIG_FILE}" >&2
    exit 1
fi

if [[ ! -d "$ANSIBLE_DIR" ]]; then
    echo "Error: ansible_directory does not exist: ${ANSIBLE_DIR}" >&2
    exit 1
fi

echo "$ANSIBLE_DIR"
