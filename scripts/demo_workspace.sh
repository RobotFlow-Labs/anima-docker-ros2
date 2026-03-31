#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

FORCE="false"
if [[ "${1:-}" == "--force" ]]; then
  FORCE="true"
fi

TARGET_DIR="/workspaces/anima/src/robotflowlabs_anima_demo"
COPY_CMD='
set -euo pipefail
if [[ -d "'"${TARGET_DIR}"'" && "'"${FORCE}"'" != "true" ]]; then
  echo "demo workspace already exists at '"${TARGET_DIR}"'" >&2
  exit 2
fi
rm -rf "'"${TARGET_DIR}"'"
mkdir -p "'"${TARGET_DIR}"'"
cp -R /tmp/robotflowlabs_anima_demo/. "'"${TARGET_DIR}"'"
'

status=0
"${ROOT_DIR}/scripts/compose.sh" run --rm -T \
  -v "${ROOT_DIR}/examples/robotflowlabs_anima_demo:/tmp/robotflowlabs_anima_demo:ro" \
  desktop bash -lc "${COPY_CMD}" || status=$?

if [[ ${status} -ne 0 ]]; then
  if [[ ${status} -eq 2 ]]; then
    echo "use './anima demo --force' to overwrite the existing demo workspace" >&2
  fi
  exit ${status}
fi

cat <<'EOF'
RobotFlowLabs ANIMA demo workspace copied into /workspaces/anima/src/robotflowlabs_anima_demo

Next:
  ./anima shell
  cd /workspaces/anima
  colcon build
  source install/setup.bash
  ros2 run robotflowlabs_anima_demo hello_anima
EOF
