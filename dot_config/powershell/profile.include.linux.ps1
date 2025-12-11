if (-not $IsLinux)
{
    return
}

function ls
{
    /bin/ls --color=auto @args
}
