# Work Items

This repo uses feature/PRDs as the canonical planning artifact before implementation plans.

## Canonical terms

- **Feature/PRD**: The shared-understanding document that describes what should be created and why.
- **Epic**: A large outcome or initiative that may contain multiple feature/PRDs.
- **Feature**: A coherent deliverable, usually represented by one feature/PRD.
- **Story**: A small, independently valuable slice that may be captured directly when no larger feature wrapper is needed.
- **Implementation plan**: A lower-level, code-facing breakdown generated from an approved feature/PRD.

## Skipping levels

Use the shallowest hierarchy that keeps the work understandable and executable.

- Use `epic -> feature -> story` when work spans multiple deliverables or needs coordination over time.
- Use `feature -> story` when the work is a coherent deliverable but does not need an epic wrapper.
- Use `story` only when the work is already small, independently valuable, and agent-executable.
- Do not create parent levels that only duplicate the child content.

## Metadata

Each work item starts with its `#` heading as the first line. Immediately after the heading, add a `## Metadata` section containing key/value metadata lines. Expected fields:

- `Status:`: The triage label or status from `docs/agents/triage-labels.md`.
- `Type:`: One of `epic`, `feature`, or `story`.
- `Created:`: The creation date in `yyyy-MM-dd` format.

Example:

```markdown
# Browser Opening

## Metadata

Status: ready-for-agent
Type: story
Created: 2026-04-01

## Description
```

## Feature/PRD content

A feature/PRD should capture:

- Summary
- Problem
- Goals
- Non-goals
- Users / actors
- Scenarios
- Requirements
- Acceptance criteria
- Design / technical notes
- Testing notes
- Dependencies and constraints
- Risks and mitigations
- Open questions
- Links

Proposal-like discussion, design notes, and specification details belong inside the feature/PRD when useful. They are not separate artifact types by default.

## Agent-ready stories

A story is ready for an AFK coding agent when it has:

- Clear user-visible or operator-visible behavior
- Acceptance criteria
- Known blockers, or "None"
- Enough context to implement without another conversation
- A pointer to any relevant feature/PRD, ADR, or domain docs

## Plans

Plans are implementation detail, not product intent.

Create an implementation plan only after a feature/PRD is accepted or marked ready for agent. Store plans using this repo's existing convention, or ask if no convention exists.
