#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "scripts/cli_helpers.sh must be sourced, not executed" >&2
  exit 1
fi

anima_parse_runtime_args() {
  ANIMA_PARSED_PROFILE="${ANIMA_PARSED_PROFILE:-desktop}"
  ANIMA_PARSED_BIND_PATH="${ANIMA_PARSED_BIND_PATH:-}"
  ANIMA_PARSED_DDS="${ANIMA_PARSED_DDS:-}"
  ANIMA_PARSED_HARDWARE="${ANIMA_PARSED_HARDWARE:-none}"
  ANIMA_PARSED_TRANSPORT="${ANIMA_PARSED_TRANSPORT:-novnc}"
  ANIMA_PARSED_OPEN_BROWSER="${ANIMA_PARSED_OPEN_BROWSER:-1}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      desktop|dev|sim)
        ANIMA_PARSED_PROFILE="$1"
        shift
        ;;
      --bind)
        [[ $# -ge 2 ]] || {
          echo "--bind requires a host path" >&2
          return 1
        }
        ANIMA_PARSED_BIND_PATH="$2"
        shift 2
        ;;
      --dds)
        [[ $# -ge 2 ]] || {
          echo "--dds requires an implementation name" >&2
          return 1
        }
        ANIMA_PARSED_DDS="$2"
        shift 2
        ;;
      --hardware)
        [[ $# -ge 2 ]] || {
          echo "--hardware requires a profile name" >&2
          return 1
        }
        ANIMA_PARSED_HARDWARE="$2"
        shift 2
        ;;
      --transport)
        [[ $# -ge 2 ]] || {
          echo "--transport requires a transport name" >&2
          return 1
        }
        ANIMA_PARSED_TRANSPORT="$2"
        shift 2
        ;;
      --no-open)
        ANIMA_PARSED_OPEN_BROWSER=0
        shift
        ;;
      *)
        echo "unknown argument: $1" >&2
        return 1
        ;;
    esac
  done
}

anima_validate_dds() {
  case "${1:-fastrtps}" in
    cyclonedds|cyclone|fastdds|fastrtps)
      ;;
    *)
      echo "unsupported DDS implementation: ${1}" >&2
      return 1
      ;;
  esac
}

anima_validate_hardware() {
  case "${1:-none}" in
    none|usb|serial|camera|audio|all)
      ;;
    *)
      echo "unsupported hardware profile: ${1}" >&2
      return 1
      ;;
  esac
}

anima_validate_transport() {
  case "${1:-novnc}" in
    webrtc|novnc)
      ;;
    *)
      echo "unsupported desktop transport: ${1}" >&2
      return 1
      ;;
  esac
}

anima_hardware_compose_files() {
  local hardware="${1:-none}"
  local files=()

  case "${hardware}" in
    none)
      ;;
    usb)
      files+=("${ROOT_DIR}/compose.hardware.usb.yaml")
      ;;
    serial)
      files+=("${ROOT_DIR}/compose.hardware.serial.yaml")
      ;;
    camera)
      files+=("${ROOT_DIR}/compose.hardware.camera.yaml")
      ;;
    audio)
      files+=("${ROOT_DIR}/compose.hardware.audio.yaml")
      ;;
    all)
      files+=(
        "${ROOT_DIR}/compose.hardware.usb.yaml"
        "${ROOT_DIR}/compose.hardware.serial.yaml"
        "${ROOT_DIR}/compose.hardware.camera.yaml"
        "${ROOT_DIR}/compose.hardware.audio.yaml"
      )
      ;;
  esac

  local IFS=:
  printf '%s\n' "${files[*]:-}"
}

anima_apply_runtime_args() {
  if [[ -n "${ANIMA_PARSED_BIND_PATH:-}" ]]; then
    mkdir -p "${ANIMA_PARSED_BIND_PATH}"
    export ANIMA_WS_MOUNT_TYPE="bind"
    export ANIMA_WS_MOUNT_SOURCE="$(cd "${ANIMA_PARSED_BIND_PATH}" && pwd)"
  fi

  if [[ -n "${ANIMA_PARSED_DDS:-}" ]]; then
    anima_validate_dds "${ANIMA_PARSED_DDS}"
    case "${ANIMA_PARSED_DDS}" in
      cyclone|cyclonedds)
        export ANIMA_DDS_IMPLEMENTATION="cyclonedds"
        ;;
      fastdds|fastrtps)
        export ANIMA_DDS_IMPLEMENTATION="fastrtps"
        ;;
    esac
  fi

  anima_validate_hardware "${ANIMA_PARSED_HARDWARE:-none}"
  export ANIMA_HARDWARE_PROFILE="${ANIMA_PARSED_HARDWARE:-none}"
  export ANIMA_COMPOSE_EXTRA_FILES="$(anima_hardware_compose_files "${ANIMA_HARDWARE_PROFILE}")"

  anima_validate_transport "${ANIMA_PARSED_TRANSPORT:-novnc}"
  export ANIMA_DESKTOP_TRANSPORT="${ANIMA_PARSED_TRANSPORT:-novnc}"
}

anima_socket_wait() {
  local host="$1"
  local port="$2"
  local retries="${3:-30}"
  local delay="${4:-1}"
  local attempt

  for ((attempt = 0; attempt < retries; attempt++)); do
    if python3 - "$host" "$port" <<'PY'
import socket
import sys

host = sys.argv[1]
port = int(sys.argv[2])
s = socket.socket()
s.settimeout(1.0)
try:
    s.connect((host, port))
except OSError:
    sys.exit(1)
finally:
    s.close()
PY
    then
      return 0
    fi
    sleep "${delay}"
  done

  return 1
}
