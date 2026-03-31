#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROS_DISTRO="${1:-jazzy}"
HOST_PORT="${2:-8766}"
IMAGE_TAG="robotflowlabs-anima-smoke-foxglove:${ROS_DISTRO}"
CONTAINER_NAME="robotflowlabs-anima-smoke-foxglove-${ROS_DISTRO}"

cleanup() {
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker buildx build --load \
  --target dev \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f "${ROOT_DIR}/docker/Dockerfile" \
  "${ROOT_DIR}"

docker run -d --rm \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:8765" \
  -v "${ROOT_DIR}/config:/etc/anima:ro" \
  "${IMAGE_TAG}" \
  bash -lc "set -eo pipefail && source /opt/ros/${ROS_DISTRO}/setup.bash && exec ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8765 address:=0.0.0.0"

for _ in {1..30}; do
  if python3 - "127.0.0.1" "${HOST_PORT}" <<'PY'
import socket
import sys

host = sys.argv[1]
port = int(sys.argv[2])
s = socket.socket()
s.settimeout(1.0)
try:
    s.connect((host, port))
except OSError:
    sys.exit(1)
finally:
    s.close()
PY
  then
    exit 0
  fi
  sleep 1
done

docker logs "${CONTAINER_NAME}" >&2
exit 1
