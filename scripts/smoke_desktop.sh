#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${1:-jazzy}"
HOST_PORT="${2:-6081}"
IMAGE_TAG="robotflowlabs-anima-smoke-desktop:${ROS_DISTRO}"
CONTAINER_NAME="robotflowlabs-anima-smoke-desktop-${ROS_DISTRO}"

cleanup() {
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker buildx build --load \
  --target desktop \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f docker/Dockerfile .

docker run -d --rm \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:6080" \
  "${IMAGE_TAG}"

for _ in {1..30}; do
  if curl -fsS "http://127.0.0.1:${HOST_PORT}/" >/dev/null; then
    break
  fi
  sleep 2
done

curl -fsS "http://127.0.0.1:${HOST_PORT}/" >/dev/null
docker exec "${CONTAINER_NAME}" bash -lc 'pgrep -af websockify >/dev/null'
