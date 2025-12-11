if ($IsLinux)
{
    $env:SSH_AUTH_SOCK = Join-Path ( Resolve-Path ~ ) ".ssh/ssh-agent.sock"
}
