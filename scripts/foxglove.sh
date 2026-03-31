#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

source "${ROOT_DIR}/scripts/cli_helpers.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
  cat <<'EOF'
usage: ./anima foxglove [dev|sim] [--bind PATH] [--dds fastrtps|cyclonedds] [--no-open]
EOF
  exit 0
fi

ANIMA_PARSED_PROFILE="${ANIMA_PROFILE:-dev}"
anima_parse_runtime_args "$@"
anima_apply_runtime_args

export ANIMA_PROFILE="${ANIMA_PARSED_PROFILE}"
export ANIMA_OPEN_BROWSER="${ANIMA_PARSED_OPEN_BROWSER}"

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

if [[ "${ANIMA_PROFILE}" == "desktop" ]]; then
  echo "Foxglove bridge requires the dev or sim profile." >&2
  echo "Use: ./anima foxglove dev" >&2
  exit 1
fi

if [[ -z "$("${ROOT_DIR}/scripts/compose.sh" ps -q desktop)" ]]; then
  "${ROOT_DIR}/scripts/start.sh" "${ANIMA_PROFILE}" --no-open
fi

"${ROOT_DIR}/scripts/compose.sh" exec -T desktop bash -lc '
  set -eo pipefail
  pkill -f foxglove_bridge >/dev/null 2>&1 || true
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
  if [[ -f "${ANIMA_WS}/install/setup.bash" ]]; then
    source "${ANIMA_WS}/install/setup.bash"
  fi
  nohup ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8765 address:=0.0.0.0 \
    >/tmp/foxglove_bridge.log 2>&1 &
'

if ! anima_socket_wait "127.0.0.1" "${HOST_FOXGLOVE_PORT}" 30 1; then
  echo "Foxglove bridge did not become reachable on port ${HOST_FOXGLOVE_PORT}" >&2
  echo "Check logs with: ./anima compose exec desktop tail -n 100 /tmp/foxglove_bridge.log" >&2
  exit 1
fi

FOXGLOVE_URL="https://studio.foxglove.dev/?ds=foxglove-websocket&ds.url=ws://127.0.0.1:${HOST_FOXGLOVE_PORT}"
echo "Foxglove bridge ready"
echo "[info] profile: ${ANIMA_PROFILE}"
echo "[info] websocket: ws://127.0.0.1:${HOST_FOXGLOVE_PORT}"
echo "[info] studio: ${FOXGLOVE_URL}"

if [[ "${ANIMA_OPEN_BROWSER}" == "1" ]]; then
  if command -v open >/dev/null 2>&1; then
    open "${FOXGLOVE_URL}"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "${FOXGLOVE_URL}" >/dev/null 2>&1 &
  else
    echo "${FOXGLOVE_URL}"
  fi
fi
