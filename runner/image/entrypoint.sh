#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_URL:?GITHUB_URL required, e.g. https://github.com/moongooseorg}"
RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_LABELS=${RUNNER_LABELS:-self-hosted}

cd /home/runner/actions-runner

graceful_stop() {
  if [[ -f .runner && -n "${RUNNER_TOKEN:-}" ]]; then
    ./config.sh remove --token "${RUNNER_TOKEN}" || true
  fi
  exit 0
}
trap graceful_stop SIGINT SIGTERM

if [[ ! -f .runner || "${EPHEMERAL:-0}" == "1" ]]; then
  : "${RUNNER_TOKEN:?RUNNER_TOKEN required for first registration}"
  EXTRA_ARGS=()
  [[ "${EPHEMERAL:-0}" == "1" ]] && EXTRA_ARGS+=(--ephemeral)
  ./config.sh \
    --url "${GITHUB_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --unattended --replace "${EXTRA_ARGS[@]}"
fi

./run.sh &
wait $!
