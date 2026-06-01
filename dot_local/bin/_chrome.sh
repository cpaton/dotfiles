#!/bin/bash
set -e

# Default port for noVNC
NOVNC_PORT=${1:-6080}

# Check and install dependencies
check_deps() {
    local missing=()
    command -v Xvfb >/dev/null || missing+=("xvfb")
    command -v x11vnc >/dev/null || missing+=("x11vnc")
    command -v websockify >/dev/null || missing+=("websockify")
    [ -f /usr/share/novnc/vnc.html ] || missing+=("novnc")
    command -v google-chrome >/dev/null || { install-chrome.sh; }
    command -v fluxbox >/dev/null || missing+=("fluxbox")
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing[*]}"
        echo "Installing..."
        sudo apt update
        sudo apt install -y xvfb x11vnc novnc websockify fluxbox
    fi
}

# Kill existing processes more thoroughly
cleanup() {
    echo "Stopping all processes..."
    # Kill Chrome processes first
    pkill -f "google-chrome.*remote-debugging-port=9222" 2>/dev/null || true
    pkill -f "chrome.*DISPLAY=:99" 2>/dev/null || true
    sleep 1
    
    # Kill window manager and VNC processes
    pkill -f "fluxbox.*DISPLAY=:99" 2>/dev/null || true
    pkill -f "Xvfb :99" 2>/dev/null || true
    pkill -f "x11vnc.*:99" 2>/dev/null || true
    pkill -f "websockify.*${NOVNC_PORT}" 2>/dev/null || true
    pkill -f "websockify.*6080" 2>/dev/null || true
    sleep 1
    echo "All processes stopped."
}

# Trap to cleanup on script exit
trap cleanup EXIT INT TERM

echo "Starting Chrome with noVNC on port ${NOVNC_PORT}..."
check_deps
cleanup

# Ensure index.html exists for subpath proxies (e.g. Coder)
[ ! -f /usr/share/novnc/index.html ] && sudo ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Start virtual display
echo "Starting Xvfb..."
Xvfb :99 -screen 0 1920x1080x24 &
XVFB_PID=$!
sleep 2

# Start Fluxbox window manager
echo "Starting Fluxbox..."
DISPLAY=:99 fluxbox &
FLUXBOX_PID=$!
sleep 2

# Start VNC server
echo "Starting x11vnc..."
x11vnc -display :99 -nopw -listen localhost -xkb -forever &
X11VNC_PID=$!
sleep 2

# Start websockify with noVNC on specified port
echo "Starting websockify on port ${NOVNC_PORT}..."
websockify --web=/usr/share/novnc/ ${NOVNC_PORT} localhost:5900 &
WEBSOCKIFY_PID=$!
sleep 2

# Start Chrome with better options for headless environment
echo "Starting Chrome..."
DISPLAY=:99 google-chrome \
    --remote-debugging-port=9222 \
    --remote-debugging-address=0.0.0.0 \
    --remote-allow-origins=* \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI,VizDisplayCompositor \
    --disable-ipc-flooding-protection \
    --disable-extensions \
    --disable-plugins \
    --disable-infobars \
    --user-data-dir=/tmp/chrome-remote-debug \
    --ignore-certificate-errors-spki-list \
    --ignore-certificate-errors \
    --ignore-ssl-errors \
    --allow-running-insecure-content \
    --disable-web-security \
    --test-type &

CHROME_PID=$!
sleep 3

echo ""
echo "🚀 Chrome started successfully!"
echo "📱 Access via noVNC: http://localhost:${NOVNC_PORT}/vnc.html?autoconnect=true&reconnect=true&reconnect_delay=2000"
echo "🔧 Remote debugging: http://localhost:9222 (accessible from any IP)"
echo ""
echo "Press Ctrl+C to stop all processes and exit"
echo ""

# Wait for Chrome to exit or for user to interrupt
wait $CHROME_PID

