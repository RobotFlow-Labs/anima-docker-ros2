#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/cli_helpers.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
  cat <<'EOF'
usage: ./anima up [desktop|dev|sim] [--bind PATH] [--dds fastrtps|cyclonedds] [--hardware none|usb|serial|camera|audio|all] [--transport webrtc|novnc] [--no-open]
EOF
  exit 0
fi

ANIMA_PARSED_PROFILE="${ANIMA_PROFILE:-desktop}"
anima_parse_runtime_args "$@"
anima_apply_runtime_args

export ANIMA_PROFILE="${ANIMA_PARSED_PROFILE}"
export ANIMA_OPEN_BROWSER="${ANIMA_PARSED_OPEN_BROWSER}"

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

if [[ "${ANIMA_HARDWARE_PROFILE}" != "none" ]]; then
  echo "[warn] hardware profile '${ANIMA_HARDWARE_PROFILE}' is opt-in and best supported on Linux hosts"
  if command -v sw_vers >/dev/null 2>&1; then
    echo "[warn] macOS Docker Desktop may not expose the requested devices directly"
  fi
fi

URL="${ANIMA_URL}"

"${ROOT_DIR}/scripts/compose.sh" up --build -d

for _ in {1..60}; do
  if curl -fsS "${URL}" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

if curl -fsS "${URL}" >/dev/null 2>&1; then
  echo "RobotFlowLabs ANIMA ready"
  echo "[info] profile: ${ANIMA_PROFILE}"
  echo "[info] url: ${URL}"
  echo "[info] transport: ${ANIMA_DESKTOP_TRANSPORT}"
  echo "[info] webrtc url: http://127.0.0.1:${HOST_WEBRTC_PORT}"
  echo "[info] novnc url: http://127.0.0.1:${HOST_NOVNC_PORT:-6080}"
  echo "[info] password: ${VNC_PASSWORD}"
  echo "[info] dds: ${ANIMA_DDS_IMPLEMENTATION}"
  echo "[info] hardware: ${ANIMA_HARDWARE_PROFILE}"
  echo "[info] workspace mount: ${ANIMA_WS_MOUNT_TYPE}:${ANIMA_WS_MOUNT_SOURCE}"
  echo "[info] credentials command: ./anima password"
  if [[ "${ANIMA_OPEN_BROWSER}" == "1" ]]; then
    "${ROOT_DIR}/scripts/open.sh"
  fi
else
  echo "RobotFlowLabs ANIMA started, but the web UI is not ready yet: ${URL}" >&2
  echo "Check logs with: make logs" >&2
  exit 1
fi
