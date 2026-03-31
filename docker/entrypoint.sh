#!/usr/bin/env bash
set -eo pipefail

for runtime_script in /etc/anima/runtime.d/*.sh; do
  if [[ -r "${runtime_script}" ]]; then
    # Profile-specific runtime defaults are injected here.
    source "${runtime_script}"
  fi
done

if [[ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi

if [[ -f "${ANIMA_WS}/install/setup.bash" ]]; then
  source "${ANIMA_WS}/install/setup.bash"
fi

/usr/local/bin/anima-bootstrap

if [[ "${1:-bash}" == "desktop" ]]; then
  exec /usr/local/bin/anima-desktop
fi

if [[ "${1:-bash}" == "bash" && -t 1 ]]; then
  cat <<EOF
RobotFlowLabs ANIMA
workspace: ${ANIMA_WS}
profile: ${ANIMA_PROFILE_NAME:-desktop}
welcome: ${ANIMA_WS}/ANIMA_WELCOME.md
EOF
fi

exec "$@"
