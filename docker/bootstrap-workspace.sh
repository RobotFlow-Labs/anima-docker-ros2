#!/usr/bin/env bash
set -eo pipefail

ANIMA_WS="${ANIMA_WS:-/workspaces/anima}"
WELCOME_FILE="${ANIMA_WS}/ANIMA_WELCOME.md"
MARKER_DIR="${HOME}/.anima"
MARKER_FILE="${MARKER_DIR}/workspace_bootstrapped"

mkdir -p "${ANIMA_WS}/src" "${MARKER_DIR}" "${HOME}/.config"
touch "${ANIMA_WS}/src/.gitkeep"

if [[ ! -f "${WELCOME_FILE}" ]]; then
  cat > "${WELCOME_FILE}" <<EOF
# RobotFlowLabs ANIMA Workspace

This workspace was initialized automatically.

## Fast Commands

\`\`\`bash
cd ${ANIMA_WS}
source /opt/ros/${ROS_DISTRO}/setup.bash
colcon build
ros2 pkg list
\`\`\`

## Host Shortcuts

\`\`\`bash
./anima status
./anima demo
./anima shell
\`\`\`

## Profiles

- current profile: ${ANIMA_PROFILE_NAME:-desktop}
- host OS hint: ${ANIMA_HOST_OS:-unknown}

## Notes

- \`src/\` is ready for your ROS 2 packages
- the default workspace lives in a Docker volume for better macOS performance
- the \`./anima\` command is a host-side shortcut from this repo checkout, not an in-container command
- use \`make export\` and \`make import\` to move the workspace in and out
EOF
fi

grep -F 'export ANIMA_WS=' "${HOME}/.bashrc" >/dev/null 2>&1 || echo "export ANIMA_WS=${ANIMA_WS}" >> "${HOME}/.bashrc"
grep -F "source /opt/ros/${ROS_DISTRO}/setup.bash" "${HOME}/.bashrc" >/dev/null 2>&1 || cat >> "${HOME}/.bashrc" <<EOF
if [[ -f /opt/ros/${ROS_DISTRO}/setup.bash ]]; then
  source /opt/ros/${ROS_DISTRO}/setup.bash
fi
EOF
grep -F 'source "${ANIMA_WS}/install/setup.bash"' "${HOME}/.bashrc" >/dev/null 2>&1 || cat >> "${HOME}/.bashrc" <<'EOF'
if [[ -f "${ANIMA_WS}/install/setup.bash" ]]; then
  source "${ANIMA_WS}/install/setup.bash"
fi
EOF
grep -F 'cd ${ANIMA_WS}' "${HOME}/.bashrc" >/dev/null 2>&1 || cat >> "${HOME}/.bashrc" <<'EOF'
if [[ "$PWD" == "$HOME" ]]; then
  cd "${ANIMA_WS}"
fi
EOF

grep -F 'alias cw=' "${HOME}/.bashrc" >/dev/null 2>&1 || echo "alias cw='cd ${ANIMA_WS}'" >> "${HOME}/.bashrc"
grep -F 'alias cs=' "${HOME}/.bashrc" >/dev/null 2>&1 || echo "alias cs='cd ${ANIMA_WS}/src'" >> "${HOME}/.bashrc"
grep -F 'alias sb=' "${HOME}/.bashrc" >/dev/null 2>&1 || echo "alias sb='source /opt/ros/${ROS_DISTRO}/setup.bash'" >> "${HOME}/.bashrc"

if [[ ! -f "${MARKER_FILE}" ]]; then
  date -u +"%Y-%m-%dT%H:%M:%SZ" > "${MARKER_FILE}"
fi
