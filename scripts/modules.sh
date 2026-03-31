#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

MODULE_DIR="${ROOT_DIR}/modules"

usage() {
  cat <<'EOF'
usage: ./anima module [list|show|install] [MODULE_ID] [--force]

Commands:
  list                 list bundled ANIMA modules
  show <id>            show one module bundle
  install <id>         copy the module bundle into /workspaces/anima/src

Options:
  --force              overwrite an existing target package directory
EOF
}

manifest_path() {
  local module_id="$1"
  local manifest="${MODULE_DIR}/${module_id}.env"
  if [[ ! -f "${manifest}" ]]; then
    echo "unknown module bundle: ${module_id}" >&2
    exit 1
  fi
  printf '%s\n' "${manifest}"
}

load_manifest() {
  unset MODULE_ID MODULE_TITLE MODULE_DESCRIPTION MODULE_PATHS MODULE_NEXT_STEPS
  # shellcheck disable=SC1090
  source "$1"
}

list_modules() {
  local manifest
  echo "RobotFlowLabs ANIMA module bundles"
  for manifest in "${MODULE_DIR}"/*.env; do
    load_manifest "${manifest}"
    printf '[info] %-8s %s\n' "${MODULE_ID}" "${MODULE_TITLE}"
    printf '       %s\n' "${MODULE_DESCRIPTION}"
  done
}

show_module() {
  local manifest="$1"
  local path
  load_manifest "${manifest}"
  echo "RobotFlowLabs ANIMA module bundle"
  echo "[info] id: ${MODULE_ID}"
  echo "[info] title: ${MODULE_TITLE}"
  echo "[info] description: ${MODULE_DESCRIPTION}"
  echo "[info] contents:"
  IFS=: read -r -a paths <<< "${MODULE_PATHS}"
  for path in "${paths[@]}"; do
    echo "  - $(basename "${path}")"
  done
  echo "[info] next: ${MODULE_NEXT_STEPS}"
}

install_module() {
  local manifest="$1"
  local force="$2"
  load_manifest "${manifest}"

  env MODULE_PATHS="${MODULE_PATHS}" MODULE_FORCE="${force}" "${ROOT_DIR}/scripts/compose.sh" run --rm -T \
    -e MODULE_PATHS \
    -e MODULE_FORCE \
    -v "${ROOT_DIR}:/tmp/anima-repo:ro" \
    desktop bash -lc '
      set -euo pipefail
      mkdir -p /workspaces/anima/src
      IFS=: read -r -a paths <<< "${MODULE_PATHS}"
      for rel in "${paths[@]}"; do
        src="/tmp/anima-repo/${rel}"
        name="$(basename "${rel}")"
        dest="/workspaces/anima/src/${name}"
        if [[ ! -d "${src}" ]]; then
          echo "module source missing: ${src}" >&2
          exit 1
        fi
        if [[ -e "${dest}" && "${MODULE_FORCE}" != "true" ]]; then
          echo "module target already exists: ${dest}" >&2
          exit 2
        fi
        rm -rf "${dest}"
        cp -R "${src}" "${dest}"
      done
    ' || status=$?

  status="${status:-0}"
  if [[ "${status}" -eq 2 ]]; then
    echo "use './anima module install ${MODULE_ID} --force' to overwrite the existing package directories" >&2
    exit 2
  fi
  if [[ "${status}" -ne 0 ]]; then
    exit "${status}"
  fi

  echo "RobotFlowLabs ANIMA module bundle installed"
  echo "[info] id: ${MODULE_ID}"
  echo "[info] title: ${MODULE_TITLE}"
  echo "[info] workspace: /workspaces/anima/src"
  echo "[info] next: ${MODULE_NEXT_STEPS}"
}

command_name="${1:-list}"
if [[ $# -gt 0 ]]; then
  shift
fi

case "${command_name}" in
  list)
    list_modules
    ;;
  show)
    [[ $# -ge 1 ]] || {
      usage >&2
      exit 1
    }
    show_module "$(manifest_path "$1")"
    ;;
  install)
    [[ $# -ge 1 ]] || {
      usage >&2
      exit 1
    }
    module_id="$1"
    shift
    force="false"
    if [[ "${1:-}" == "--force" ]]; then
      force="true"
      shift
    fi
    [[ $# -eq 0 ]] || {
      usage >&2
      exit 1
    }
    install_module "$(manifest_path "${module_id}")" "${force}"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
