#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${1:-jazzy}"
IMAGE_TAG="robotflowlabs-anima-smoke-base:${ROS_DISTRO}"

docker buildx build --load \
  --target base \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f docker/Dockerfile .

docker run --rm "${IMAGE_TAG}" bash -lc \
  'test -f "/opt/ros/${ROS_DISTRO}/setup.bash" && ros2 --help >/dev/null'
