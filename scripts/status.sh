#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

PROFILE="${1:-${ANIMA_PROFILE:-desktop}}"
export ANIMA_PROFILE="${PROFILE}"
# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

SERVICE="desktop"
URL="$(env ANIMA_PROFILE="${PROFILE}" "${ROOT_DIR}/scripts/url.sh")"
CONTAINER_ID="$(env ANIMA_PROFILE="${PROFILE}" "${ROOT_DIR}/scripts/compose.sh" ps -q "${SERVICE}")"

echo "RobotFlowLabs ANIMA status"
if [[ -z "${CONTAINER_ID}" ]]; then
  echo "[info] profile: ${PROFILE}"
  echo "[info] env file: ${ENV_FILE}"
  echo "[info] distro: ${ROS_DISTRO:-jazzy}"
  echo "[info] dds: ${ANIMA_DDS_IMPLEMENTATION}"
  echo "[info] hardware: ${ANIMA_HARDWARE_PROFILE}"
  echo "[info] transport: ${ANIMA_DESKTOP_TRANSPORT}"
  echo "[info] rmw: ${RMW_IMPLEMENTATION}"
  echo "[info] workspace mount: ${ANIMA_WS_MOUNT_TYPE}:${ANIMA_WS_MOUNT_SOURCE}"
  echo "[info] compose overlays: ${ANIMA_COMPOSE_EXTRA_FILES:-none}"
  echo "[info] url: ${URL}"
  echo "[info] credentials: ./anima password"
  echo "[info] container: not running"
  exit 0
fi

container_env() {
  local key="$1"
  docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "${CONTAINER_ID}" \
    | awk -F= -v k="${key}" '$1 == k {sub($1 "=",""); print; exit}'
}

workspace_mount() {
  docker inspect --format '{{range .Mounts}}{{printf "%s|%s|%s\n" .Destination .Type .Source}}{{end}}' "${CONTAINER_ID}" \
    | awk -F'|' '$1 == "/workspaces/anima" {print $2 ":" $3; exit}'
}

host_port() {
  local container_port="$1"
  docker port "${CONTAINER_ID}" "${container_port}" 2>/dev/null | awk -F: 'NR==1 {print $NF}'
}

probe_transport() {
  local transport="$1"
  case "${transport}" in
    webrtc)
      [[ -n "${WEBRTC_PORT:-}" ]] || return 1
      curl -fsS -u "${SELKIES_BASIC_AUTH_USER}:${VNC_PASSWORD}" "http://127.0.0.1:${WEBRTC_PORT}" >/dev/null 2>&1
      ;;
    novnc)
      [[ -n "${NOVNC_PORT:-}" ]] || return 1
      curl -fsS "http://127.0.0.1:${NOVNC_PORT}" >/dev/null 2>&1
      ;;
  esac
}

RUNNING_PROFILE="$(container_env ANIMA_PROFILE_NAME)"
RUNNING_DDS="$(container_env ANIMA_DDS_IMPLEMENTATION)"
RUNNING_HARDWARE="$(container_env ANIMA_HARDWARE_PROFILE)"
RUNNING_TRANSPORT="$(container_env ANIMA_DESKTOP_TRANSPORT)"
RUNNING_WEBRTC_ENABLED="$(container_env ANIMA_ENABLE_WEBRTC)"
RUNNING_RMW="$(container_env RMW_IMPLEMENTATION)"
RUNNING_WORKSPACE="$(workspace_mount)"
NOVNC_PORT="$(host_port 6080/tcp)"
WEBRTC_PORT="$(host_port 8080/tcp)"
FOXGLOVE_PORT="$(host_port 8765/tcp)"

STATE="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_ID}")"
HEALTH="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}n/a{{end}}' "${CONTAINER_ID}")"
IMAGE="$(docker inspect --format '{{.Config.Image}}' "${CONTAINER_ID}")"
STARTED_AT="$(docker inspect --format '{{.State.StartedAt}}' "${CONTAINER_ID}")"
RUNNING_DISTRO="$(awk -F: 'NR==1 {print $2}' <<<"${IMAGE}" | awk -F- 'NR==1 {print $1}')"
ACTIVE_TRANSPORT=""

if [[ "${RUNNING_TRANSPORT:-${ANIMA_DESKTOP_TRANSPORT}}" == "webrtc" ]] && probe_transport webrtc; then
  ACTIVE_TRANSPORT="webrtc"
elif probe_transport novnc; then
  ACTIVE_TRANSPORT="novnc"
elif probe_transport webrtc; then
  ACTIVE_TRANSPORT="webrtc"
fi

if [[ "${ACTIVE_TRANSPORT}" == "webrtc" ]]; then
  URL="http://127.0.0.1:${WEBRTC_PORT}"
elif [[ "${ACTIVE_TRANSPORT}" == "novnc" ]]; then
  URL="http://127.0.0.1:${NOVNC_PORT}"
fi

echo "[info] profile: ${RUNNING_PROFILE:-${PROFILE}}"
echo "[info] env file: ${ENV_FILE}"
echo "[info] distro: ${RUNNING_DISTRO:-${ROS_DISTRO:-jazzy}}"
echo "[info] dds: ${RUNNING_DDS:-${ANIMA_DDS_IMPLEMENTATION}}"
echo "[info] hardware: ${RUNNING_HARDWARE:-${ANIMA_HARDWARE_PROFILE}}"
echo "[info] transport: ${ACTIVE_TRANSPORT:-${RUNNING_TRANSPORT:-${ANIMA_DESKTOP_TRANSPORT}}}"
if [[ -n "${ACTIVE_TRANSPORT}" && "${ACTIVE_TRANSPORT}" != "${RUNNING_TRANSPORT:-${ANIMA_DESKTOP_TRANSPORT}}" ]]; then
  echo "[info] requested transport: ${RUNNING_TRANSPORT:-${ANIMA_DESKTOP_TRANSPORT}}"
fi
echo "[info] rmw: ${RUNNING_RMW:-${RMW_IMPLEMENTATION}}"
echo "[info] workspace mount: ${RUNNING_WORKSPACE:-${ANIMA_WS_MOUNT_TYPE}:${ANIMA_WS_MOUNT_SOURCE}}"
echo "[info] compose overlays: ${ANIMA_COMPOSE_EXTRA_FILES:-none}"
echo "[info] url: ${URL}"
if [[ "${RUNNING_WEBRTC_ENABLED}" == "1" && -n "${WEBRTC_PORT}" ]]; then
  echo "[info] webrtc port: ${WEBRTC_PORT}"
fi
if [[ -n "${NOVNC_PORT}" ]]; then
  echo "[info] noVNC port: ${NOVNC_PORT}"
fi
if [[ -n "${FOXGLOVE_PORT}" ]]; then
  echo "[info] foxglove port: ${FOXGLOVE_PORT}"
fi
echo "[info] credentials: ./anima password"
echo "[info] container: ${STATE}"
echo "[info] health: ${HEALTH}"
echo "[info] image: ${IMAGE}"
echo "[info] started: ${STARTED_AT}"
