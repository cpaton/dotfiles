#!/usr/bin/env pwsh

<#
.SYNOPSIS
Downloads the latest mise binary release for the current Linux/macOS platform
and installs it into the user's local bin directory.
#>

[CmdletBinding()]
param(
    # Path where the mise binary should be placed.
    [Parameter()]
    [string]
    $BinDir = ( Join-Path $HOME '.local/bin' )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

function Get-MisePlatform {
    [CmdletBinding()]
    param()

    if ($IsLinux) { return 'linux' }
    if ($IsMacOS) { return 'macos' }

    throw 'Unsupported OS. This script supports Linux and macOS only.'
}

function Get-MiseArchitecture {
    [CmdletBinding()]
    param()

    switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
        'X64'   { return 'x64' }
        'Arm64' { return 'arm64' }
        default { throw "Unsupported architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" }
    }
}

function Install-Mise {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $InstallDirectory
    )

    $os = Get-MisePlatform
    $arch = Get-MiseArchitecture

    Write-Host "Resolving latest mise release for $os-$arch..."

    $releaseApiUrl = 'https://api.github.com/repos/jdx/mise/releases/latest'
    $release = Invoke-RestMethod -Uri $releaseApiUrl

    # Mise release assets follow pattern: mise-<version>-<os>-<arch>
    $assetPattern = "mise-*-$os-$arch"
    # Prefer the bare binary over tarball
    $asset = $release.assets |
        Where-Object { $_.name -like $assetPattern -and $_.name -notlike '*.tar.*' -and $_.name -notlike '*.sig' -and $_.name -notlike '*.sha*' } |
        Select-Object -First 1

    if ($null -eq $asset) {
        # Fall back to tarball
        $asset = $release.assets |
            Where-Object { $_.name -like "$assetPattern.tar.gz" } |
            Select-Object -First 1
    }

    if ($null -eq $asset) {
        throw "Could not find mise release asset matching $assetPattern for release $($release.tag_name)"
    }

    $temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $temporaryDirectory -Force | Out-Null

    try {
        $downloadPath = Join-Path $temporaryDirectory $asset.name
        Write-Host "Downloading $($asset.browser_download_url)..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath

        New-Item -ItemType Directory -Path $InstallDirectory -Force | Out-Null
        $destination = Join-Path $InstallDirectory 'mise'

        if ($asset.name -like '*.tar.gz') {
            tar -xzf $downloadPath -C $temporaryDirectory
            $miseBinary = Get-ChildItem -Path $temporaryDirectory -Recurse -File -Filter 'mise' |
                Where-Object { $_.FullName -ne $downloadPath } |
                Select-Object -First 1
            if ($null -eq $miseBinary) {
                throw 'Downloaded archive did not contain a mise binary.'
            }
            Copy-Item -Path $miseBinary.FullName -Destination $destination -Force
        }
        else {
            Copy-Item -Path $downloadPath -Destination $destination -Force
        }

        if (Get-Command -Name 'chmod' -ErrorAction SilentlyContinue) {
            chmod 0755 $destination
        }

        Write-Host "Installed mise to $destination"
        & $destination version
    }
    finally {
        Remove-Item -Path $temporaryDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Add-BinDirectoryToPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Directory
    )

    New-Item -ItemType Directory -Path $Directory -Force | Out-Null

    $pathEntries = ($env:PATH ?? '') -split [System.IO.Path]::PathSeparator
    if ($pathEntries -contains $Directory) {
        return
    }

    $env:PATH = "$($Directory)$([System.IO.Path]::PathSeparator)$($env:PATH)"
}

# --- Main ---

Install-Mise -InstallDirectory $BinDir
Add-BinDirectoryToPath -Directory $BinDir
