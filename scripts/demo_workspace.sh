#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

args=(install demo)
if [[ "${1:-}" == "--force" ]]; then
  args+=(--force)
fi

exec "${ROOT_DIR}/scripts/modules.sh" "${args[@]}"
