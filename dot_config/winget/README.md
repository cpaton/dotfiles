# WinGet configuration

`configuration.winget` declares Windows software to install across machines.
It currently installs Gpg4win from the `winget` source. Portable CLI tools,
including gopass, remain managed by mise.

## Versions

- `settings.version` pins Gpg4win to **5.1.1** (the suite version, not the
  bundled GnuPG component version).
- `directives.version` pins the Microsoft.WinGet.DSC PowerShell module to
  **1.29.380**; prerelease modules are disabled.
- `configurationVersion: 0.2.0` identifies the file format, not software.

Versions are updated manually in the configuration. `useLatest: false` keeps
the requested application version exact; applying it to a machine with a newer
version can uninstall/reinstall that application. Review security releases
regularly and update the pins deliberately. Requested releases must remain
available upstream.

These settings do not create a `winget pin` or prevent upgrades outside this
configuration.

## Apply to a machine

Requires Windows with WinGet **1.6.2631 or later**, internet access to the WinGet
source and PowerShell Gallery, and permission to approve administrator elevation.
Check WinGet with `winget --version`.

In PowerShell, change to this folder (in the repo or its synced
`~/.config/winget` location), then run:

```powershell
# Validate the configuration and resource discovery.
winget configure validate -f .\configuration.winget

# Install/configure the declared software; approve the prompts.
winget configure -f .\configuration.winget

# Check whether the machine matches the declared state.
winget configure test -f .\configuration.winget
```

WinGet resolves the pinned DSC module automatically. Resolve any validation or
module-discovery errors before applying. Reapply after changing versions; this
is not a continuous background updater.

GPG private keys and password stores are provisioned separately, not by this
configuration.
