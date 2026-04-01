#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

MODULE_DIR="${ROOT_DIR}/modules"

normalize_module_id() {
  case "${1:-}" in
    starter)
      printf 'starter-visualization\n'
      ;;
    *)
      printf '%s\n' "${1:-}"
      ;;
  esac
}

usage() {
  cat <<'EOF'
usage: ./anima starter [list|show|install|remove|test] [MODULE_ID] [--force]
       ./anima module  [list|show|install|remove|test] [MODULE_ID] [--force]

Commands:
  list                 list bundled ANIMA starter packs
  show <id>            show one starter pack bundle
  install <id>         copy the starter bundle into /workspaces/anima/src
  remove <id>          remove the installed starter bundle from /workspaces/anima/src
  test <id>            build the bundle in a temporary workspace and run its smoke command

Options:
  --force              overwrite an existing target package directory during install
EOF
}

is_command() {
  case "${1:-}" in
    list|show|install|remove|test|help|-h|--help)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

render_list() {
  local value="${1:-}"
  if [[ -z "${value}" ]]; then
    printf 'none'
    return
  fi
  printf '%s' "${value//:/, }"
}

split_list() {
  local value="${1:-}"
  local -n result_ref="$2"
  result_ref=()
  if [[ -n "${value}" ]]; then
    IFS=: read -r -a result_ref <<< "${value}"
  fi
}

manifest_path() {
  local module_id
  module_id="$(normalize_module_id "$1")"
  local manifest="${MODULE_DIR}/${module_id}.env"
  if [[ ! -f "${manifest}" ]]; then
    echo "unknown starter pack: ${module_id}" >&2
    exit 1
  fi
  printf '%s\n' "${manifest}"
}

load_manifest() {
  local manifest="$1"
  unset MODULE_ID MODULE_TITLE MODULE_VERSION MODULE_SUMMARY MODULE_DESCRIPTION
  unset MODULE_SOURCE_PATHS MODULE_PATHS MODULE_INSTALL_TARGETS MODULE_DEPENDS
  unset MODULE_SUPPORTED_DISTROS MODULE_SUPPORTED_PROFILES MODULE_NEXT_STEPS MODULE_SMOKE_COMMAND
  # shellcheck disable=SC1090
  source "${manifest}"
  MODULE_SUMMARY="${MODULE_SUMMARY:-${MODULE_DESCRIPTION:-}}"
  MODULE_DESCRIPTION="${MODULE_DESCRIPTION:-${MODULE_SUMMARY:-}}"
  MODULE_SOURCE_PATHS="${MODULE_SOURCE_PATHS:-${MODULE_PATHS:-}}"
  MODULE_INSTALL_TARGETS="${MODULE_INSTALL_TARGETS:-}"
  MODULE_DEPENDS="${MODULE_DEPENDS:-}"
  MODULE_SUPPORTED_DISTROS="${MODULE_SUPPORTED_DISTROS:-}"
  MODULE_SUPPORTED_PROFILES="${MODULE_SUPPORTED_PROFILES:-}"
  MODULE_NEXT_STEPS="${MODULE_NEXT_STEPS:-}"
  MODULE_SMOKE_COMMAND="${MODULE_SMOKE_COMMAND:-${MODULE_NEXT_STEPS:-}}"
  MODULE_VERSION="${MODULE_VERSION:-1.0.0}"
}

load_runtime_context() {
  if [[ -n "${ANIMA_RUNTIME_CONTEXT_LOADED:-}" ]]; then
    return
  fi

  local env_file="${ANIMA_ENV_FILE:-$("${ROOT_DIR}/scripts/resolve_env.sh")}"
  if [[ ! -f "${env_file}" ]]; then
    echo "env file not found: ${env_file}" >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  set -a && source "${env_file}" && set +a
  export ANIMA_RUNTIME_CONTEXT_LOADED=1
  export ANIMA_RUNTIME_ENV_FILE="${env_file}"
  export ANIMA_RUNTIME_PROFILE="${ANIMA_PROFILE:-desktop}"
  export ANIMA_RUNTIME_DISTRO="${ROS_DISTRO:-jazzy}"
}

validate_compatibility() {
  local manifest="$1"
  load_manifest "${manifest}"
  load_runtime_context

  local current_profile="${ANIMA_RUNTIME_PROFILE}"
  local current_distro="${ANIMA_RUNTIME_DISTRO}"
  local -a supported_profiles=()
  local -a supported_distros=()
  split_list "${MODULE_SUPPORTED_PROFILES}" supported_profiles
  split_list "${MODULE_SUPPORTED_DISTROS}" supported_distros

  if [[ "${#supported_profiles[@]}" -gt 0 ]]; then
    if ! printf '%s\n' "${supported_profiles[@]}" | grep -qx "${current_profile}"; then
      echo "starter pack '${MODULE_ID}' is not supported on profile '${current_profile}'" >&2
      echo "supported profiles: $(render_list "${MODULE_SUPPORTED_PROFILES}")" >&2
      exit 3
    fi
  fi

  if [[ "${#supported_distros[@]}" -gt 0 ]]; then
    if ! printf '%s\n' "${supported_distros[@]}" | grep -qx "${current_distro}"; then
      echo "starter pack '${MODULE_ID}' is not supported on ROS distro '${current_distro}'" >&2
      echo "supported distros: $(render_list "${MODULE_SUPPORTED_DISTROS}")" >&2
      exit 3
    fi
  fi
}

