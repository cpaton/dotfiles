---
name: setup-repository
description: Sets up repo-specific context for global software-development skills under `docs/agents/` and an `## Agent skills` block in AGENTS.md. Use before first use of skills that write feature PRDs, epics, stories, implementation plans, work items, triage labels, or domain-aware docs.
disable-model-invocation: true
---

# Setup Repository

Scaffold the per-repo configuration that global software-development skills assume:

- **Tracker**: where work items live: GitHub, GitLab, local markdown, Jira, or another workflow
- **Work items**: the repo's feature/PRD conventions, product intent hierarchy, and when levels may be skipped
- **Triage labels**: tracker-specific labels or statuses for common agent workflows
- **Domain docs**: where `docs/context.md`, `docs/context-map.md`, and ADRs live

This is a prompt-driven setup skill. Explore first, present findings, ask for decisions one at a time, then write.

## Process

### 1. Explore

Inspect the current repo. Read what exists; do not assume:

- `AGENTS.md`: identify whether it exists and whether an `## Agent skills` block already exists
- `docs/agents/`: detect prior setup output
- `docs/context.md` and `docs/context-map.md`
- `docs/adr/` and any context-specific `docs/adr/`
- `docs/work-items/`, `.scratch/`, or other local markdown work item conventions

### 2. Present findings and ask

Summarise what exists and what is missing. Then walk the user through these decisions one at a time.

#### Section A: Tracker

Explainer: The tracker is where work items live for this repo. Skills that create epics, features, stories, triage items, or publish PRDs need to know whether to use GitHub, GitLab, local markdown, Jira, or another workflow.

Default posture:

- Locally stored in `docs/work-items/` or other local markdown work item conventions.
- Otherwise ask.

Options:

- **Local markdown**: work items live as markdown files in this repo
- **Other**: ask the user to describe the workflow in one paragraph

#### Section B: Work items

Explainer: Work item rules define how feature/PRDs are stored and how product intent is broken down before implementation. The default flow is `feature/PRD -> implementation plan`; the optional work hierarchy is `epic -> feature -> story`, but simple work can skip levels.

Default:

- Use `epic -> feature -> story` for large work that needs coordination over time.
- Use `feature -> story` for medium work that does not need an epic wrapper.
- Use `story` only when the work is already small, independently valuable, and agent-executable.
- Do not create parent levels that only duplicate the child content.

Ask whether the repo wants different names or stricter rules.

#### Section C: Triage labels

Explainer: Triage labels or statuses let skills mark work as needing review, needing more information, ready for an AFK agent, ready for a human, or rejected.

Canonical roles:

- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

Default: use the canonical strings unless the repo already has equivalents.

#### Section D: Domain docs

Explainer: Domain-aware skills read `docs/context.md` for project language and `docs/adr/` for durable decisions.

Confirm the layout:

- **Single-context**: one `docs/context.md` and `docs/adr/`
- **Multi-context**: `docs/context-map.md` pointing to per-context `docs/context.md` files

### 3. Confirm draft

Before writing, show the user a draft of:

- The `## Agent skills` block
- `docs/agents/tracker.md`
- `docs/agents/work-items.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`

### 4. Write

Edit `AGENTS.md` at the repo root. If it does not exist, create it.

If an `## Agent skills` block exists, update it in place. Do not append a duplicate. Do not overwrite surrounding user content.

Use this block shape:

```markdown
## Agent skills

### Tracker

[one-line summary of where work items are tracked]. See `docs/agents/tracker.md`.

### Work items

[one-line summary of the repo's product intent hierarchy]. See `docs/agents/work-items.md`.

### Triage labels

[one-line summary of the label or status vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of single-context or multi-context layout]. See `docs/agents/domain.md`.
```

Write the docs files from this skill's templates:

- `tracker-github.md`
- `tracker-gitlab.md`
- `tracker-local.md`
- `tracker-other.md`
- `work-items.md`
- `triage-labels.md`
- `domain.md`

### 5. Done

Tell the user setup is complete and which skills now read from `docs/agents/`.

Mention that `docs/agents/*.md` is intentionally editable by hand. Re-run `setup-repository` only when switching trackers, changing work item hierarchy conventions, or resetting the repo's agent docs.
