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

running_container_id() {
  "${ROOT_DIR}/scripts/compose.sh" ps -q desktop
}

container_env() {
  local container_id="$1"
  local key="$2"
  docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "${container_id}" \
    | awk -F= -v k="${key}" '$1 == k {sub($1 "=",""); print; exit}'
}

ensure_matching_runtime() {
  local container_id running_profile running_dds running_hardware
  container_id="$(running_container_id)"

  if [[ -z "${container_id}" ]]; then
    "${ROOT_DIR}/scripts/start.sh" "${ANIMA_PROFILE}" --no-open
    return
  fi

  running_profile="$(container_env "${container_id}" ANIMA_PROFILE_NAME)"
  running_dds="$(container_env "${container_id}" ANIMA_DDS_IMPLEMENTATION)"
  running_hardware="$(container_env "${container_id}" ANIMA_HARDWARE_PROFILE)"

  if [[ "${running_profile}" != "${ANIMA_PROFILE}" ]] \
    || [[ "${running_dds}" != "${ANIMA_DDS_IMPLEMENTATION}" ]] \
    || [[ "${running_hardware}" != "${ANIMA_HARDWARE_PROFILE}" ]]; then
    echo "[info] restarting ANIMA to match foxglove runtime"
    echo "[info] requested profile: ${ANIMA_PROFILE}"
    echo "[info] requested dds: ${ANIMA_DDS_IMPLEMENTATION}"
    echo "[info] requested hardware: ${ANIMA_HARDWARE_PROFILE}"
    "${ROOT_DIR}/scripts/compose.sh" down
    "${ROOT_DIR}/scripts/start.sh" "${ANIMA_PROFILE}" --no-open
  fi
}

ensure_matching_runtime

"${ROOT_DIR}/scripts/compose.sh" exec -T desktop bash -lc '
  set -eo pipefail
  existing_pids="$(pgrep -f "foxglove_bridge_launch.xml" || true)"
  if [[ -n "${existing_pids}" ]]; then
    for pid in ${existing_pids}; do
      if [[ "${pid}" != "$$" ]]; then
        kill "${pid}" >/dev/null 2>&1 || true
      fi
    done
  fi
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