source_paths() {
  local -a paths=()
  split_list "${MODULE_SOURCE_PATHS}" paths
  if [[ "${#paths[@]}" -eq 0 ]]; then
    split_list "${MODULE_PATHS:-}" paths
  fi
  printf '%s\n' "${paths[@]}"
}

install_targets() {
  local -a targets=()
  split_list "${MODULE_INSTALL_TARGETS}" targets
  if [[ "${#targets[@]}" -eq 0 ]]; then
    local -a paths=()
    split_list "${MODULE_SOURCE_PATHS}" paths
    if [[ "${#paths[@]}" -eq 0 ]]; then
      split_list "${MODULE_PATHS:-}" paths
    fi
    local path
    for path in "${paths[@]}"; do
      targets+=("$(basename "${path}")")
    done
  fi
  printf '%s\n' "${targets[@]}"
}

with_workspace_command() {
  local script="$1"
  env \
    MODULE_ID="${MODULE_ID}" \
    MODULE_SOURCE_PATHS="${MODULE_SOURCE_PATHS}" \
    MODULE_INSTALL_TARGETS="${MODULE_INSTALL_TARGETS}" \
    MODULE_SMOKE_COMMAND="${MODULE_SMOKE_COMMAND}" \
    MODULE_FORCE="${MODULE_FORCE:-false}" \
    "${ROOT_DIR}/scripts/compose.sh" run --rm -T \
    -e MODULE_ID \
    -e MODULE_SOURCE_PATHS \
    -e MODULE_INSTALL_TARGETS \
    -e MODULE_SMOKE_COMMAND \
    -e MODULE_FORCE \
    -v "${ROOT_DIR}:/tmp/anima-repo:ro" \
    desktop bash -lc "${script}"
}

