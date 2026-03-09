#!/bin/bash
# Run ansible playbook via Docker
# Usage: cmd-deploy.sh [--apply] [--limit host] [--tags tag] [extra args...]
set -euo pipefail

ANSIBLE_IMAGE="alpine/ansible:2.20.0"
ANSIBLE_DIR="$("$(dirname "$0")/read-config.sh")"

# Parse arguments
APPLY=false
EXTRA_ARGS=()

for arg in "$@"; do
  if [ "$arg" = "--apply" ]; then
    APPLY=true
  else
    EXTRA_ARGS+=("$arg")
  fi
done

# Build ansible-playbook command
CMD=(ansible-playbook site.yaml -i inventory/hosts.yaml)

if [ "$APPLY" = false ]; then
  CMD+=(--check)
fi

CMD+=(--diff)
CMD+=("${EXTRA_ARGS[@]}")

DOCKER_FLAGS=()
if [ -t 0 ]; then
  DOCKER_FLAGS=(--tty --interactive)
fi

docker run --rm \
  "${DOCKER_FLAGS[@]}" \
  --volume "${ANSIBLE_DIR}:/ansible" \
  --volume "${HOME}/.ssh:/tmp/.ssh-host:ro" \
  --workdir /ansible \
  "${ANSIBLE_IMAGE}" \
  sh -c "cp -r /tmp/.ssh-host /root/.ssh && chmod 700 /root/.ssh && chmod 600 /root/.ssh/* && ansible-galaxy collection install -r requirements.yml && ${CMD[*]}"
