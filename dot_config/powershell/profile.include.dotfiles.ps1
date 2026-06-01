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

    # Auto-detect profiles from .dotfiles-include-* marker files
    $TargetProfiles = @('global')
    $markerFiles = Get-ChildItem -File -Path $Target -Filter '.dotfiles-include-*' -Force
    foreach ($marker in $markerFiles) {
        $profileName = $marker.Name -replace '^\.dotfiles-include-', ''
        if ($profileName) { $TargetProfiles += $profileName }
    }
    Write-Verbose "Target profiles: $($TargetProfiles -join ', ')"

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

    function Read-ProfileMap() {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Directory
        )

        $map = @{}
        $profileFiles = Get-ChildItem -File -Path $Directory -Filter '.dotfiles-profile-*' -Force
        foreach ($file in $profileFiles) {
            $profile = $file.Name -replace '^\.dotfiles-profile-', ''
            Get-Content -Path $file.FullName | ForEach-Object {
                $entry = $_.Trim()
                if ($entry) { $map[$entry] = $profile }
            }
        }
        return $map
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

        # Merge profile maps from both sides
        $profileMap = Read-ProfileMap -Directory $SyncSource
        $targetProfileMap = Read-ProfileMap -Directory $SyncDestination
        foreach ($key in $targetProfileMap.Keys) {
            if (-not $profileMap.ContainsKey($key)) {
                $profileMap[$key] = $targetProfileMap[$key]
            }
        }

        $ignoredDirectories = @( '.git' )

        # Sync .dotfiles-profile-* files only if target has that profile
        $sourceProfileFiles = Get-ChildItem -File -Path $SyncSource -Filter '.dotfiles-profile-*' -Force
        foreach ($file in $sourceProfileFiles) {
            $profile = $file.Name -replace '^\.dotfiles-profile-', ''
            if ($TargetProfiles -contains $profile) {
                Copy-Item -Path $file.FullName -Destination $SyncDestination -Force -Verbose:$VerbosePreference
            }
        }

        # Sync regular files
        $sourceFiles = Get-ChildItem -File -Path $SyncSource -Force | Where-Object {
            $_.Name -notmatch '^\.dotfiles-include-' -and $_.Name -notmatch '^\.dotfiles-profile-'
        }
        foreach ($file in $sourceFiles) {
            $assignedProfile = Get-Profile -Name $file.Name -ConfigProfileMap $profileMap
            if ([string]::IsNullOrWhiteSpace($assignedProfile) -or ($TargetProfiles -contains $assignedProfile)) {
                Copy-Item -Path $file.FullName -Destination $SyncDestination -Force -Verbose:$VerbosePreference
            } else {
                Write-Host "Skipping file '$($file.Name)' as it is not included in the profile"
            }
        }

        # Sync directories
        $sourceDirectories = Get-ChildItem -Directory -Path $SyncSource -Force
        foreach ($directory in $sourceDirectories) {
            if ($ignoredDirectories -contains $directory.Name) {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is ignored"
                continue
            }
            $assignedProfile = Get-Profile -Name $directory.Name -ConfigProfileMap $profileMap
            if (-not [string]::IsNullOrWhiteSpace($assignedProfile) -and $TargetProfiles -notcontains $assignedProfile) {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is not included in the profile"
                continue
            }
            $dstPath = Join-Path $SyncDestination $directory.Name
            Sync-Directory -SyncSource $directory.FullName -SyncDestination $dstPath -Verbose:$VerbosePreference
        }

        # Cleanup target files: only remove if source manages that profile
        $syncedSourceFileNames = @()
        foreach ($file in $sourceFiles) {
            $p = Get-Profile -Name $file.Name -ConfigProfileMap $profileMap
            if ([string]::IsNullOrWhiteSpace($p) -or ($TargetProfiles -contains $p)) {
                $syncedSourceFileNames += $file.Name
            }
        }

        $targetFiles = Get-ChildItem -File -Path $SyncDestination -Force | Where-Object {
            $_.Name -notmatch '^\.dotfiles-include-' -and $_.Name -notmatch '^\.dotfiles-profile-'
        }
        foreach ($file in $targetFiles) {
            $assignedProfile = Get-Profile -Name $file.Name -ConfigProfileMap $profileMap
            # Skip files whose profile isn't managed by source
            if (-not [string]::IsNullOrWhiteSpace($assignedProfile) -and $SourceProfiles -notcontains $assignedProfile) {
                continue
            }
            if ($syncedSourceFileNames -notcontains $file.Name) {
                Remove-Item -Path $file.FullName -Force -Verbose:$VerbosePreference
            }
        }

        # Cleanup target directories
        $syncedSourceDirNames = @()
        foreach ($dir in $sourceDirectories) {
            if ($ignoredDirectories -contains $dir.Name) { continue }
            $p = Get-Profile -Name $dir.Name -ConfigProfileMap $profileMap
            if ([string]::IsNullOrWhiteSpace($p) -or ($TargetProfiles -contains $p)) {
                $syncedSourceDirNames += $dir.Name
            }
        }

        $targetDirectories = Get-ChildItem -Directory -Path $SyncDestination -Force
        foreach ($directory in $targetDirectories) {
            if ($ignoredDirectories -contains $directory.Name) { continue }
            $assignedProfile = Get-Profile -Name $directory.Name -ConfigProfileMap $profileMap
            if (-not [string]::IsNullOrWhiteSpace($assignedProfile) -and $SourceProfiles -notcontains $assignedProfile) {
                continue
            }
            if ($syncedSourceDirNames -notcontains $directory.Name) {
                Remove-Item -Path $directory.FullName -Force -Recurse -Verbose:$VerbosePreference
            }
        }
    }

    Sync-Directory -SyncSource $Source -SyncDestination $Target -Verbose:$VerbosePreference
}
