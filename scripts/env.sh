#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

HOST_NOVNC_PORT="${HOST_NOVNC_PORT:-6080}"
HOST_VNC_PORT="${HOST_VNC_PORT:-5901}"
HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT:-8080}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/arm64}"

echo "RobotFlowLabs ANIMA environment"
echo "[info] env file: ${ENV_FILE}"
echo "[info] profile: ${ANIMA_PROFILE:-desktop}"
echo "[info] hardware: ${ANIMA_HARDWARE_PROFILE}"
echo "[info] transport: ${ANIMA_DESKTOP_TRANSPORT}"
echo "[info] distro: ${ROS_DISTRO:-jazzy}"
echo "[info] target platform: ${DOCKER_PLATFORM}"
echo "[info] primary url: ${ANIMA_URL}"
echo "[info] noVNC url: http://127.0.0.1:${HOST_NOVNC_PORT}"
if [[ "${ANIMA_ENABLE_WEBRTC}" == "1" ]]; then
  echo "[info] WebRTC url: http://127.0.0.1:${HOST_WEBRTC_PORT}"
  echo "[info] WebRTC auth user: ${SELKIES_BASIC_AUTH_USER}"
else
  echo "[info] WebRTC: disabled by current transport defaults"
fi
echo "[info] VNC port: ${HOST_VNC_PORT}"
echo "[info] Foxglove port: ${HOST_FOXGLOVE_PORT}"
echo "[info] dds: ${ANIMA_DDS_IMPLEMENTATION}"
echo "[info] rmw: ${RMW_IMPLEMENTATION}"
echo "[info] workspace mount: ${ANIMA_WS_MOUNT_TYPE}:${ANIMA_WS_MOUNT_SOURCE}"
echo "[info] compose overlays: ${ANIMA_COMPOSE_EXTRA_FILES:-none}"
echo "[info] password mode: ${ANIMA_VNC_PASSWORD_MODE}"
echo "[info] password command: ./anima password"

if [[ "${ANIMA_VNC_PASSWORD_MODE}" == "generated" ]]; then
  echo "[info] generated password file: ${ANIMA_VNC_PASSWORD_FILE}"
fi
