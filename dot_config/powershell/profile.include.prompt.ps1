. __ProfileCachedInitialization "prompt" {
    # oh-my-posh --init --shell pwsh --config ( Join-Path $MachineConfiguration.ConfigRoot "oh-my-posh/shell.omp.json" ) | Out-String
    $ohMyPosh = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    $ohMyPoshConfigPath = Join-Path $MachineConfiguration.ConfigRoot "oh-my-posh/shell.omp.yaml"
    & $ohMyPosh.Definition init pwsh --config=$ohMyPoshConfigPath --print | Out-String
}

if ($IsLinux) {
    $originalPrompt = (Get-Command prompt).ScriptBlock
    function prompt {
        # Set the process current working directory as this doesn't happen by default on Linux
        # which means tools like tmux-ressurect won't restore the correct directory
        if ($ExecutionContext.SessionState.Path.CurrentLocation.Provider.Name -eq "FileSystem") {
            [System.Environment]::CurrentDirectory = $ExecutionContext.SessionState.Path.CurrentLocation.Path
        }
        & $originalPrompt
    }
}
