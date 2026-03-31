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

transport_url() {
  local transport="$1"
  case "${transport}" in
    webrtc)
      printf 'http://127.0.0.1:%s\n' "${HOST_WEBRTC_PORT}"
      ;;
    novnc)
      printf 'http://127.0.0.1:%s\n' "${HOST_NOVNC_PORT:-6080}"
      ;;
  esac
}

probe_transport() {
  local transport="$1"
  local url
  url="$(transport_url "${transport}")"
  if [[ "${transport}" == "webrtc" ]]; then
    curl -fsS -u "${SELKIES_BASIC_AUTH_USER}:${VNC_PASSWORD}" "${url}" >/dev/null 2>&1
  else
    curl -fsS "${url}" >/dev/null 2>&1
  fi
}

"${ROOT_DIR}/scripts/compose.sh" up --build -d

READY_TRANSPORT=""
for _ in {1..60}; do
  if probe_transport "${ANIMA_DESKTOP_TRANSPORT}"; then
    READY_TRANSPORT="${ANIMA_DESKTOP_TRANSPORT}"
    break
  fi
  if [[ "${ANIMA_DESKTOP_TRANSPORT}" != "novnc" && "${ANIMA_ENABLE_NOVNC}" == "1" ]] && probe_transport novnc; then
    READY_TRANSPORT="novnc"
    break
  fi
  sleep 2
done

if [[ -n "${READY_TRANSPORT}" ]]; then
  URL="$(transport_url "${READY_TRANSPORT}")"
  echo "RobotFlowLabs ANIMA ready"
  echo "[info] profile: ${ANIMA_PROFILE}"
  echo "[info] url: ${URL}"
  echo "[info] transport: ${READY_TRANSPORT}"
  echo "[info] novnc url: http://127.0.0.1:${HOST_NOVNC_PORT:-6080}"
  if [[ "${ANIMA_ENABLE_WEBRTC}" == "1" ]]; then
    echo "[info] webrtc url: http://127.0.0.1:${HOST_WEBRTC_PORT}"
    echo "[info] webrtc auth user: ${SELKIES_BASIC_AUTH_USER}"
  else
    echo "[info] webrtc: disabled by current transport defaults"
  fi
  echo "[info] password: ${VNC_PASSWORD}"
  echo "[info] dds: ${ANIMA_DDS_IMPLEMENTATION}"
  echo "[info] hardware: ${ANIMA_HARDWARE_PROFILE}"
  echo "[info] workspace mount: ${ANIMA_WS_MOUNT_TYPE}:${ANIMA_WS_MOUNT_SOURCE}"
  echo "[info] credentials command: ./anima password"
  if [[ "${READY_TRANSPORT}" != "${ANIMA_DESKTOP_TRANSPORT}" ]]; then
    echo "[warn] requested transport '${ANIMA_DESKTOP_TRANSPORT}' is not ready; using '${READY_TRANSPORT}' instead"
  fi
  if [[ "${ANIMA_OPEN_BROWSER}" == "1" ]]; then
    "${ROOT_DIR}/scripts/open.sh"
  fi
else
  echo "RobotFlowLabs ANIMA started, but neither desktop transport became ready." >&2
  echo "Check logs with: make logs" >&2
  exit 1
fi
