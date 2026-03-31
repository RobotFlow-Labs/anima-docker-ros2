#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REFERENCE_DIR="${ROOT_DIR}/repositories/docker-ros2-desktop-vnc"
UPSTREAM_URL="https://github.com/Tiryoh/docker-ros2-desktop-vnc.git"

mkdir -p "${ROOT_DIR}/repositories"

if [[ -d "${REFERENCE_DIR}/.git" ]]; then
  git -C "${REFERENCE_DIR}" fetch --all --prune
  git -C "${REFERENCE_DIR}" pull --ff-only
else
  git clone "${UPSTREAM_URL}" "${REFERENCE_DIR}"
fi
