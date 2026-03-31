#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

URL="${ANIMA_URL}"

if command -v open >/dev/null 2>&1; then
  open "${URL}"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "${URL}" >/dev/null 2>&1 &
elif command -v python3 >/dev/null 2>&1; then
  python3 -m webbrowser "${URL}" >/dev/null 2>&1 || echo "${URL}"
else
  echo "${URL}"
fi
