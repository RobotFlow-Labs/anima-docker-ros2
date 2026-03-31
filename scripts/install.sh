#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_BIN_DIR="${ANIMA_INSTALL_BIN_DIR:-${HOME}/.local/bin}"
TARGET_PATH="${TARGET_BIN_DIR}/anima"

mkdir -p "${TARGET_BIN_DIR}"
ln -sf "${ROOT_DIR}/anima" "${TARGET_PATH}"

echo "installed ANIMA CLI at ${TARGET_PATH}"

case ":${PATH}:" in
  *:"${TARGET_BIN_DIR}":*)
    echo "you can now run: anima help"
    ;;
  *)
    echo "add ${TARGET_BIN_DIR} to your PATH to run 'anima' from anywhere"
    ;;
esac
