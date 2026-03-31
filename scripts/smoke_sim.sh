#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROS_DISTRO="${1:-jazzy}"
IMAGE_TAG="robotflowlabs-anima-smoke-sim:${ROS_DISTRO}"

docker buildx build --load \
  --target sim \
  --build-arg ROS_DISTRO="${ROS_DISTRO}" \
  -t "${IMAGE_TAG}" \
  -f "${ROOT_DIR}/docker/Dockerfile" \
  "${ROOT_DIR}"

docker run --rm "${IMAGE_TAG}" bash -lc "set -eo pipefail
source /opt/ros/${ROS_DISTRO}/setup.bash

ros2 pkg prefix ros_gz_sim >/dev/null

launch_dir=\"\$(ros2 pkg prefix ros_gz_sim)/share/ros_gz_sim/launch\"
launch_file=\"\$(find \"\${launch_dir}\" -maxdepth 1 -name '*.launch.py' | sort | head -n 1)\"
test -n \"\${launch_file}\"

show_args=\"\$(ros2 launch ros_gz_sim \"\$(basename \"\${launch_file}\")\" --show-args)\"
launch_args=()
if grep -q 'headless' <<<\"\${show_args}\"; then
  launch_args+=(headless:=true)
elif grep -q 'gui' <<<\"\${show_args}\"; then
  launch_args+=(gui:=false)
fi

set +e
timeout 20s ros2 launch ros_gz_sim \"\$(basename \"\${launch_file}\")\" \"\${launch_args[@]}\" >/tmp/ros_gz_smoke.log 2>&1
status=\$?
set -e
if [[ \$status -ne 0 && \$status -ne 124 ]]; then
  cat /tmp/ros_gz_smoke.log >&2
  exit \$status
fi

grep -Eq 'ros_gz|Gazebo|launch' /tmp/ros_gz_smoke.log
"
