#!/bin/bash
set -e

DISPLAY_NUM=${DISPLAY_NUM:-99}
export DISPLAY=:${DISPLAY_NUM}
DEBUG_PORT=${DEBUG_PORT:-9222}

exec google-chrome \
    --remote-debugging-port=${DEBUG_PORT} \
    --remote-debugging-address=127.0.0.1 \
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
    --ignore-certificate-errors \
    --ignore-ssl-errors \
    --allow-running-insecure-content \
    --disable-web-security \
    --test-type
