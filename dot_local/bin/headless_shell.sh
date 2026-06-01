#!/bin/bash
export DISPLAY=${DISPLAY:-:99}
exec /usr/bin/google-chrome --no-sandbox --disable-setuid-sandbox --disable-gpu --disable-dev-shm-usage "$@"

