function Sync-DotFiles()
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]
        $Source,
        [Parameter(Mandatory)]
        [string]
        $Target,
        [Parameter()]
        [string[]]
        $Profiles = @('global')
    )

    $ErrorActionPreference = "Stop"

    if (-not (Test-Path -Path $Source))
    {
        throw "Source path '$Source' does not exist."
    }
    if (-not (Test-Path -Path $Target))
    {
        throw "Target path '$Target' does not exist."
    }

    function Get-Profile()
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Name
        )

        $profileRegex = "^.+__(?<profile>[^\.]+)(\.|$)"
        $profileMatch = [regex]::Match($Name, $profileRegex)
        if ($profileMatch.Success)
        {
            return $profileMatch.Groups["profile"].Value
        }
        return $null
    }

    function Should-Sync()
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]
            $Name
        )

        $assignedProfile = Get-Profile -Name $Name
        if ([string]::IsNullOrWhiteSpace($assignedProfile))
        {
            return $true
        }
        $includedProfile = $Profiles -contains $assignedProfile
        return $includedProfile
    }

    function Sync-Directory()
    {
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory)]
            [string]
            $SyncSource,
            [Parameter(Mandatory)]
            [string]
            $SyncDestination
        )

        if (-not (Test-Path -Path $SyncDestination))
        {
            New-Item -ItemType Directory -Path $SyncDestination -Verbose:$VerbosePreference | Out-Null
        }

        $sourceFiles = Get-ChildItem -File -Path $SyncSource -Force
        $sourceFileNames = $sourceFiles.Name
        foreach ($file in $sourceFiles)
        {
            if (-not (Should-Sync -Name $file.Name))
            {
                Write-Host "Skipping file '$($file.Name)' as it is not included in the profile"
                continue
            }
            Copy-Item -Path $file.FullName -Destination $SyncDestination -Force -Verbose:$VerbosePreference
        }

        $ignoredDirectories = @( ".git" )

        $sourceDirectories = Get-ChildItem -Directory -Path $SyncSource -Force
        $sourceDirectoryNames = $sourceDirectories.Name
        foreach ($directory in $sourceDirectories)
        {
            if ($ignoredDirectories -contains $directory.Name)
            {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is ignored"
                continue
            }

            if (-not (Should-Sync -Name $directory.Name))
            {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is not included in the profile"
                continue
            }

            $dstPath = Join-Path $SyncDestination $directory.Name
            Sync-Directory -SyncSource $directory.FullName -SyncDestination $dstPath -Verbose:$VerbosePreference
        }

        $targetFileNames = ( Get-ChildItem -File -Path $SyncDestination -Force ).Name
        $filesToRemove = $targetFileNames | Where-Object { $sourceFileNames -notcontains $_ -and ( Should-Sync -Name $_ )}
        foreach ($file in $filesToRemove)
        {
            Remove-Item -Path (Join-Path $SyncDestination $file) -Force -Verbose:$VerbosePreference
        }

        $targetDirectoryNames = ( Get-ChildItem -Directory -Path $SyncDestination -Force ).Name
        $directoriesToRemove = $targetDirectoryNames | Where-Object { $sourceDirectoryNames -notcontains $_ }
        foreach ($directory in $directoriesToRemove)
        {
            if ($ignoredDirectories -contains $directory.Name)
            {
                Write-Verbose "Skipping directory '$($directory.Name)' as it is ignored"
                continue
            }

            Remove-Item -Path (Join-Path $SyncDestination $directory) -Force -Recurse -Verbose:$VerbosePreference
        }
    }

    Sync-Directory -SyncSource $Source -SyncDestination $Target -Verbose:$VerbosePreference
}
