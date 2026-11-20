<#
.SYNOPSIS
    Clone a GitLab repo mirroring the remote group structure under the local git root.
.EXAMPLE
    glabco git@scm.tpicapcloud.com:fusion/rates/fusion-rates-message-lib-mcp.git
    # Clones to ~/git/fusion/rates/fusion-rates-message-lib-mcp and cd's into it
#>
function Invoke-GitLabClone {
    [CmdletBinding()]
    param(
        # SSH or HTTPS clone URL, e.g. git@scm.tpicapcloud.com:fusion/rates/repo.git
        [Parameter(Mandatory, Position = 0)]
        [string]$CloneUrl
    )

    $gitRoot = $MachineConfiguration.GitRoot
    if (-not $gitRoot) {
        throw 'MachineConfiguration.GitRoot is not set.'
    }

    # Extract the path portion from the URL
    # SSH:   git@host:group/subgroup/repo.git  -> group/subgroup/repo.git
    # HTTPS: https://host/group/subgroup/repo.git -> group/subgroup/repo.git
    if ($CloneUrl -match '^git@[^:]+:(.+)$') {
        $repoPath = $Matches[1]
    }
    elseif ($CloneUrl -match '^https?://[^/]+/(.+)$') {
        $repoPath = $Matches[1]
    }
    else {
        throw "Unrecognised clone URL format: $CloneUrl"
    }

    # Strip trailing .git
    $repoPath = $repoPath -replace '\.git$', ''

    # Split into parent directory structure and repo name
    $parentPath = Split-Path $repoPath -Parent
    $targetDir = Join-Path $gitRoot $repoPath

    if (Test-Path $targetDir) {
        Write-Host "Directory already exists, changing to: $targetDir"
        Set-Location $targetDir
        return
    }

    # Ensure the parent group directory exists
    $parentDir = Join-Path $gitRoot $parentPath
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # Clone into the parent directory (git creates the repo folder)
    git clone $CloneUrl --recurse-submodules $targetDir
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed with exit code $LASTEXITCODE"
    }

    Set-Location $targetDir
}

New-Alias -Name glabco -Value Invoke-GitLabClone -Force

<#
.SYNOPSIS
    Export a GitLab project's CI/CD variables (including inherited group variables) to a .env file.
.DESCRIPTION
    Collects CI/CD variables from the current project and all ancestor groups,
    merging them with GitLab's precedence: project > child group > parent group.
    Hidden variables (value not readable via API) and file-type variables are skipped.
.EXAMPLE
    glabenv
    # Writes all CI/CD variables to .env.local in the current directory
.EXAMPLE
    Export-GitLabCIVariables -OutputPath .env.ci -EnvironmentScope production
    # Writes production-scoped variables to .env.ci
#>
function Export-GitLabCIVariables {
    [CmdletBinding()]
    param(
        # Output file path (default: .env.local in the git repo root)
        [Parameter(Position = 0)]
        [string]$OutputPath,

        # Filter to a specific environment scope (default: all scopes, '*' matches everything)
        [string]$EnvironmentScope,

        # Exclude protected variables (they are included by default)
        [switch]$ExcludeProtected
    )

    # Resolve the git repo root for the default output path
    $repoRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'Not inside a Git repository.'
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path $repoRoot '.env.local'
    }

    # Get the project metadata (namespace kind + group hierarchy)
    $projectJson = glab api 'projects/:id' 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to query GitLab project: $projectJson"
    }
    $project = $projectJson | ConvertFrom-Json

    Write-Host "Project: $($project.path_with_namespace) (id: $($project.id))" -ForegroundColor Cyan

    # Collect variables from each level, ordered from most-specific (project) to least (root group)
    # Each entry: @{ Source = 'project|group:path'; Variables = @[...] }
    $levels = [System.Collections.Generic.List[hashtable]]::new()

    # 1. Project-level variables
    $projVarsJson = glab api "projects/$($project.id)/variables" --paginate 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to query project variables: $projVarsJson"
    }
    $projVars = $projVarsJson | ConvertFrom-Json
    $levels.Add(@{ Source = "project:$($project.path_with_namespace)"; Variables = $projVars })
    Write-Host "  Project variables: $($projVars.Count)" -ForegroundColor DarkGray

    # 2. Walk up the group hierarchy if the project is under a group (not a user namespace)
    if ($project.namespace.kind -eq 'group') {
        $groupId = $project.namespace.id
        while ($groupId) {
            $groupJson = glab api "groups/$groupId" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to query group $groupId — skipping ancestor groups."
                break
            }
            $group = $groupJson | ConvertFrom-Json

            $groupVarsJson = glab api "groups/$groupId/variables" --paginate 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to query variables for group '$($group.full_path)' — skipping."
                $groupId = $group.parent_id
                continue
            }
            $groupVars = $groupVarsJson | ConvertFrom-Json
            $levels.Add(@{ Source = "group:$($group.full_path)"; Variables = $groupVars })
            Write-Host "  Group '$($group.full_path)' variables: $($groupVars.Count)" -ForegroundColor DarkGray

            $groupId = $group.parent_id
        }
    }
    else {
        Write-Host '  Project is under a user namespace — no group variables to inherit.' -ForegroundColor DarkGray
    }

    # Merge: first writer wins (project overrides child group overrides parent group)
    $merged = [ordered]@{}
    # Track source for verbose output
    $sources = @{}

    foreach ($level in $levels) {
        foreach ($var in $level.Variables) {
            # Skip file-type variables (they reference file paths, not env values)
            if ($var.variable_type -eq 'env_var' -and -not $var.hidden) {
                # Environment scope filter
                if ($EnvironmentScope) {
                    # Match exact scope or wildcard '*'
                    if ($var.environment_scope -ne '*' -and $var.environment_scope -ne $EnvironmentScope) {
                        continue
                    }
                }

                # Skip protected variables if excluded
                if ($var.protected -and $ExcludeProtected) {
                    continue
                }

                # First writer wins (most specific level)
                if (-not $merged.Contains($var.key)) {
                    $merged[$var.key] = $var.value
                    $sources[$var.key] = $level.Source
                }
            }
        }
    }

    if ($merged.Count -eq 0) {
        Write-Host 'No variables found.' -ForegroundColor Yellow
        return
    }

    # Write the .env file
    $lines = [System.Collections.Generic.List[string]]::new()

    foreach ($key in $merged.Keys) {
        # Quote values that contain spaces, newlines or special shell characters
        $value = $merged[$key]
        if ($value -match '[\s"''\\$`#!]' -or $value -eq '') {
            # Escape existing double quotes and backslashes, then wrap
            $escaped = $value -replace '\\', '\\' -replace '"', '\"'
            $lines.Add("${key}=`"$escaped`"")
        }
        else {
            $lines.Add("${key}=$value")
        }
    }

    # Ensure trailing newline
    $lines.Add('')
    [System.IO.File]::WriteAllText($OutputPath, ($lines -join "`n"))

    Write-Host "`nWrote $($merged.Count) variables to $OutputPath" -ForegroundColor Green

    # Show provenance summary
    $bySource = $sources.Values | Group-Object | Sort-Object Name
    foreach ($g in $bySource) {
        Write-Host "  $($g.Name): $($g.Count) vars" -ForegroundColor DarkGray
    }
}

New-Alias -Name glabenv -Value Export-GitLabCIVariables -Force
