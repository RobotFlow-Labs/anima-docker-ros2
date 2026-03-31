#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-${SRC:-}}"
if [[ -z "${SRC}" ]]; then
  echo "usage: SRC=/path/to/workspace.tar.gz ./scripts/import_workspace.sh" >&2
  echo "   or: ./scripts/import_workspace.sh /path/to/workspace.tar.gz" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ ! -e "${SRC}" ]]; then
  echo "source not found: ${SRC}" >&2
  exit 1
fi

if [[ -d "${SRC}" ]]; then
  tar -C "${SRC}" -cf - . | "${ROOT_DIR}/scripts/compose.sh" run --rm -T desktop bash -lc 'mkdir -p /workspaces/anima && tar -xf - -C /workspaces/anima'
else
  "${ROOT_DIR}/scripts/compose.sh" run --rm -T -v "${SRC}:/tmp/workspace.tar.gz:ro" desktop bash -lc 'mkdir -p /workspaces/anima && tar -xf /tmp/workspace.tar.gz -C /workspaces/anima'
fi

echo "workspace imported into the ANIMA volume"
