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
  "${ROOT_DIR}/scripts/modules.sh" install starter --force

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
    timeout 5 ros2 run robotflowlabs_anima_demo hello_anima >/tmp/anima-demo.log 2>&1
    demo_status=$?
    timeout 8 ros2 launch robotflowlabs_anima_pubsub pubsub_demo.launch.py >/tmp/anima-pubsub.log 2>&1
    pubsub_status=$?
    set -e

    if [[ "${demo_status}" != "0" && "${demo_status}" != "124" ]]; then
      cat /tmp/anima-demo.log >&2
      exit "${demo_status}"
    fi

    if [[ "${pubsub_status}" != "0" && "${pubsub_status}" != "124" ]]; then
      cat /tmp/anima-pubsub.log >&2
      exit "${pubsub_status}"
    fi

    grep -q "RobotFlowLabs ANIMA demo node started" /tmp/anima-demo.log
    grep -Eq "Publishing ANIMA starter message|heard ANIMA starter message" /tmp/anima-pubsub.log
  '
