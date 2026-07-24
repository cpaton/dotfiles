# Tracker: GitLab

Work items for this repo live as GitLab issues. Use the `glab` CLI for tracker operations.

## Conventions

- **Create a work item**: `glab issue create --title "..." --description "..."`.
- **Read a work item**: `glab issue view <number> --comments`. Use `-F json` for machine-readable output when needed.
- **List work items**: `glab issue list -F json` with appropriate `--label` filters.
- **Comment on a work item**: `glab issue note <number> --message "..."`. GitLab calls comments "notes".
- **Apply or remove labels**: `glab issue update <number> --label "..."` or `--unlabel "..."`.
- **Close a work item**: post any closing note first with `glab issue note`, then run `glab issue close <number>`.
- **Merge requests**: GitLab calls PRs "merge requests". Use `glab mr ...` commands for MR operations.

Infer the repo from `git remote -v`; `glab` does this automatically when run inside a clone.

## Publishing

When a skill says "publish to the tracker", create a GitLab issue.

## Fetching

When a skill says "fetch the relevant work item", run `glab issue view <number> --comments`.
