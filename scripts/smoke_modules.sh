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
    "${ROOT_DIR}/scripts/compose.sh" down -v >/dev/null 2>&1 || true
}
trap cleanup EXIT

DOCKER_PLATFORM_OVERRIDE="${DOCKER_PLATFORM_OVERRIDE:-$(native_platform)}"
HOST_NOVNC_PORT_OVERRIDE="${HOST_NOVNC_PORT_OVERRIDE:-6180}"
HOST_VNC_PORT_OVERRIDE="${HOST_VNC_PORT_OVERRIDE:-6001}"
HOST_WEBRTC_PORT_OVERRIDE="${HOST_WEBRTC_PORT_OVERRIDE:-8180}"
HOST_FOXGLOVE_PORT_OVERRIDE="${HOST_FOXGLOVE_PORT_OVERRIDE:-8865}"

env \
  ANIMA_ENV_FILE="${ROOT_DIR}/.env.example" \
  DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
  HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
  HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
  HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
  HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
  bash "${ROOT_DIR}/scripts/modules.sh" install starter --force

env \
  ANIMA_ENV_FILE="${ROOT_DIR}/.env.example" \
  DOCKER_PLATFORM="${DOCKER_PLATFORM_OVERRIDE}" \
  HOST_NOVNC_PORT="${HOST_NOVNC_PORT_OVERRIDE}" \
  HOST_VNC_PORT="${HOST_VNC_PORT_OVERRIDE}" \
  HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT_OVERRIDE}" \
  HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT_OVERRIDE}" \
  "${ROOT_DIR}/scripts/compose.sh" run --rm -T desktop bash -lc '
    set -eo pipefail
    cd /workspaces/anima
    colcon build
    source install/setup.bash

    set +e
    timeout 10 ros2 launch robotflowlabs_anima_starter starter_demo.launch.py >/tmp/anima-starter.log 2>&1
    starter_status=$?
    set -e

    if [[ "${starter_status}" != "0" && "${starter_status}" != "124" ]]; then
      cat /tmp/anima-starter.log >&2
      exit "${starter_status}"
    fi

    grep -q "RobotFlowLabs ANIMA demo node started" /tmp/anima-starter.log
    grep -q "Your workspace is ready. Add packages under /workspaces/anima/src." /tmp/anima-starter.log
    grep -q "ANIMA starter talker is publishing on /anima/starter" /tmp/anima-starter.log
    grep -Eq "Publishing ANIMA starter message|heard ANIMA starter message" /tmp/anima-starter.log
  '
