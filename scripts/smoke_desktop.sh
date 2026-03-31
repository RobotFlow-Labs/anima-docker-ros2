#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${1:-jazzy}"
NOVNC_PORT="${2:-6081}"
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
  -p "${NOVNC_PORT}:6080" \
  -e ANIMA_ENABLE_WEBRTC=0 \
  "${IMAGE_TAG}" \
  desktop

for _ in {1..30}; do
  if curl -fsS "http://127.0.0.1:${NOVNC_PORT}/" >/dev/null; then
    break
  fi
  sleep 2
done

curl -fsS "http://127.0.0.1:${NOVNC_PORT}/" >/dev/null
docker exec "${CONTAINER_NAME}" bash -lc 'pgrep -af websockify >/dev/null'
