#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

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
    ANIMA_ENV_FILE="${ROOT_DIR}/.env.example" \
    DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
    HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
    HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
    HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
    HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
    ./anima compose down -v >/dev/null 2>&1 || true
}
trap cleanup EXIT

DOCKER_PLATFORM_OVERRIDE="${DOCKER_PLATFORM_OVERRIDE:-$(native_platform)}"
HOST_NOVNC_PORT_OVERRIDE="${HOST_NOVNC_PORT_OVERRIDE:-6280}"
HOST_VNC_PORT_OVERRIDE="${HOST_VNC_PORT_OVERRIDE:-6101}"
HOST_WEBRTC_PORT_OVERRIDE="${HOST_WEBRTC_PORT_OVERRIDE:-8280}"
HOST_FOXGLOVE_PORT_OVERRIDE="${HOST_FOXGLOVE_PORT_OVERRIDE:-8965}"

env \
  ANIMA_ENV_FILE="${ROOT_DIR}/.env.example" \
  DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
  HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
  HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
  HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
  HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
  ./anima up --no-open

curl -fsS "http://127.0.0.1:${HOST_NOVNC_PORT_OVERRIDE}/" >/dev/null

status_output="$(
env \
  ANIMA_ENV_FILE="${ROOT_DIR}/.env.example" \
  DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
  HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
  HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
  HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
  HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
  ./anima status
)"

grep -q '\[info\] transport: novnc' <<< "${status_output}"
