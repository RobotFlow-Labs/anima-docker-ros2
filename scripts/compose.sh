#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"
# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

compose_args=(-f "${ROOT_DIR}/compose.yaml")
if [[ -n "${ANIMA_COMPOSE_EXTRA_FILES:-}" ]]; then
  IFS=: read -r -a extra_files <<<"${ANIMA_COMPOSE_EXTRA_FILES}"
  for compose_file in "${extra_files[@]}"; do
    if [[ -n "${compose_file}" ]]; then
      compose_args+=(-f "${compose_file}")
    fi
  done
fi

exec docker compose --env-file "${ENV_FILE}" "${compose_args[@]}" "$@"
