$debugUrl = "http://127.0.0.1:9222"
try {
    Invoke-RestMethod "$debugUrl/json/version" -ErrorAction Stop | Out-Null
} catch {
    Start-Process "chrome.exe" -ArgumentList @(
        "--remote-debugging-port=9222",
        "--remote-debugging-address=127.0.0.1",
        "--remote-allow-origins=*",
        "--user-data-dir=$env:TEMP\chrome-remote-debug"
    )
    Start-Sleep 2
}

& pixi x --spec nodejs npx -y chrome-devtools-mcp@latest --browser-url=$debugUrl --no-usage-statistics
