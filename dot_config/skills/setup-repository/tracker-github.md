# Tracker: GitHub

Work items for this repo live as GitHub issues. Use the `gh` CLI for tracker operations.

## Conventions

- **Create a work item**: `gh issue create --title "..." --body "..."`. Use a heredoc or temporary body file for multi-line bodies.
- **Read a work item**: `gh issue view <number> --comments`.
- **List work items**: `gh issue list --state open --json number,title,body,labels,comments` with appropriate `--label` and `--state` filters.
- **Comment on a work item**: `gh issue comment <number> --body "..."`.
- **Apply or remove labels**: `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- **Close a work item**: `gh issue close <number> --comment "..."`.

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Publishing

When a skill says "publish to the tracker", create a GitHub issue.

## Fetching

When a skill says "fetch the relevant work item", run `gh issue view <number> --comments`.
