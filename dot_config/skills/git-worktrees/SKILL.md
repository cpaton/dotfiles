---
name: git-worktrees
description: >-
  Set up an isolated git worktree workspace inside a `.worktrees/` subfolder of the current repo.
  Use when starting feature work that needs branch isolation, before executing implementation plans,
  or when the user mentions "worktree", "isolated workspace", or wants to work on a second branch
  without stashing.
---

# Git Worktrees

Set up an isolated workspace using git worktrees in a `.worktrees/` subfolder.

**Announce at start:** "I'm using the git-worktrees skill to set up an isolated workspace."

## Step 0: Detect Existing Isolation

Before creating anything, check if already in a worktree.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside submodules. Check first:

```bash
git rev-parse --show-superproject-working-tree 2>/dev/null
```

If that returns a path → you're in a submodule, not a worktree. Treat as a normal repo.

**If already in a worktree** (GIT_DIR != GIT_COMMON, not a submodule): report the branch and skip to Step 3.

**If in a normal repo:** proceed to Step 1.

## Step 1: Ensure `.worktrees/` Is Gitignored

The worktree directory **must** be ignored before creating worktrees in it.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_DIR="$REPO_ROOT/.worktrees"

# Check if already ignored
git check-ignore -q "$WORKTREE_DIR" 2>/dev/null
```

**If not ignored:** append `.worktrees/` to `.gitignore` and commit the change before proceeding.

```bash
echo '.worktrees/' >> "$REPO_ROOT/.gitignore"
git add .gitignore
git commit -m "chore: gitignore .worktrees directory"
```

## Step 2: Create the Worktree

```bash
BRANCH_NAME="<feature-branch>"
mkdir -p "$WORKTREE_DIR"
git worktree add "$WORKTREE_DIR/$BRANCH_NAME" -b "$BRANCH_NAME"
cd "$WORKTREE_DIR/$BRANCH_NAME"
```

**If the branch already exists** (remote or local), drop the `-b` flag:

```bash
git worktree add "$WORKTREE_DIR/$BRANCH_NAME" "$BRANCH_NAME"
```

**If `git worktree add` fails** with a permission or sandbox error: tell the user, then fall back to working in the current directory.

## Step 3: Report

```
Worktree ready at <full-path>
Branch: <branch-name>
Based on: <parent-branch>
```

## Cleanup

When finished with a worktree:

```bash
# From the main repo (not inside the worktree)
cd "$REPO_ROOT"
git worktree remove "$WORKTREE_DIR/$BRANCH_NAME"
```

Or to remove all worktrees:

```bash
git worktree list --porcelain | grep '^worktree' | grep '.worktrees/' | awk '{print $2}' | xargs -I{} git worktree remove {}
```

## Quick Reference

| Situation | Action |
|---|---|
| Already in a linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo |
| `.worktrees/` not ignored | Add to `.gitignore` + commit (Step 1) |
| Branch already exists | `git worktree add` without `-b` |
| Permission error on create | Fall back to working in place |
| Finished with worktree | `git worktree remove` from main repo |
