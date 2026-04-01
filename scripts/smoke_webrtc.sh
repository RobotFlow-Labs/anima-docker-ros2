#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${1:-jazzy}"
WEBRTC_PORT="${2:-8081}"
IMAGE_TAG="robotflowlabs-anima-smoke-webrtc:${ROS_DISTRO}"
CONTAINER_NAME="robotflowlabs-anima-smoke-webrtc-${ROS_DISTRO}"
WEBRTC_USER="${WEBRTC_USER:-ubuntu}"
WEBRTC_PASSWORD="${WEBRTC_PASSWORD:-preview1}"

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
  -p "${WEBRTC_PORT}:8080" \
  -e ANIMA_DESKTOP_TRANSPORT=webrtc \
  -e ANIMA_ENABLE_WEBRTC=1 \
  -e ANIMA_ENABLE_NOVNC=0 \
  -e SELKIES_BASIC_AUTH_USER="${WEBRTC_USER}" \
  -e VNC_PASSWORD="${WEBRTC_PASSWORD}" \
  "${IMAGE_TAG}" \
  desktop

for _ in {1..30}; do
  if curl -fsS -u "${WEBRTC_USER}:${WEBRTC_PASSWORD}" "http://127.0.0.1:${WEBRTC_PORT}/" >/dev/null; then
    break
  fi
  sleep 2
done

curl -fsS -u "${WEBRTC_USER}:${WEBRTC_PASSWORD}" "http://127.0.0.1:${WEBRTC_PORT}/" >/dev/null
docker exec "${CONTAINER_NAME}" bash -lc 'pgrep -af selkies-gstreamer >/dev/null'
