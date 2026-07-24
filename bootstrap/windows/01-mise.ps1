#!/usr/bin/env pwsh

<#
.SYNOPSIS
Installs mise on Windows via Scoop.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
    throw 'Scoop is not installed. Install it first: https://scoop.sh'
}

$installed = scoop list mise 2>&1
if ($LASTEXITCODE -eq 0 -and ($installed | Select-String 'mise')) {
    Write-Host 'mise is already installed via Scoop, updating...'
    scoop update mise
}
else {
    Write-Host 'Installing mise via Scoop...'
    scoop install mise
}

$misePath = (Get-Command -Name 'mise' -ErrorAction SilentlyContinue).Source
if (-not $misePath) {
    throw 'mise was not found on PATH after Scoop installation.'
}

Write-Host "mise installed at: $misePath"
& mise version
