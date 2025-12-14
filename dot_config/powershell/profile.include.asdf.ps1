function Get-AsdfPlugins
{
    [CmdletBinding()]
    param()

    $ErrorActionPreference = "Stop"
    $PSNativeCommandUseErrorActionPreference = $true

    $asdfOutput = asdf plugin list --refs --urls

    # asdf plugin output with urls ends up on two lines (looking up remote ends with a newline)
    # so we need to join every two lines together to get the full plugin info
    $plugins = @()
    for ($i = 0; $i -lt $asdfOutput.Length; $i += 2)
    {
        $pluginNameAndUrlLine = $asdfOutput[$i]
        $pluginRefLine = $asdfOutput[$i+1]

        $nameAndUrlMatch = ([regex]"^(?<pluginName>[^\s]+)\s+(?<url>[^\s]+)$").Match($pluginNameAndUrlLine)
        $refMatch = ([regex]"^\s+(?<ref>[^\s]+)").Match($pluginRefLine)

        if (-not $nameAndUrlMatch.Success)
        {
            Write-Warning "Failed to parse plugin name and url from line: $pluginNameAndUrlLine"
            break
        }

        if (-not $refMatch.Success)
        {
            Write-Warning "Failed to parse plugin ref from line: $pluginRefLine"
            break
        }

        $plugins += [pscustomobject][ordered]@{
            Name = $nameAndUrlMatch.Groups["pluginName"].Value
            Url = $nameAndUrlMatch.Groups["url"].Value
            Ref = $refMatch.Groups["ref"].Value
        }
    }

    $plugins
}

function Get-AsdfPluginExportPath
{
    [CmdletBinding()]
    param()

    $ErrorActionPreference = "Stop"

    $configRoot = $env:XDG_CONFIG_HOME ?? ( Join-Path ( Resolve-Path "~" ) ".config" )
    $asdfConfigRoot = Join-Path $configRoot "asdf"
    Join-Path $asdfConfigRoot "plugins.json"
}

function Export-AsdfPlugins
{
    [CmdletBinding()]
    param()

    $ErrorActionPreference = "Stop"
    $PSNativeCommandUseErrorActionPreference = $true

    $plugins = Get-AsdfPlugins

    $exportPath = Get-AsdfPluginExportPath
    if (-not (Test-Path ( Split-Path $exportPath -Parent )))
    {
        New-Item -ItemType Directory -Path $asdfConfigRoot -Force | Out-Null
    }

    Write-Verbose "Exporting plugins to $exportPath"
    $plugins | Sort-Object -Property Name | ConvertTo-Json -Depth 100 | Out-File -FilePath $exportPath
}

function Get-AsdfExportedPlugins
{
    [CmdletBinding()]
    param()

    $exportPath = Get-AsdfPluginExportPath
    if (-not (Test-Path $exportPath))
    {
        Write-Warning "No plugins exported to $exportPath"
        return @()
    }

    ConvertFrom-Json -InputObject ( Get-Content -Path $exportPath -Raw )
}

function Update-AsdfPlugins
{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $ErrorActionPreference = "Stop"
    $PSNativeCommandUseErrorActionPreference = $true

    $exportedPlugins = Get-AsdfExportedPlugins
    $currentPlugins = Get-AsdfPlugins

    $pluginNamesWhichShouldExist = @()
    foreach ($plugin in $exportedPlugins)
    {
        $pluginNamesWhichShouldExist += $plugin.Name
        $currentPlugin = $currentPlugins | Where-Object { $_.Name -eq $plugin.Name }
        if ($null -eq $currentPlugin)
        {
            Write-Verbose "Adding plugin $($plugin.Name)"
            if ($PSCmdlet.ShouldProcess("Add plugin $($plugin.Name)"))
            {
                asdf plugin add $($plugin.Name) $($plugin.Url) $($plugin.Ref)
            }
        } else
        {
            $urlDifferent = $currentPlugin.Url -ne $plugin.Url
            $refDifferent = $currentPlugin.Ref -ne $plugin.Ref

            if (-not $urlDifferent -and -not $refDifferent)
            {
                Write-Verbose "Plugin $($plugin.Name) is already up to date"
                continue
            }

            if ($urlDifferent)
            {
                Write-Verbose "Removing plugin $($plugin.Name) as URL is different. Current: $($currentPlugin.Url), Expected: $($plugin.Url)"
                if ($PSCmdlet.ShouldProcess("Remove plugin $($plugin.Name)"))
                {
                    asdf plugin remove $($plugin.Name)
                }
            }

            Write-Verbose "Updating plugin $($plugin.Name) ref $($currentPlugin.Ref) -> $($plugin.Ref)"
            if ($PSCmdlet.ShouldProcess("Update plugin $($plugin.Name) ref"))
            {
                asdf plugin update $($plugin.Name) $($plugin.Ref)
            }
        }
    }

    $pluginsToRemove = $currentPlugins | Where-Object { $pluginNamesWhichShouldExist -notcontains $_.Name }
    foreach ($plugin in $pluginsToRemove)
    {
        Write-Verbose "Removing plugin $(plugin.Name)"
        if ($PSCmdlet.ShouldProcess("Remove plugin $(plugin.Name)"))
        {
            asdf plugin remove $(plugin.Name)
        }
    }
}
