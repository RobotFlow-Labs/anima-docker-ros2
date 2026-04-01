#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

MODULE_ID="${1:-starter-visualization}"

default_env_file() {
  case "${MODULE_ID}" in
    starter-sim)
      printf '%s/.env.sim\n' "${ROOT_DIR}"
      ;;
    starter-sensors)
      printf '%s/.env.dev\n' "${ROOT_DIR}"
      ;;
    *)
      printf '%s/.env.example\n' "${ROOT_DIR}"
      ;;
  esac
}

native_platform() {
  case "$(uname -m)" in
    x86_64|amd64)
      printf 'linux/amd64\n'
      ;;
    arm64|aarch64)
      printf 'linux/arm64\n'
      ;;
    *)
      printf 'linux/amd64\n'
      ;;
  esac
}

cleanup() {
  env \
    ANIMA_ENV_FILE="${ANIMA_ENV_FILE_OVERRIDE}" \
    DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
    HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
    HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
    HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
    HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
    "${ROOT_DIR}/scripts/compose.sh" down -v >/dev/null 2>&1 || true
}
trap cleanup EXIT

DOCKER_PLATFORM_OVERRIDE="${DOCKER_PLATFORM_OVERRIDE:-$(native_platform)}"
HOST_NOVNC_PORT_OVERRIDE="${HOST_NOVNC_PORT_OVERRIDE:-6180}"
HOST_VNC_PORT_OVERRIDE="${HOST_VNC_PORT_OVERRIDE:-6001}"
HOST_WEBRTC_PORT_OVERRIDE="${HOST_WEBRTC_PORT_OVERRIDE:-8180}"
HOST_FOXGLOVE_PORT_OVERRIDE="${HOST_FOXGLOVE_PORT_OVERRIDE:-8865}"
ANIMA_ENV_FILE_OVERRIDE="${ANIMA_ENV_FILE_OVERRIDE:-$(default_env_file)}"

env \
  ANIMA_ENV_FILE="${ANIMA_ENV_FILE_OVERRIDE}" \
  DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
  HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
  HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
  HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
  HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
  bash "${ROOT_DIR}/scripts/modules.sh" show "${MODULE_ID}"

env \
  ANIMA_ENV_FILE="${ANIMA_ENV_FILE_OVERRIDE}" \
  DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
  HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
  HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
  HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
  HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
  bash "${ROOT_DIR}/scripts/modules.sh" test "${MODULE_ID}"
