function Unlock-GpgVault() {
    [CmdletBinding()]
    param()

    $env:GPG_TTY = "$(tty)"
    gpg-connect-agent updatestartuptty /bye
    gopass show unlock-check 2>$null | Out-Null
}

function Lock-GpgVault() {
    [CmdletBinding()]
    param()

    gpg-connect-agent reloadagent /bye
    # gpgconf --kill gpg-agent
}

function Get-GpgKeyInfo() {
    [CmdletBinding()]
    param()

    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $true

    $lines = gpg --list-keys --with-subkey-fingerprints --with-keygrip --with-colons | ForEach-Object { $_ }

    $results = @()
    $currentPrimary = $null
    $currentKey = $null

    foreach ($line in $lines) {
        $fields = $line -split ':'

        switch ($fields[0]) {
            'pub' {
                if ($currentPrimary) {
                    $results += [PSCustomObject]$currentPrimary 
                }
                $currentKey = $null
                $algo = & { switch ($fields[3]) {
                        '1' {
                            'RSA' 
                        } '2' {
                            'RSA-Encrypt' 
                        } '3' {
                            'RSA-Sign' 
                        }
                        '16' {
                            'Elgamal' 
                        } '17' {
                            'DSA' 
                        } '18' {
                            'ECDH' 
                        }
                        '19' {
                            'ECDSA' 
                        } '22' {
                            'EdDSA' 
                        } default {
                            $fields[3] 
                        }
                    } }
                $currentPrimary = @{
                    Validity     = switch ($fields[1]) {
                        'o' {
                            'unknown' 
                        } 'n' {
                            'never-trust' 
                        } 'm' {
                            'marginal' 
                        }
                        'f' {
                            'full' 
                        } 'u' {
                            'ultimate' 
                        } 'r' {
                            'revoked' 
                        }
                        'e' {
                            'expired' 
                        } 'd' {
                            'disabled' 
                        } default {
                            $fields[1] 
                        }
                    }
                    KeyLength    = $fields[2]
                    Algorithm    = $algo
                    KeyId        = $fields[4]
                    Created      = if ($fields[5]) {
                        [DateTimeOffset]::FromUnixTimeSeconds([long]$fields[5]).DateTime 
                    }
                    else {
                        $null 
                    }
                    Expires      = if ($fields[6]) {
                        [DateTimeOffset]::FromUnixTimeSeconds([long]$fields[6]).DateTime 
                    }
                    else {
                        $null 
                    }
                    Trust        = switch ($fields[8]) {
                        'o' {
                            'unknown' 
                        } 'n' {
                            'never-trust' 
                        } 'm' {
                            'marginal' 
                        }
                        'f' {
                            'full' 
                        } 'u' {
                            'ultimate' 
                        } default {
                            $fields[8] 
                        }
                    }
                    # Capabilities field: uppercase = this key's own capabilities,
                    # lowercase = what subkeys can do collectively. Subkeys only use lowercase.
                    Capabilities = @(
                        if ($fields[11] -cmatch 'S') {
                            'sign' 
                        }
                        if ($fields[11] -cmatch 'C') {
                            'certify' 
                        }
                        if ($fields[11] -cmatch 'E') {
                            'encrypt' 
                        }
                        if ($fields[11] -cmatch 'A') {
                            'authenticate' 
                        }
                    ) -join ', '
                    Curve        = $fields[16]
                    Fingerprint  = $null
                    Keygrip      = $null
                    Uid          = $null
                    Cached       = $false
                    Subkeys      = @()
                }
                $currentKey = $currentPrimary
            }
            'sub' {
                $algo = & { switch ($fields[3]) {
                        '1' {
                            'RSA' 
                        } '2' {
                            'RSA-Encrypt' 
                        } '3' {
                            'RSA-Sign' 
                        }
                        '16' {
                            'Elgamal' 
                        } '17' {
                            'DSA' 
                        } '18' {
                            'ECDH' 
                        }
                        '19' {
                            'ECDSA' 
                        } '22' {
                            'EdDSA' 
                        } default {
                            $fields[3] 
                        }
                    } }
                $subkey = @{
                    Validity     = switch ($fields[1]) {
                        'o' {
                            'unknown' 
                        } 'n' {
                            'never-trust' 
                        } 'm' {
                            'marginal' 
                        }
                        'f' {
                            'full' 
                        } 'u' {
                            'ultimate' 
                        } 'r' {
                            'revoked' 
                        }
                        'e' {
                            'expired' 
                        } 'd' {
                            'disabled' 
                        } default {
                            $fields[1] 
                        }
                    }
                    KeyLength    = $fields[2]
                    Algorithm    = $algo
                    KeyId        = $fields[4]
                    Created      = if ($fields[5]) {
                        [DateTimeOffset]::FromUnixTimeSeconds([long]$fields[5]).DateTime 
                    }
                    else {
                        $null 
                    }
                    Expires      = if ($fields[6]) {
                        [DateTimeOffset]::FromUnixTimeSeconds([long]$fields[6]).DateTime 
                    }
                    else {
                        $null 
                    }
                    Capabilities = @(
                        if ($fields[11] -cmatch 'e') {
                            'encrypt' 
                        }
                        if ($fields[11] -cmatch 's') {
                            'sign' 
                        }
                        if ($fields[11] -cmatch 'a') {
                            'authenticate' 
                        }
                    ) -join ', '
                    Curve        = $fields[16]
                    Fingerprint  = $null
                    Keygrip      = $null
                    Cached       = $false
                }
                $currentPrimary.Subkeys += $subkey
                $currentKey = $subkey
            }
            'fpr' {
                if ($currentKey) {
                    $currentKey.Fingerprint = $fields[9] 
                } 
            }
            'grp' {
                if ($currentKey) {
                    $currentKey.Keygrip = $fields[9] 
                } 
            }
            'uid' {
                if ($currentPrimary -and -not $currentPrimary.Uid) {
                    $currentPrimary.Uid = $fields[9] 
                } 
            }
        }
    }

    if ($currentPrimary) {
        $results += [PSCustomObject]$currentPrimary 
    }

    # Add cache status from gpg-agent
    $agentLines = gpg-connect-agent 'keyinfo --list' /bye 2>&1 | Where-Object { $_ -match '^S KEYINFO' }
    foreach ($key in $results) {
        $match = $agentLines | Where-Object { $_ -match $key.Keygrip }
        if ($match) {
            $key.Cached = ($match -split '\s+')[6] -eq '1' 
        }
        foreach ($sub in $key.Subkeys) {
            $match = $agentLines | Where-Object { $_ -match $sub.Keygrip }
            if ($match) {
                $sub.Cached = ($match -split '\s+')[6] -eq '1' 
            }
        }
        $key.Subkeys = $key.Subkeys | ForEach-Object { [PSCustomObject]$_ }
    }

    return $results
}

