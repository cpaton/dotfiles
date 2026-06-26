#!/usr/bin/env pwsh

<#
.SYNOPSIS
Bootstraps shell startup files for this dotfiles repo.
#>

[CmdletBinding()]
param(
    # Bash startup file to update when it already exists.
    [Parameter()]
    [string]
    $BashRcPath = ( Join-Path $HOME '.bashrc' )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$bashProfileSnippet = @'
if [ -f "$HOME/.config/bash/profile.bash" ]; then
    . "$HOME/.config/bash/profile.bash"
fi
'@

if (-not (Test-Path -Path $BashRcPath -PathType Leaf)) {
    Write-Host "Skipping bash bootstrap; file does not exist: $BashRcPath"
    return
}

$bashRcContent = Get-Content -Path $BashRcPath -Raw
if ($bashRcContent.Contains($bashProfileSnippet.Trim())) {
    Write-Host "Bash bootstrap already present in $BashRcPath"
    return
}

Add-Content -Path $BashRcPath -Value @(
    ''
    $bashProfileSnippet.TrimEnd()
)

Write-Host "Added bash bootstrap snippet to $BashRcPath"
