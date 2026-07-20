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
  "sudo install -d -m 700 -o runner -g runner /home/runner/.ssh; \
   sudo test -f /home/runner/.ssh/deploy_key || sudo ssh-keygen -t ed25519 -f /home/runner/.ssh/deploy_key -N '' -C github-runner; \
   sudo chown runner:runner /home/runner/.ssh/deploy_key /home/runner/.ssh/deploy_key.pub; \
   sudo cat /home/runner/.ssh/deploy_key.pub" > ~/.ssh/deploy_key.pub

ssh "${PI_USER}@${TARGET_IP}" \
  "docker rm -f github-runner 2>/dev/null || true; \
   docker run -d --name github-runner --restart always \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v /home/runner/.ssh:/home/runner/.ssh:ro \
     -e GITHUB_URL='${GITHUB_URL}' \
     -e RUNNER_TOKEN='${RUNNER_TOKEN}' \
     -e RUNNER_NAME='${RUNNER_NAME}' \
     ${IMAGE}"