function Test-GoPassVaultLocked() {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $true

    $goPassVaultRoot = '~/.local/share/gopass/stores/root'
    $goPassVaultGpgIdPath = Join-Path $goPassVaultRoot '.gpg-id'

    if (-not (Test-Path $goPassVaultGpgIdPath)) {
        throw "GoPass GPG Vault not found at $goPassVaultGpgIdPath"
    }

    $gpgKeys = Get-GpgKeyInfo

    $goPassVaultGpgIds = Get-Content $goPassVaultGpgIdPath
    foreach ($goPassVaultGpgId in $goPassVaultGpgIds) {
        Write-Verbose "Checking GPG key $goPassVaultGpgId"

        if ($goPassVaultGpgId -notmatch '(0x[0-9A-F]{8})') {
            Write-Verbose "Skipping non-GPG key $goPassVaultGpgId"
            continue
        }

        $gpgKeyId = $goPassVaultGpgId.Substring(2)
        # .gpg-id references the primary key, but decryption uses the encryption subkey.
        $primaryKey = $gpgKeys | Where-Object { $_.KeyId -eq $gpgKeyId }
        if ($null -eq $primaryKey) {
            Write-Verbose "No primary key found for GPG key <$goPassVaultGpgId>"
            continue
        }

        $encryptionSubkey = $primaryKey.Subkeys | Where-Object { $_.Capabilities -match 'encrypt' }
        if ($null -eq $encryptionSubkey) {
            Write-Verbose "No encryption subkey found for primary key <$($primaryKey.Uid)> ($($primaryKey.KeyId))"
            continue
        }

        Write-Verbose "Primary key <$($primaryKey.Uid)> ($($primaryKey.KeyId)) -> encryption subkey ($($encryptionSubkey.KeyId)), cached: $($encryptionSubkey.Cached)"
        if ($encryptionSubkey.Cached) {
            return $false
        }
    }

    return $true
}
