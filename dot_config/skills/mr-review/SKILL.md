---
name: mr-review
description: >-
  Review a GitLab merge request by cloning the project locally, creating a worktree for
  parallel-safe isolation, fetching MR metadata via the GitLab MCP, assembling a spec from
  the MR description and linked issues, and delegating to the code-review skill for two-axis
  review (Standards + Spec). Use when the user pastes a GitLab MR URL, asks to review an MR,
  or mentions "mr review".
---

# GitLab MR Review

Clone/checkout a GitLab MR into an isolated worktree and run a two-axis code review.

## Prerequisites

The `ent-gitlab` MCP must be available. If a Jira issue key is found (e.g. `PROJ-123`), the `ent-jira` MCP is used to fetch it — but Jira is optional, not blocking.

## Input

Accept **either**:

- **MR URL** — `https://<host>/<project-path>/-/merge_requests/<iid>` — parse host, project path, and MR IID.
- **Structured fields** — project path (or numeric ID) + MR IID; host defaults to `scm.tpicapcloud.com`.

## Process

### 1. Parse input and fetch MR metadata

Extract `host`, `project_path`, and `mr_iid` from the URL or structured input.

Fetch the MR via the GitLab MCP:

```
GET /api/v4/projects/<url-encoded-project-path>/merge_requests/<iid>
```

Extract: `source_branch`, `target_branch`, `description`, `title`, `web_url`.

### 2. Clone or update the repo

Target directory: `~/git/<project_path>` (e.g. `~/git/tpicap/root/platform/apex-cli`).

**If the repo does not exist** — clone via SSH:

```powershell
git clone "git@${host}:${project_path}.git" "$HOME/git/${project_path}"
```

**If the repo already exists** — fetch latest:

```powershell
git -C "$HOME/git/${project_path}" fetch origin
```

### 3. Create a worktree for this review

Use a worktree so multiple MR reviews for the same repo can run in parallel.

```powershell
$repoRoot = "$HOME/git/${project_path}"
$worktreeDir = "$repoRoot/.worktrees"
$worktreePath = "$worktreeDir/mr-${mr_iid}"

# Ensure .worktrees/ is gitignored
$ignored = git -C $repoRoot check-ignore -q "$worktreeDir" 2>$null; $LASTEXITCODE -eq 0
if (-not $ignored) {
    Add-Content -Path "$repoRoot/.gitignore" -Value '.worktrees/'
    git -C $repoRoot add .gitignore
    git -C $repoRoot commit -m 'chore: gitignore .worktrees directory'
}

# Remove stale worktree at this path if it exists
if (Test-Path $worktreePath) {
    git -C $repoRoot worktree remove $worktreePath --force
}

# Create worktree on the source branch
git -C $repoRoot worktree add $worktreePath "origin/${source_branch}" --detach
```

The `--detach` avoids branch lock conflicts when multiple worktrees review branches from the same remote. The review only reads; it never commits.

Verify `origin/<target_branch>` is available: `git -C $worktreePath rev-parse "origin/${target_branch}"`. If not, fetch it explicitly.

### 4. Assemble the spec

Build a spec document by combining, in order:

1. **MR title and description** — always included.
2. **Linked GitLab issues** — `GET /api/v4/projects/<id>/merge_requests/<iid>/closes_issues`. Include each issue's title and description.
3. **Jira issues** — scan MR description and commit messages for `[A-Z]{2,}-\d+` patterns. For each unique key, fetch via the Jira MCP (`get_issue`). If unavailable or a fetch fails, note the key as unresolved and continue.
4. **Commit messages** — `git -C $worktreePath log "origin/${target_branch}..HEAD" --oneline`.

If the spec is empty (no description, no linked issues), flag "no spec available" — the Spec axis will skip.

### 5. Delegate to code-review

Run the code-review skill's process with:

- **Repo path**: the worktree at `$worktreePath` — all git and file operations must use `working_dir` set to this path.
- **Fixed point**: `origin/<target_branch>` — code-review will use `git diff origin/<target_branch>...HEAD`.
- **Spec**: the assembled document from step 4.

Follow code-review steps 3–5 (identify standards sources, spawn parallel sub-agents, aggregate).

### 6. Offer post and cleanup

After presenting the review, offer two actions:

- **Post to MR** — `POST /api/v4/projects/<url-encoded-project-path>/merge_requests/<iid>/notes` with the formatted review. Only post if the user confirms.
- **Clean up worktree** — `git -C $repoRoot worktree remove $worktreePath`. Only remove if the user confirms; they may want to inspect the code.
