# Dotfiles

Portable developer workstation configuration managed with [chezmoi](https://www.chezmoi.io). Designed to work across both Windows and Linux where possible, with a single repo serving work and personal machines.

## Repository Layout

Chezmoi convention: directories prefixed with `dot_` map to dotfiles/directories in `~`. For example `dot_config/` → `~/.config/`, `dot_ssh/` → `~/.ssh/`.

| Directory | Purpose |
|---|---|
| `dot_config/` | XDG config (`~/.config/`) — nvim, powershell, git, tmux, mcp servers, AI skills, etc. |
| `dot_kiro/`, `dot_kiro-v2/`, `dot_kiro-v3/` | Kiro CLI agent definitions, settings, and crew config |
| `dot_ssh/` | SSH client config and public keys |
| `dot_gnupg/` | GPG agent configuration |
| `dot_local/` | User-local binaries (`~/.local/bin/`) |
| `dot_pi/` | Pi-Agent configuration |
| `bootstrap/` | First-run setup scripts and chezmoi seed config |

Chezmoi templates use `.tmpl` suffix and are rendered at apply time using data from `~/.config/chezmoi/chezmoi.yaml`.

## Cross-Platform Design

Configurations target both Windows and Linux. Where platform differences exist, chezmoi templates handle the branching. The `bootstrap/` directory contains platform-specific setup scripts (`bootstrap/linux/`, `bootstrap/windows/`).

Chezmoi data (`data:` in chezmoi.yaml) parameterises paths and feature flags so the same templates produce correct output on either OS.

## Ownership and Profiles

The repo is shared across work and personal machines. To avoid leaking company-specific configuration into personal installs (or vice versa), the repo uses a **profile system** that controls which files are synced to a given target.

### How it works

**Profile marker files** — `.dotfiles-include-<profile>` — live at the repo root and declare which profiles a target machine subscribes to. The repo currently has:

- `.dotfiles-include-global` — always present, baseline config
- `.dotfiles-include-tpicap` — present on work machines only

**Ownership files** — `.dotfiles-profile-<profile>` — live inside any directory and list the files and subdirectories in that directory that belong to a specific profile. Each line is a filename or directory name. Example from `dot_config/skills/.dotfiles-profile-tpicap`:

```
arch-adversarial-panel
arch-code-review
arch-design-challenge
...
```

These entries (architecture skills, work-specific MCP servers, etc.) are only synced to machines that have `.dotfiles-include-tpicap` at their root.

**Files with no profile assignment** are treated as `global` and sync everywhere.

### Sync logic

The `Sync-DotFiles` function (in `dot_config/powershell/profile.include.dotfiles.ps1`) walks the source tree and:

1. Reads `.dotfiles-include-*` markers from both source and target to determine active profiles
2. In each directory, reads `.dotfiles-profile-*` to build a map of file/directory → profile
3. Copies files whose profile matches (or that have no profile assignment)
4. Skips files whose profile is not active on the target
5. Cleans up target files that no longer exist in the source (but only for profiles the source manages)

### Adding profile-owned content

To assign a file or directory to a profile:

1. Add its name (just the filename, not a path) to the `.dotfiles-profile-<profile>` file in the same directory
2. Ensure the target machine has the corresponding `.dotfiles-include-<profile>` marker

Content not listed in any profile file syncs to all targets.
