#!/bin/bash
set -e

NOVNC_PORT=${NOVNC_PORT:-6080}
DISPLAY_NUM=${DISPLAY_NUM:-99}
export DISPLAY=:${DISPLAY_NUM}

cleanup() {
    pkill -f "fluxbox.*DISPLAY=:${DISPLAY_NUM}" 2>/dev/null || true
    pkill -f "x11vnc.*:${DISPLAY_NUM}" 2>/dev/null || true
    pkill -f "websockify.*${NOVNC_PORT}" 2>/dev/null || true
    pkill -f "Xvfb :${DISPLAY_NUM}" 2>/dev/null || true
}

trap cleanup EXIT INT TERM
cleanup

# 1. Virtual display
Xvfb :${DISPLAY_NUM} -screen 0 1920x1080x24 &
sleep 1

# 2. Window manager
fluxbox &
sleep 1

# 3. VNC server
x11vnc -display :${DISPLAY_NUM} -nopw -listen localhost -xkb -forever &
sleep 1

# 4. websockify + noVNC
websockify --web=/usr/share/novnc/ ${NOVNC_PORT} localhost:5900 &

echo "VNC stack running — noVNC on port ${NOVNC_PORT}"
wait
