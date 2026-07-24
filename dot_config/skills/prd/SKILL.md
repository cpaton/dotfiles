---
name: prd
description: Defines the canonical feature/PRD document structure for repository work items. Use when writing, reviewing, or formatting feature PRDs before converting them into implementation plans.
---

# PRD

Use this skill for the canonical feature/PRD structure. A feature/PRD captures shared understanding of something to create. It is not an implementation plan.

The normal flow is:

1. Use `plan-work-item` to interview, explore, and reach shared understanding.
2. Use `to-prd` to write the result in this format to the tracker-defined data store.
3. Convert the PRD into a detailed implementation plan only after it is clear enough for agent execution.

## Repository conventions

Before writing the PRD, read these files when they exist:

- `docs/agents/work-items.md`: work item hierarchy, type, metadata, and readiness rules
- `docs/agents/tracker.md`: where PRDs/work items are stored and how to write them
- `docs/agents/triage-labels.md`: valid `Status:` values
- `docs/agents/domain.md`: where domain context and ADRs live

Use `docs/context.md` vocabulary and respect relevant ADRs in `docs/adr/` when present.

## Canonical feature/PRD structure

```markdown
# <Feature / PRD title>

## Metadata

Status: <triage status>
Type: feature
Created: yyyy-MM-dd

## Summary

One or two paragraphs describing what this is and why it matters.

## Problem

What problem, opportunity, or improvement are we addressing?

## Goals

- Goal 1
- Goal 2

## Non-goals

- Explicitly out of scope
- Things we considered but are not solving now

## Users / actors

Who is affected or who will use this?

## Scenarios

### Scenario 1: <name>

Describe the user/operator journey.

## Requirements

- The system must...
- The user must be able to...

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Design / technical notes

Important design constraints, implementation decisions, APIs, data shapes, or architectural implications.

Keep this high-level unless the details are decision-critical.

## Testing notes

What behavior should be tested, at what seam, and what prior art exists?

## Dependencies and constraints

Known blockers, integrations, sequencing constraints, compatibility requirements.

## Risks and mitigations

Known risks and how we intend to reduce them.

## Open questions

- [ ] Question 1
- [ ] Question 2

## Links

Related ADRs, context docs, parent/child work items, external references.
```

## Rules

- Keep implementation details high-level. File-by-file instructions belong in the implementation plan.
- Include design notes when they affect what should be built, what constraints exist, or what future implementers must not accidentally change.
- Use `Status: ready-for-agent` only when there are no open questions blocking implementation-plan generation.
- If open questions remain, use `Status: needs-info` or the repo-specific equivalent.
- Prefer one clear feature/PRD over separate proposal, design, and specification documents.
