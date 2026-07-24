#!/usr/bin/env pwsh

<#
.SYNOPSIS
Installs chezmoi through mise and configures it for this dotfiles repo.
#>

[CmdletBinding()]
param(
    # Version of chezmoi to install.
    [Parameter()]
    [string]
    $ChezmoiVersion = '2.65.1',

    # Path to the mise binary installed by 01-mise.ps1.
    [Parameter()]
    [string]
    $MisePath = ( Join-Path $HOME '.local/bin/mise' )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

if (-not (Test-Path -Path $MisePath -PathType Leaf)) {
    # Try finding mise on PATH (e.g. Windows/Scoop install)
    $miseCommand = Get-Command -Name 'mise' -ErrorAction SilentlyContinue
    if ($null -eq $miseCommand) {
        throw "mise not found at $MisePath or on PATH. Run 01-mise.ps1 first."
    }
    $MisePath = $miseCommand.Source
}

Write-Host "Installing chezmoi $ChezmoiVersion via mise..."
& $MisePath install "chezmoi@$ChezmoiVersion"
& $MisePath use --global "chezmoi@$ChezmoiVersion"

$chezmoiPath = (& $MisePath which chezmoi)
if (-not $chezmoiPath -or -not (Test-Path -Path $chezmoiPath -PathType Leaf)) {
    throw "chezmoi binary not found after mise install."
}

Write-Host "chezmoi installed at: $chezmoiPath"

& (Join-Path $PSScriptRoot '../chezmoi-config.ps1') -ChezmoiPath $chezmoiPath
