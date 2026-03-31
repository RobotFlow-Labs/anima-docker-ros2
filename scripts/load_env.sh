#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "scripts/load_env.sh must be sourced, not executed" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/cli_helpers.sh"
ENV_FILE="${ANIMA_ENV_FILE:-$("${ROOT_DIR}/scripts/resolve_env.sh")}"
STATE_DIR="${ROOT_DIR}/.anima"
PASSWORD_FILE="${STATE_DIR}/vnc_password"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "env file not found: ${ENV_FILE}" >&2
  return 1 2>/dev/null || exit 1
fi

generate_password() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c 20
    return
  fi

  python3 - <<'PY'
import secrets
import string

alphabet = string.ascii_letters + string.digits
print("".join(secrets.choice(alphabet) for _ in range(20)))
PY
}

preserve_runtime_env() {
  local var
  for var in "$@"; do
    if [[ -n "${!var+x}" ]]; then
      export "ANIMA_PRESERVE_${var}=1"
      export "ANIMA_PRESERVE_VALUE_${var}=${!var}"
    fi
  done
}

restore_runtime_env() {
  local var preserve_flag preserve_value_var
  for var in "$@"; do
    preserve_flag="ANIMA_PRESERVE_${var}"
    preserve_value_var="ANIMA_PRESERVE_VALUE_${var}"
    if [[ -n "${!preserve_flag:-}" ]]; then
      export "${var}=${!preserve_value_var}"
      unset "${preserve_flag}" "${preserve_value_var}"
    fi
  done
}

runtime_override_vars=(
  ANIMA_PROFILE
  ANIMA_HARDWARE_PROFILE
  ANIMA_DESKTOP_TRANSPORT
  ANIMA_DDS_IMPLEMENTATION
  ANIMA_ENABLE_NOVNC
  ANIMA_ENABLE_WEBRTC
  ANIMA_WS_MOUNT_TYPE
  ANIMA_WS_MOUNT_SOURCE
  ANIMA_COMPOSE_EXTRA_FILES
  VNC_PASSWORD
)

preserve_runtime_env "${runtime_override_vars[@]}"

# shellcheck disable=SC1090
set -a && source "${ENV_FILE}" && set +a

restore_runtime_env "${runtime_override_vars[@]}"

mkdir -p "${STATE_DIR}"
export ANIMA_STATE_DIR="${STATE_DIR}"
export ANIMA_VNC_PASSWORD_FILE="${PASSWORD_FILE}"
export ANIMA_HARDWARE_PROFILE="${ANIMA_HARDWARE_PROFILE:-none}"
export ANIMA_DESKTOP_TRANSPORT="${ANIMA_DESKTOP_TRANSPORT:-novnc}"
export ANIMA_ENABLE_NOVNC="${ANIMA_ENABLE_NOVNC:-1}"
export SELKIES_BASIC_AUTH_USER="${SELKIES_BASIC_AUTH_USER:-ubuntu}"

case "${ANIMA_DESKTOP_TRANSPORT}" in
  webrtc)
    export ANIMA_ENABLE_WEBRTC="1"
    ;;
  novnc)
    export ANIMA_ENABLE_WEBRTC="0"
    ;;
  *)
    echo "unsupported desktop transport: ${ANIMA_DESKTOP_TRANSPORT}" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac

if [[ -z "${VNC_PASSWORD:-}" || "${VNC_PASSWORD}" == "anima" ]]; then
  if [[ ! -s "${PASSWORD_FILE}" ]]; then
    generate_password > "${PASSWORD_FILE}"
    chmod 600 "${PASSWORD_FILE}"
  fi
  export VNC_PASSWORD
  VNC_PASSWORD="$(tr -d '\r\n' < "${PASSWORD_FILE}")"
  export ANIMA_VNC_PASSWORD_MODE="generated"
else
  export ANIMA_VNC_PASSWORD_MODE="explicit"
fi

export HOST_FOXGLOVE_PORT="${HOST_FOXGLOVE_PORT:-8765}"
export HOST_WEBRTC_PORT="${HOST_WEBRTC_PORT:-8080}"

ANIMA_WS_MOUNT_TYPE="${ANIMA_WS_MOUNT_TYPE:-volume}"
if [[ "${ANIMA_WS_MOUNT_TYPE}" == "bind" ]]; then
  ANIMA_WS_MOUNT_SOURCE="${ANIMA_WS_MOUNT_SOURCE:-${ROOT_DIR}/workspace}"
else
  ANIMA_WS_MOUNT_SOURCE="${ANIMA_WS_MOUNT_SOURCE:-anima_ws}"
fi
export ANIMA_WS_MOUNT_TYPE
export ANIMA_WS_MOUNT_SOURCE

if [[ -z "${ANIMA_COMPOSE_EXTRA_FILES:-}" ]]; then
  export ANIMA_COMPOSE_EXTRA_FILES="$(anima_hardware_compose_files "${ANIMA_HARDWARE_PROFILE}")"
fi

case "${ANIMA_DDS_IMPLEMENTATION:-fastrtps}" in
  cyclonedds|cyclone)
    export ANIMA_DDS_IMPLEMENTATION="cyclonedds"
    export RMW_IMPLEMENTATION="rmw_cyclonedds_cpp"
    export CYCLONEDDS_URI="file:///etc/anima/dds/cyclonedds.xml"
    unset FASTRTPS_DEFAULT_PROFILES_FILE
    ;;
  fastdds|fastrtps)
    export ANIMA_DDS_IMPLEMENTATION="fastrtps"
    export RMW_IMPLEMENTATION="rmw_fastrtps_cpp"
    export FASTRTPS_DEFAULT_PROFILES_FILE="/etc/anima/dds/fastdds.xml"
    unset CYCLONEDDS_URI
    ;;
  *)
    echo "unsupported DDS implementation: ${ANIMA_DDS_IMPLEMENTATION}" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac

if [[ "${ANIMA_DESKTOP_TRANSPORT}" == "webrtc" ]]; then
  export ANIMA_URL="http://127.0.0.1:${HOST_WEBRTC_PORT}"
else
  export ANIMA_URL="http://127.0.0.1:${HOST_NOVNC_PORT:-6080}"
fi
