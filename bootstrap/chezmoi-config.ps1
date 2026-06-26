#!/usr/bin/env pwsh

<#
.SYNOPSIS
Creates ~/.config/chezmoi/chezmoi.yaml from bootstrap/chezmoi.yaml, prompting for placeholders.
#>

[CmdletBinding()]
param(
    # Path to the template config containing __placeholder__ values.
    [Parameter()]
    [string]
    $TemplatePath = ( Join-Path $PSScriptRoot 'chezmoi.yaml' ),
    # Destination path for the rendered chezmoi config.
    [Parameter()]
    [string]
    $OutputPath = ( Join-Path ( $env:XDG_CONFIG_HOME ?? ( Join-Path $HOME '.config' ) ) 'chezmoi/chezmoi.yaml' ),
    # Path to the chezmoi executable to show in the final init command.
    [Parameter()]
    [string]
    $ChezmoiPath = 'chezmoi'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PlaceholderDefault {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    switch ($Name) {
        'source-dir' { (Resolve-Path (Join-Path $PSScriptRoot '..')).Path; return }
        default { ''; return }
    }
}

function Read-PlaceholderValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    $defaultValue = Get-PlaceholderDefault -Name $Name
    if ([string]::IsNullOrWhiteSpace($defaultValue)) {
        return Read-Host "Enter configuration value for $Name"
    }

    $value = Read-Host "Enter configuration value for $Name [$defaultValue]"
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $defaultValue
    }

    $value
}

if (-not (Test-Path -Path $TemplatePath -PathType Leaf)) {
    throw "Template not found: $TemplatePath"
}

$template = Get-Content -Path $TemplatePath -Raw
$placeholderMatches = [regex]::Matches($template, '__([A-Za-z0-9_-]+)__')
$placeholderNames = $placeholderMatches |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

$rendered = $template
foreach ($placeholderName in $placeholderNames) {
    $value = Read-PlaceholderValue -Name $placeholderName
    $rendered = $rendered.Replace("__$($placeholderName)__", $value)
}

$outputDirectory = Split-Path -Path $OutputPath -Parent
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
Set-Content -Path $OutputPath -Value $rendered -NoNewline

Write-Host "Created chezmoi config at $OutputPath"
Write-Host ''
Write-Host 'Resultant config:'
Write-Host '-----------------'
Get-Content -Path $OutputPath | ForEach-Object { Write-Host $_ }
Write-Host '-----------------'
Write-Host ''
Write-Host 'To initialise chezmoi with this config, run:'
Write-Host "  & '$ChezmoiPath' apply --verbose"
