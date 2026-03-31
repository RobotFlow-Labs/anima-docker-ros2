#!/usr/bin/env bash
set -euo pipefail

export USER="${USER:-ubuntu}"
export HOME="${HOME:-/home/ubuntu}"
export DISPLAY="${DISPLAY:-:1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-${USER}}"

VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
WEBRTC_PORT="${WEBRTC_PORT:-8080}"
VNC_PORT="${VNC_PORT:-5901}"
VNC_PASSWORD="${VNC_PASSWORD:-anima}"
ANIMA_ENABLE_NOVNC="${ANIMA_ENABLE_NOVNC:-1}"
ANIMA_ENABLE_WEBRTC="${ANIMA_ENABLE_WEBRTC:-1}"
ANIMA_DESKTOP_TRANSPORT="${ANIMA_DESKTOP_TRANSPORT:-webrtc}"
SELKIES_USER="${SELKIES_BASIC_AUTH_USER:-${USER}}"
SELKIES_WEB_ROOT="${SELKIES_WEB_ROOT:-/opt/gst-web}"
SELKIES_ENCODER="${SELKIES_ENCODER:-x264enc}"
SELKIES_FRAMERATE="${SELKIES_FRAMERATE:-30}"
SELKIES_VIDEO_BITRATE="${SELKIES_VIDEO_BITRATE:-4000}"

export VNC_PASSWORD

mkdir -p "${HOME}/.vnc"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"
# Ubuntu Noble's TigerVNC packages do not ship a vncpasswd helper, so
# generate the VNC auth blob directly before starting tigervncserver.
python3 - <<'PY' | openssl enc -des-ecb -provider default -provider legacy -K 17526b06234e5807 -nosalt -nopad -out "${HOME}/.vnc/passwd"
import os
import sys

password = os.environ["VNC_PASSWORD"].encode("utf-8")[:8].ljust(8, b"\0")
sys.stdout.buffer.write(password)
PY
chmod 600 "${HOME}/.vnc/passwd"

cat > "${HOME}/.vnc/xstartup" <<'EOF'
#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x "${HOME}/.vnc/xstartup"

rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1

vncserver "${DISPLAY}" -geometry "${VNC_GEOMETRY}" -depth "${VNC_DEPTH}" -localhost no

declare -a CHILD_PIDS=()
declare -a CHILD_NAMES=()

cleanup() {
  for pid in "${CHILD_PIDS[@]:-}"; do
    [[ -z "${pid}" ]] && continue
    kill "${pid}" >/dev/null 2>&1 || true
  done
  vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ "${ANIMA_ENABLE_NOVNC}" == "1" ]]; then
  python3 -m websockify --web=/usr/share/novnc "${NOVNC_PORT}" "localhost:${VNC_PORT}" &
  CHILD_PIDS+=("$!")
  CHILD_NAMES+=("novnc")
fi

if [[ "${ANIMA_ENABLE_WEBRTC}" == "1" ]]; then
  pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1 || true
  export SELKIES_PORT="${WEBRTC_PORT}"
  export SELKIES_ADDR="0.0.0.0"
  export SELKIES_WEB_ROOT
  export SELKIES_ENABLE_HTTPS="false"
  export SELKIES_ENABLE_BASIC_AUTH="true"
  export SELKIES_BASIC_AUTH_USER="${SELKIES_USER}"
  export SELKIES_BASIC_AUTH_PASSWORD="${VNC_PASSWORD}"
  export SELKIES_ENCODER
  export SELKIES_FRAMERATE
  export SELKIES_VIDEO_BITRATE
  export SELKIES_ENABLE_RESIZE="true"
  export SELKIES_ENABLE_CURSORS="true"
  export SELKIES_ENABLE_CLIPBOARD="true"
  export SELKIES_APP_WAIT_READY="false"
  selkies-gstreamer &
  CHILD_PIDS+=("$!")
  CHILD_NAMES+=("webrtc")
fi

if [[ "${#CHILD_PIDS[@]}" -eq 0 ]]; then
  echo "No desktop transport enabled." >&2
  exit 1
fi

while true; do
  alive_children=0
  for i in "${!CHILD_PIDS[@]}"; do
    pid="${CHILD_PIDS[$i]}"
    [[ -z "${pid}" ]] && continue
    if ! kill -0 "${pid}" >/dev/null 2>&1; then
      status=0
      wait "${pid}" || status=$?
      echo "[warn] desktop transport '${CHILD_NAMES[$i]}' exited with status ${status}" >&2
      CHILD_PIDS[$i]=""
      CHILD_NAMES[$i]=""
      continue
    fi
    alive_children=$((alive_children + 1))
  done
  if (( alive_children == 0 )); then
    echo "No desktop transports are still running." >&2
    exit 1
  fi
  sleep 1
done
