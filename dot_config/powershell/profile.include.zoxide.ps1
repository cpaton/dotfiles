. __ProfileCachedInitialization "zoxide" {
    if ($null -ne (Get-Command zoxide -ErrorAction SilentlyContinue)) {
        zoxide init powershell | Out-String
    }
}
