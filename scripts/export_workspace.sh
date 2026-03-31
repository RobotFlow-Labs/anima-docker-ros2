#!/usr/bin/env bash
set -euo pipefail

DEST="${1:-${DEST:-}}"
if [[ -z "${DEST}" ]]; then
  echo "usage: DEST=/path/to/workspace.tar.gz ./scripts/export_workspace.sh" >&2
  echo "   or: ./scripts/export_workspace.sh /path/to/workspace.tar.gz" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

mkdir -p "$(dirname "${DEST}")"
"${ROOT_DIR}/scripts/compose.sh" run --rm -T desktop bash -lc 'tar -C /workspaces/anima -czf - .' > "${DEST}"

echo "workspace exported to ${DEST}"
