function Sync-DotFiles() {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]
        $Source,
        [Parameter(Mandatory)]
        [string]
        $Target
    )

    $ErrorActionPreference = 'Stop'

    if (-not (Test-Path -Path $Source)) {
        throw "Source path '$Source' does not exist."
    }
    if (-not (Test-Path -Path $Target)) {
        throw "Target path '$Target' does not exist."
    }

    # Auto-detect profiles from .dotfiles-include-* marker files in target root
    $TargetProfiles = @('global')
    $markerFiles = Get-ChildItem -File -Path $Target -Filter '.dotfiles-include-*' -Force
    foreach ($marker in $markerFiles) {
        $profileName = $marker.Name -replace '^\.dotfiles-include-', ''
        if ($profileName) { $TargetProfiles += $profileName }
    }
    Write-Verbose "Target profiles: $($TargetProfiles -join ', ')"

    # Auto-detect profiles from .dotfiles-include-* marker files in source root
    $SourceProfiles = @('global')
    $markerFiles = Get-ChildItem -File -Path $Source -Filter '.dotfiles-include-*' -Force
    foreach ($marker in $markerFiles) {
        $profileName = $marker.Name -replace '^\.dotfiles-include-', ''
        if ($profileName) { $SourceProfiles += $profileName }
    }
    Write-Verbose "Source profiles: $($SourceProfiles -join ', ')"

    function Get-Profile() {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Name,
            [Parameter()]
            [hashtable]
            $ConfigProfileMap = @{}
        )

        $profileRegex = '^.+__(?<profile>[^\.]+)(\.|$)'
        $profileMatch = [regex]::Match($Name, $profileRegex)
        if ($profileMatch.Success) {
            return $profileMatch.Groups['profile'].Value
        }
        if ($ConfigProfileMap.ContainsKey($Name)) {
            return $ConfigProfileMap[$Name]
        }
        return $null
    }

    function Read-DotfilesProfileConfig() {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Directory
        )

        $configPath = Join-Path $Directory '.dotfiles-profile'
        $map = @{}
        if (Test-Path -Path $configPath) {
            Get-Content -Path $configPath | ForEach-Object {
                $line = $_.Trim()
                if ($line -and $line -match '^(?<name>.+):(?<profile>.+)$') {
                    $map[$Matches['name'].Trim()] = $Matches['profile'].Trim()
                }
            }
        }
        return $map
    }

    function Should-Sync() {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Name,
            [Parameter()]
            [hashtable]
            $ConfigProfileMap = @{}
        )

        $assignedProfile = Get-Profile -Name $Name -ConfigProfileMap $ConfigProfileMap
        if ([string]::IsNullOrWhiteSpace($assignedProfile)) {
            return $true
        }
        return $TargetProfiles -contains $assignedProfile
    }

    function Is-SourceManaged() {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Name,
            [Parameter()]
            [hashtable]
            $ConfigProfileMap = @{}
        )

        $assignedProfile = Get-Profile -Name $Name -ConfigProfileMap $ConfigProfileMap
        if ([string]::IsNullOrWhiteSpace($assignedProfile)) {
            return $true
        }
        return $SourceProfiles -contains $assignedProfile
    }

    function Sync-Directory() {
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory)]
            [string]
            $SyncSource,
            [Parameter(Mandatory)]
            [string]
            $SyncDestination
        )

        if (-not (Test-Path -Path $SyncDestination)) {
            New-Item -ItemType Directory -Path $SyncDestination -Verbose:$VerbosePreference | Out-Null
        }

        $profileMap = Read-DotfilesProfileConfig -Directory $SyncSource
        $ignoredFiles = @( '.dotfiles-profile' )
        $ignoredDirectories = @( '.git' )

        # Sync files
        $sourceFiles = Get-ChildItem -File -Path $SyncSource -Force | Where-Object {
            $ignoredFiles -notcontains $_.Name -and $_.Name -notmatch '^\.dotfiles-include-'
        }
        foreach ($file in $sourceFiles) {
            if (-not (Should-Sync -Name $file.Name -ConfigProfileMap $profileMap)) {
                Write-Host "Skipping file '$($file.Name)' as it is not included in the profile"
                continue
            }
            Copy-Item -Path $file.FullName -Destination $SyncDestination -Force -Verbose:$VerbosePreference
        }

        # Sync directories
        $sourceDirectories = Get-ChildItem -Directory -Path $SyncSource -Force
        foreach ($directory in $sourceDirectories) {
            if ($ignoredDirectories -contains $directory.Name) {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is ignored"
                continue
            }
            if (-not (Should-Sync -Name $directory.Name -ConfigProfileMap $profileMap)) {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is not included in the profile"
                continue
            }
            $dstPath = Join-Path $SyncDestination $directory.Name
            Sync-Directory -SyncSource $directory.FullName -SyncDestination $dstPath -Verbose:$VerbosePreference
        }

        # Cleanup target: only remove files whose profile is managed by source.
        # If source doesn't manage the profile, leave the file alone.
        $syncedSourceFileNames = @($sourceFiles | Where-Object { Should-Sync -Name $_.Name -ConfigProfileMap $profileMap } | ForEach-Object { $_.Name })
        $targetFiles = Get-ChildItem -File -Path $SyncDestination -Force | Where-Object { $_.Name -notmatch '^\.dotfiles-include-' }
        foreach ($file in $targetFiles) {
            if (-not (Is-SourceManaged -Name $file.Name -ConfigProfileMap $profileMap)) {
                continue
            }
            if (-not (Should-Sync -Name $file.Name -ConfigProfileMap $profileMap)) {
                Remove-Item -Path $file.FullName -Force -Verbose:$VerbosePreference
            } elseif ($syncedSourceFileNames -notcontains $file.Name) {
                Remove-Item -Path $file.FullName -Force -Verbose:$VerbosePreference
            }
        }

        # Cleanup target directories
        $syncedSourceDirNames = @($sourceDirectories | Where-Object {
            $ignoredDirectories -notcontains $_.Name -and (Should-Sync -Name $_.Name -ConfigProfileMap $profileMap)
        } | ForEach-Object { $_.Name })
        $targetDirectories = Get-ChildItem -Directory -Path $SyncDestination -Force
        foreach ($directory in $targetDirectories) {
            if ($ignoredDirectories -contains $directory.Name) { continue }
            if (-not (Is-SourceManaged -Name $directory.Name -ConfigProfileMap $profileMap)) {
                continue
            }
            if (-not (Should-Sync -Name $directory.Name -ConfigProfileMap $profileMap)) {
                Remove-Item -Path $directory.FullName -Force -Recurse -Verbose:$VerbosePreference
            } elseif ($syncedSourceDirNames -notcontains $directory.Name) {
                Remove-Item -Path $directory.FullName -Force -Recurse -Verbose:$VerbosePreference
            }
        }
    }

    Sync-Directory -SyncSource $Source -SyncDestination $Target -Verbose:$VerbosePreference
}
