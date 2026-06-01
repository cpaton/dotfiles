#!/bin/bash
if ! curl -s http://127.0.0.1:9222/json/version >/dev/null 2>&1; then
  systemctl --user start remote-chrome.service
  sleep 2
fi

exec pixi x --spec nodejs npx -y chrome-devtools-mcp@latest \
  --browser-url=http://127.0.0.1:9222 --no-usage-statistics
