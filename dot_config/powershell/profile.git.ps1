if ($IsWindows) {
    $git = Get-Command git -ErrorAction SilentlyContinue

    if ($git)
    {
    	$usrBin = Resolve-Path -Path ( Join-Path -Path $git.Source "..\..\usr\bin" )
    	$sshAddPath = Join-Path -Path $usrBin -ChildPath "ssh-add.exe"
    	$sshAgentPath = Join-Path -Path $usrBin -ChildPath "ssh-agent.exe"

        Set-Alias ssh-add $sshAddPath
    	Set-Alias ssh-agent $sshAgentPath
    }
}
