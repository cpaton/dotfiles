#!/usr/bin/env pwsh

<#
.SYNOPSIS
Downloads the latest asdf binary release for the current Linux/macOS platform,
installs it into the user's local bin directory, and ensures that directory is
available on PATH for future PowerShell sessions.
#>

[CmdletBinding()]
param(
    # URL where releases can be found
    [Parameter()]
    [string]
    $AsdfReleaseApiUrl = ( 'https://api.github.com/repos/asdf-vm/asdf/releases/latest' ),
    # Path where binary should be placed
    [Parameter()]
    [string]
    $BinDir = ( Join-Path $HOME '.local/bin' )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

function Get-AsdfPlatform {
    [CmdletBinding()]
    param()

    if ($IsLinux) {
        'linux'
        return
    }

    if ($IsMacOS) {
        'darwin'
        return
    }

    throw 'Unsupported OS. asdf binary releases are available for Linux and macOS.'
}

function Get-AsdfArchitecture {
    [CmdletBinding()]
    param()

    switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
        'X64' { 'amd64'; return }
        'Arm64' { 'arm64'; return }
        'X86' { '386'; return }
        default { throw "Unsupported architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" }
    }
}

function Assert-CommandExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    if (-not (Get-Command -Name $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

function Install-Asdf {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $ReleaseApiUrl,

        [Parameter(Mandatory)]
        [string]
        $InstallDirectory
    )

    Assert-CommandExists -Name 'tar'

    $os = Get-AsdfPlatform
    $architecture = Get-AsdfArchitecture

    Write-Host "Resolving latest asdf release for $os-$architecture..."
    $release = Invoke-RestMethod -Uri $ReleaseApiUrl
    $assetPattern = "asdf-v*-$os-$architecture.tar.gz"
    $asset = $release.assets | Where-Object { $_.name -like $assetPattern } | Select-Object -First 1

    if ($null -eq $asset) {
        throw "Could not find asdf release asset matching $assetPattern"
    }

    $temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $temporaryDirectory -Force | Out-Null

    try {
        $archivePath = Join-Path $temporaryDirectory 'asdf.tar.gz'

        Write-Host "Downloading $($asset.browser_download_url)..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archivePath

        tar -xzf $archivePath -C $temporaryDirectory

        $asdfBinary = Get-ChildItem -Path $temporaryDirectory -Recurse -File -Filter 'asdf' | Select-Object -First 1
        if ($null -eq $asdfBinary) {
            throw 'Downloaded archive did not contain an asdf binary.'
        }

        New-Item -ItemType Directory -Path $InstallDirectory -Force | Out-Null

        $destination = Join-Path $InstallDirectory 'asdf'
        Copy-Item -Path $asdfBinary.FullName -Destination $destination -Force

        if (Get-Command -Name 'chmod' -ErrorAction SilentlyContinue) {
            chmod 0755 $destination
        }

        Write-Host "Installed asdf to $destination"
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

    $pathEntries = ( $env:PATH ?? '' ) -split [System.IO.Path]::PathSeparator
    if ($pathEntries -contains $Directory) {
        return
    }

    $env:PATH = "$($Directory)$([System.IO.Path]::PathSeparator)$($env:PATH)"
}

Install-Asdf -ReleaseApiUrl $AsdfReleaseApiUrl -InstallDirectory $BinDir
Add-BinDirectoryToPath -Directory $BinDir
