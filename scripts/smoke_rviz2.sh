#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROS_DISTRO="${1:-jazzy}"
HOST_PORT="${2:-6082}"
IMAGE_TAG="robotflowlabs-anima-smoke-rviz2:${ROS_DISTRO}"
CONTAINER_NAME="robotflowlabs-anima-smoke-rviz2-${ROS_DISTRO}"

cleanup() {
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker buildx build --load \
  --target desktop \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f "${ROOT_DIR}/docker/Dockerfile" \
  "${ROOT_DIR}"

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${HOST_PORT}:6080" \
  "${IMAGE_TAG}"

for _ in {1..30}; do
  if docker exec "${CONTAINER_NAME}" bash -lc 'pgrep -af websockify >/dev/null && pgrep -af Xvnc >/dev/null'; then
    break
  fi
  sleep 2
done

docker exec \
  -e DISPLAY=:1 \
  -e LIBGL_ALWAYS_SOFTWARE=1 \
  -e QT_X11_NO_MITSHM=1 \
  "${CONTAINER_NAME}" \
  bash -lc "set -eo pipefail && source /opt/ros/${ROS_DISTRO}/setup.bash && set +e && timeout 20s rviz2 >/tmp/rviz2.log 2>&1; status=\$?; set -e; if [[ \$status -ne 0 && \$status -ne 124 ]]; then cat /tmp/rviz2.log >&2; exit \$status; fi; if [[ \$status -eq 0 ]]; then grep -Eq 'RViz|OGRE|Rendering' /tmp/rviz2.log || { cat /tmp/rviz2.log >&2; exit 1; }; fi"
