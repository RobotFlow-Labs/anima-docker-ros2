#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

HOST_NOVNC_PORT="${HOST_NOVNC_PORT:-6080}"
HOST_VNC_PORT="${HOST_VNC_PORT:-5901}"
HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT:-8080}"
HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT:-8765}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/arm64}"

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '[ok] %s\n' "$label"
  else
    printf '[fail] %s\n' "$label"
    return 1
  fi
}

echo "RobotFlowLabs ANIMA doctor"
echo "[info] env file: ${ENV_FILE}"
echo "[info] dds: ${ANIMA_DDS_IMPLEMENTATION}"
echo "[info] hardware: ${ANIMA_HARDWARE_PROFILE}"
echo "[info] transport: ${ANIMA_DESKTOP_TRANSPORT}"
echo "[info] workspace mount: ${ANIMA_WS_MOUNT_TYPE}:${ANIMA_WS_MOUNT_SOURCE}"
echo "[info] compose overlays: ${ANIMA_COMPOSE_EXTRA_FILES:-none}"

check "env file" test -f "${ENV_FILE}"
check "docker CLI" command -v docker
check "docker compose" docker compose version
check "docker daemon" docker info

if command -v sw_vers >/dev/null 2>&1; then
  echo "[info] macOS: $(sw_vers -productVersion)"
  if [[ "${ANIMA_HARDWARE_PROFILE}" != "none" ]]; then
    echo "[warn] hardware passthrough profiles are best-effort on Docker Desktop for Mac"
  fi
fi

echo "[info] host arch: $(uname -m)"
echo "[info] target platform: ${DOCKER_PLATFORM}"

if command -v sysctl >/dev/null 2>&1; then
  if sysctl -n hw.memsize >/dev/null 2>&1; then
    MEM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    CPU_COUNT="$(sysctl -n hw.ncpu 2>/dev/null || echo "?")"
    echo "[info] host memory: ${MEM_GB} GB"
    echo "[info] host cpus: ${CPU_COUNT}"
    if (( MEM_GB < 8 )); then
      echo "[warn] less than 8 GB host memory detected; Docker Desktop ROS desktop sessions may feel constrained"
    fi
  fi
fi

DISK_FREE_GB="$(df -Pk . | awk 'NR==2 {print int($4/1024/1024)}')"
echo "[info] free disk near repo: ${DISK_FREE_GB} GB"
if (( DISK_FREE_GB < 20 )); then
  echo "[warn] less than 20 GB free disk detected; large image builds may fail"
fi

if command -v lsof >/dev/null 2>&1; then
  if lsof -iTCP:"${HOST_NOVNC_PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "[warn] port ${HOST_NOVNC_PORT} is already in use"
  else
    echo "[ok] port ${HOST_NOVNC_PORT} is free"
  fi

  if lsof -iTCP:"${HOST_VNC_PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "[warn] port ${HOST_VNC_PORT} is already in use"
  else
    echo "[ok] port ${HOST_VNC_PORT} is free"
  fi

  if lsof -iTCP:"${HOST_WEBRTC_PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "[warn] port ${HOST_WEBRTC_PORT} is already in use"
  else
    echo "[ok] port ${HOST_WEBRTC_PORT} is free"
  fi

  if lsof -iTCP:"${HOST_FOXGLOVE_PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "[warn] port ${HOST_FOXGLOVE_PORT} is already in use"
  else
    echo "[ok] port ${HOST_FOXGLOVE_PORT} is free"
  fi
fi

case "${ANIMA_HARDWARE_PROFILE}" in
  usb)
    if [[ ! -d /dev/bus/usb ]]; then
      echo "[warn] /dev/bus/usb is not present on this host"
    else
      echo "[ok] usb device root detected"
    fi
    ;;
  serial)
    if [[ ! -e /dev/ttyUSB0 && ! -e /dev/ttyACM0 ]]; then
      echo "[warn] no common serial device node detected (/dev/ttyUSB0 or /dev/ttyACM0)"
    else
      echo "[ok] serial device node detected"
    fi
    ;;
  camera)
    if [[ ! -e /dev/video0 ]]; then
      echo "[warn] /dev/video0 is not present on this host"
    else
      echo "[ok] camera device detected"
    fi
    ;;
  audio)
    if [[ ! -d /dev/snd ]]; then
      echo "[warn] /dev/snd is not present on this host"
    else
      echo "[ok] audio device root detected"
    fi
    ;;
  all)
    echo "[info] hardware profile includes USB, serial, camera, and audio overlays"
    ;;
esac

echo "[info] run: make up"
echo "[info] run dev profile: make up-dev"
echo "[info] run sim profile: make up-sim"
echo "[info] hardware runs: make up-usb | make up-serial | make up-camera | make up-audio"
echo "[info] open: make open"
echo "[info] shell: make shell"
echo "[info] experimental webrtc: ./anima up --transport webrtc"
echo "[info] foxglove: ./anima foxglove dev"
echo "[info] password: ./anima password"
