#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROS_DISTRO="${1:-jazzy}"
IMAGE_TAG="robotflowlabs-anima-smoke-cyclonedds:${ROS_DISTRO}"

docker buildx build --load \
  --target base \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f "${ROOT_DIR}/docker/Dockerfile" \
  "${ROOT_DIR}"

docker run --rm \
  -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
  -e CYCLONEDDS_URI=file:///etc/anima/dds/cyclonedds.xml \
  -v "${ROOT_DIR}/config:/etc/anima:ro" \
  "${IMAGE_TAG}" \
  bash -lc '
    set -eo pipefail
    source "/opt/ros/${ROS_DISTRO}/setup.bash"
    python3 - <<'"'"'PY'"'"'
import rclpy
from rclpy.utilities import get_rmw_implementation_identifier

rclpy.init()
identifier = get_rmw_implementation_identifier()
print(identifier)
assert identifier == "rmw_cyclonedds_cpp", identifier
rclpy.shutdown()
PY
  '
