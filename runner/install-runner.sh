#!/usr/bin/env bash
set -euo pipefail

TARGET_IP=${1:?Usage: install.sh <target-ip>}
PI_USER=${PI_USER:-pi}
GITHUB_URL=${GITHUB_URL:-https://github.com/moongooseorg}
RUNNER_NAME=pi-runner
IMAGE=homelab-github-runner:latest
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

read -rsp "Org runner token: " RUNNER_TOKEN
echo

docker run --privileged --rm tonistiigi/binfmt --install arm64
docker buildx build -t "${IMAGE}" --load "${SCRIPT_DIR}/image"

docker save "${IMAGE}" | gzip | ssh "${PI_USER}@${TARGET_IP}" 'gunzip | docker load'

ssh "${PI_USER}@${TARGET_IP}" \
  "docker rm -f github-runner 2>/dev/null || true; \
   docker run -d --name github-runner --restart always \
     -e GITHUB_URL='${GITHUB_URL}' \
     -e RUNNER_TOKEN='${RUNNER_TOKEN}' \
     -e RUNNER_NAME='${RUNNER_NAME}' \
     ${IMAGE}"