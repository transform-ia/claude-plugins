#!/bin/bash
# Wipe all VictoriaLogs data by stopping the container, clearing the volume, and restarting.
# Usage: wipe-logs.sh
set -euo pipefail

VICTORIALOGS_HOST="robotinfra-tnvt"
CONTAINER="victorialogs"
VOLUME="victorialogs"

echo "Wiping VictoriaLogs data on ${VICTORIALOGS_HOST}..."
ssh "${VICTORIALOGS_HOST}" \
  "docker stop ${CONTAINER} && \
   docker run --rm -v ${VOLUME}:/data alpine sh -c 'rm -rf /data/*' && \
   docker start ${CONTAINER}"

echo "Done. VictoriaLogs is clean and running."
