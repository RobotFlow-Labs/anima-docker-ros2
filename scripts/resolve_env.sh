#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST_OS="$(uname -s)"
HOST_ARCH="$(uname -m)"
PROFILE="${ANIMA_PROFILE:-desktop}"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  echo "${ROOT_DIR}/.env"
  exit 0
fi

if [[ "${HOST_OS}" == "Darwin" ]]; then
  if [[ "${PROFILE}" != "desktop" && -f "${ROOT_DIR}/.env.${PROFILE}" ]]; then
    echo "${ROOT_DIR}/.env.${PROFILE}"
    exit 0
  fi

  if [[ "${HOST_ARCH}" == "x86_64" && -f "${ROOT_DIR}/.env.intel" ]]; then
    echo "${ROOT_DIR}/.env.intel"
    exit 0
  fi

  if [[ -f "${ROOT_DIR}/.env.mac" ]]; then
    echo "${ROOT_DIR}/.env.mac"
    exit 0
  fi
fi

if [[ -f "${ROOT_DIR}/.env.example" ]]; then
  echo "${ROOT_DIR}/.env.example"
  exit 0
fi

exit 1
