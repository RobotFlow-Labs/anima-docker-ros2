#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROS_DISTRO="${1:-jazzy}"
IMAGE_TAG="robotflowlabs-anima-smoke-multicontainer-dds:${ROS_DISTRO}"
LISTENER_NAME="robotflowlabs-anima-smoke-dds-listener-${ROS_DISTRO}"
ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-87}"

cleanup() {
  docker rm -f "${LISTENER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker buildx build --load \
  --target desktop \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f "${ROOT_DIR}/docker/Dockerfile" \
  "${ROOT_DIR}"

docker run -d \
  --name "${LISTENER_NAME}" \
  --network host \
  -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
  -e ROS_DOMAIN_ID="${ROS_DOMAIN_ID}" \
  -e CYCLONEDDS_URI=file:///etc/anima/dds/cyclonedds.xml \
  -v "${ROOT_DIR}/config:/etc/anima:ro" \
  "${IMAGE_TAG}" \
  bash -lc "set -eo pipefail && source /opt/ros/${ROS_DISTRO}/setup.bash && exec timeout 20s ros2 run demo_nodes_cpp listener"

for _ in {1..4}; do
  if docker logs "${LISTENER_NAME}" 2>&1 | grep -q "Listening"; then
    break
  fi
  sleep 1
done

sleep 3

docker run --rm \
  --network host \
  -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
  -e ROS_DOMAIN_ID="${ROS_DOMAIN_ID}" \
  -e CYCLONEDDS_URI=file:///etc/anima/dds/cyclonedds.xml \
  -v "${ROOT_DIR}/config:/etc/anima:ro" \
  "${IMAGE_TAG}" \
  bash -lc "set -eo pipefail && source /opt/ros/${ROS_DISTRO}/setup.bash && set +e && timeout 10s ros2 run demo_nodes_cpp talker >/tmp/talker.log 2>&1; status=\$?; set -e; if [[ \$status -ne 0 && \$status -ne 124 ]]; then cat /tmp/talker.log >&2; exit \$status; fi"

listener_exit="$(docker wait "${LISTENER_NAME}")"
listener_logs="$(mktemp)"
docker logs "${LISTENER_NAME}" > "${listener_logs}" 2>&1 || true

if [[ "${listener_exit}" != "0" && "${listener_exit}" != "124" ]]; then
  cat "${listener_logs}" >&2
  exit 1
fi

grep -Eq "I heard:|Hello World" "${listener_logs}"
