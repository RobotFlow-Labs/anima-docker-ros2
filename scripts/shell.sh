#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

source "${ROOT_DIR}/scripts/cli_helpers.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
  cat <<'EOF'
usage: ./anima shell [desktop|dev|sim] [--bind PATH] [--dds fastrtps|cyclonedds] [--hardware none|usb|serial|camera|audio|all] [--transport webrtc|novnc]
EOF
  exit 0
fi

ANIMA_PARSED_PROFILE="${ANIMA_PROFILE:-desktop}"
anima_parse_runtime_args "$@"
anima_apply_runtime_args

export ANIMA_PROFILE="${ANIMA_PARSED_PROFILE}"

if "${ROOT_DIR}/scripts/compose.sh" ps -q desktop >/dev/null 2>&1 && [[ -n "$("${ROOT_DIR}/scripts/compose.sh" ps -q desktop)" ]]; then
  exec "${ROOT_DIR}/scripts/compose.sh" exec desktop bash
fi

exec "${ROOT_DIR}/scripts/compose.sh" run --rm desktop bash