list_modules() {
  local manifest
  echo "RobotFlowLabs ANIMA starter packs"
  shopt -s nullglob
  for manifest in "${MODULE_DIR}"/*.env; do
    load_manifest "${manifest}"
    printf '[info] %-22s %-8s %s\n' "${MODULE_ID}" "${MODULE_VERSION}" "${MODULE_TITLE}"
    printf '       %s\n' "${MODULE_SUMMARY}"
    printf '       distros: %s\n' "$(render_list "${MODULE_SUPPORTED_DISTROS}")"
    printf '       profiles: %s\n' "$(render_list "${MODULE_SUPPORTED_PROFILES}")"
  done
  shopt -u nullglob
}

show_module() {
  local manifest="$1"
  local path
  load_manifest "${manifest}"
  echo "RobotFlowLabs ANIMA starter pack"
  echo "[info] id: ${MODULE_ID}"
  echo "[info] title: ${MODULE_TITLE}"
  echo "[info] version: ${MODULE_VERSION}"
  echo "[info] summary: ${MODULE_SUMMARY}"
  echo "[info] supported distros: $(render_list "${MODULE_SUPPORTED_DISTROS}")"
  echo "[info] supported profiles: $(render_list "${MODULE_SUPPORTED_PROFILES}")"
  echo "[info] dependencies: $(render_list "${MODULE_DEPENDS}")"
  echo "[info] install targets:"
  while IFS= read -r path; do
    [[ -n "${path}" ]] || continue
    echo "  - ${path}"
  done < <(install_targets)
  echo "[info] smoke test: ${MODULE_SMOKE_COMMAND}"
  echo "[info] next: ${MODULE_NEXT_STEPS}"
}

install_module() {
  local manifest="$1"
  local force="$2"
  validate_compatibility "${manifest}"
  load_manifest "${manifest}"

  MODULE_FORCE="${force}" with_workspace_command '
    set -euo pipefail
    mkdir -p /workspaces/anima/src

    mapfile -t source_paths < <(printf "%s" "${MODULE_SOURCE_PATHS}" | tr ":" "\n")
    mapfile -t install_targets < <(printf "%s" "${MODULE_INSTALL_TARGETS}" | tr ":" "\n")

    if [[ "${#install_targets[@]}" -eq 0 ]]; then
      install_targets=()
      rel=""
      for rel in "${source_paths[@]}"; do
        [[ -n "${rel}" ]] || continue
        install_targets+=("$(basename "${rel}")")
      done
    fi

    if [[ "${#source_paths[@]}" -ne "${#install_targets[@]}" ]]; then
      echo "starter metadata mismatch: source paths and install targets differ" >&2
      exit 1
    fi

    for i in "${!source_paths[@]}"; do
      rel="${source_paths[$i]}"
      target="${install_targets[$i]}"
      src="/tmp/anima-repo/${rel}"
      dest="/workspaces/anima/src/${target}"
      if [[ ! -d "${src}" ]]; then
        echo "starter source missing: ${src}" >&2
        exit 1
      fi
      if [[ -e "${dest}" && "${MODULE_FORCE}" != "true" ]]; then
        echo "starter target already exists: ${dest}" >&2
        exit 2
      fi
      rm -rf "${dest}"
      cp -R "${src}" "${dest}"
    done
  ' || status=$?

  status="${status:-0}"
  if [[ "${status}" -eq 2 ]]; then
    echo "use './anima starter install ${MODULE_ID} --force' to overwrite the existing package directories" >&2
    exit 2
  fi
  if [[ "${status}" -ne 0 ]]; then
    exit "${status}"
  fi

  echo "RobotFlowLabs ANIMA starter pack installed"
  echo "[info] id: ${MODULE_ID}"
  echo "[info] title: ${MODULE_TITLE}"
  echo "[info] workspace: /workspaces/anima/src"
  echo "[info] next: ${MODULE_NEXT_STEPS}"
}

remove_module() {
  local manifest="$1"
  validate_compatibility "${manifest}"
  load_manifest "${manifest}"

  with_workspace_command '
    set -euo pipefail
    mkdir -p /workspaces/anima/src
    mapfile -t install_targets < <(printf "%s" "${MODULE_INSTALL_TARGETS}" | tr ":" "\n")
    if [[ "${#install_targets[@]}" -eq 0 ]]; then
      echo "starter metadata missing install targets for ${MODULE_ID}" >&2
      exit 1
    fi

    for target in "${install_targets[@]}"; do
      dest="/workspaces/anima/src/${target}"
      if [[ ! -e "${dest}" ]]; then
        echo "[info] starter target already absent: ${dest}"
        continue
      fi
      rm -rf "${dest}"
      echo "[info] removed ${dest}"
    done
  '

  echo "RobotFlowLabs ANIMA starter pack removed"
  echo "[info] id: ${MODULE_ID}"
  echo "[info] title: ${MODULE_TITLE}"
}

test_module() {
  local manifest="$1"
  validate_compatibility "${manifest}"
  load_manifest "${manifest}"

  with_workspace_command '
    set -euo pipefail
    workspace="$(mktemp -d /tmp/anima-starter-XXXXXX)"
    trap "rm -rf \"${workspace}\"" EXIT
    mkdir -p "${workspace}/src"

    mapfile -t source_paths < <(printf "%s" "${MODULE_SOURCE_PATHS}" | tr ":" "\n")
    mapfile -t install_targets < <(printf "%s" "${MODULE_INSTALL_TARGETS}" | tr ":" "\n")

    if [[ "${#install_targets[@]}" -eq 0 ]]; then
      install_targets=()
      rel=""
      for rel in "${source_paths[@]}"; do
        [[ -n "${rel}" ]] || continue
        install_targets+=("$(basename "${rel}")")
      done
    fi

    if [[ "${#source_paths[@]}" -ne "${#install_targets[@]}" ]]; then
      echo "starter metadata mismatch: source paths and install targets differ" >&2
      exit 1
    fi

    for i in "${!source_paths[@]}"; do
      rel="${source_paths[$i]}"
      target="${install_targets[$i]}"
      src="/tmp/anima-repo/${rel}"
      dest="${workspace}/src/${target}"
      if [[ ! -d "${src}" ]]; then
        echo "starter source missing: ${src}" >&2
        exit 1
      fi
      cp -R "${src}" "${dest}"
    done

    cd "${workspace}"
    colcon build
    set +u
    source install/setup.bash
    set -u
    eval "${MODULE_SMOKE_COMMAND}"
  '

  echo "RobotFlowLabs ANIMA starter pack test passed"
  echo "[info] id: ${MODULE_ID}"
  echo "[info] title: ${MODULE_TITLE}"
}

raw_command="${1:-}"
if is_command "${raw_command}"; then
  namespace="starter"
  command_name="${raw_command}"
  shift || true
else
  namespace="${raw_command:-starter}"
  if [[ $# -gt 0 ]]; then
    shift
  fi
  command_name="${1:-list}"
  if [[ $# -gt 0 ]]; then
    shift
  fi
fi

case "${namespace}" in
  starter|module|modules)
    ;;
  "")
    namespace="starter"
    ;;
  *)
    echo "unknown starter namespace: ${namespace}" >&2
    usage >&2
    exit 1
    ;;
esac

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
  remove)
    [[ $# -ge 1 ]] || {
      usage >&2
      exit 1
    }
    remove_module "$(manifest_path "$1")"
    ;;
  test)
    [[ $# -ge 1 ]] || {
      usage >&2
      exit 1
    }
    test_module "$(manifest_path "$1")"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
