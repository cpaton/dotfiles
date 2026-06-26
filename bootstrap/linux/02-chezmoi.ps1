#!/usr/bin/env pwsh

<#
.SYNOPSIS
Installs chezmoi through asdf using the version pinned in dot_tool-versions.
#>

[CmdletBinding()]
param(
    # Path to the asdf .tool-versions source file in this dotfiles repo.
    [Parameter()]
    [string]
    $ToolVersionsPath = ( Join-Path $PSScriptRoot '../../dot_tool-versions' ),

    # Path to the asdf binary installed by bootstrap-asdf.ps1.
    [Parameter()]
    [string]
    $AsdfPath = ( Join-Path $HOME '.local/bin/asdf' )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

function Assert-FileExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "Required file not found: $Path"
    }
}

function Get-ToolVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [string]
        $ToolName
    )

    if (-not (Test-Path -Path $Path)) {
        throw "Tool versions file not found: $Path"
    }

    $escapedToolName = [regex]::Escape($ToolName)
    $match = Get-Content -Path $Path |
        Where-Object { $_ -match "^\s*$escapedToolName\s+(?<version>\S+)" } |
        Select-Object -First 1

    if ($null -eq $match) {
        throw "Could not find $ToolName version in $Path"
    }

    if ($match -notmatch "^\s*$escapedToolName\s+(?<version>\S+)") {
        throw "Could not parse $ToolName version from: $match"
    }

    $Matches.version
}

Assert-FileExists -Path $AsdfPath

$chezmoiVersion = Get-ToolVersion -Path $ToolVersionsPath -ToolName 'chezmoi'

$plugins = @(& $AsdfPath plugin list)
if ($plugins -notcontains 'chezmoi') {
    & $AsdfPath plugin add chezmoi
}

& $AsdfPath install chezmoi $chezmoiVersion
& $AsdfPath set --home chezmoi $chezmoiVersion

$chezmoiInstallDirectory = & $AsdfPath where chezmoi $chezmoiVersion
$chezmoiBinaryName = 'chezmoi'
$chezmoiPath = Join-Path $chezmoiInstallDirectory "bin/$chezmoiBinaryName"
if (-not (Test-Path -Path $chezmoiPath -PathType Leaf)) {
    $chezmoiPath = Join-Path $chezmoiInstallDirectory $chezmoiBinaryName
}

& (Join-Path $PSScriptRoot '../chezmoi-config.ps1') -ChezmoiPath $chezmoiPath

