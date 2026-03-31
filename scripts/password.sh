#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTION="${1:-show}"

# shellcheck disable=SC1090
source "${ROOT_DIR}/scripts/load_env.sh"

case "${ACTION}" in
  show)
    echo "${VNC_PASSWORD}"
    ;;
  reset)
    if [[ "${ANIMA_VNC_PASSWORD_MODE}" != "generated" ]]; then
      echo "VNC password comes from the env file, so reset is disabled." >&2
      echo "Edit ${ENV_FILE} if you want to change it." >&2
      exit 1
    fi

    rm -f "${ANIMA_VNC_PASSWORD_FILE}"
    # shellcheck disable=SC1090
    source "${ROOT_DIR}/scripts/load_env.sh"
    echo "${VNC_PASSWORD}"
    ;;
  *)
    echo "usage: ./anima password [show|reset]" >&2
    exit 1
    ;;
esac
