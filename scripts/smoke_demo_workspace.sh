#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROS_DISTRO="${1:-jazzy}"
IMAGE_TAG="robotflowlabs-anima-smoke-demo:${ROS_DISTRO}"

docker buildx build --load \
  --target base \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f "${ROOT_DIR}/docker/Dockerfile" \
  "${ROOT_DIR}"

docker run --rm \
  -v "${ROOT_DIR}/examples/robotflowlabs_anima_demo:/workspaces/anima/src/robotflowlabs_anima_demo:ro" \
  "${IMAGE_TAG}" \
  bash -lc '
    set -eo pipefail
    cd /workspaces/anima
    colcon build
    source install/setup.bash
    timeout 5 ros2 run robotflowlabs_anima_demo hello_anima > /tmp/anima-demo.log 2>&1 || status=$?
    status="${status:-0}"
    if [[ "${status}" != "0" && "${status}" != "124" ]]; then
      cat /tmp/anima-demo.log >&2
      exit "${status}"
    fi
    grep -q "RobotFlowLabs ANIMA demo node started" /tmp/anima-demo.log
  '
