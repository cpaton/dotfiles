---
name: plan-work-item
description: Interviews the user and explores the repo until there is shared understanding for a feature/PRD. Use before to-prd when the user wants to plan a feature, clarify an idea, or decide what should be captured in a PRD before implementation planning.
---

<what-to-do>

Interview me about every aspect of this feature until we reach a shared understanding. Walk down each branch of the problem and design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

When the feature is clear enough, run `to-prd` to write the result as a canonical feature/PRD to the tracker-defined data store. Do not write the final PRD directly from this skill unless the user explicitly asks you to skip the handoff.

</what-to-do>

<supporting-info>

## Repository conventions

Before planning or writing anything, read the repo-specific agent conventions when they exist:

- `docs/agents/work-items.md`: feature/PRD hierarchy, metadata, and readiness rules
- `docs/agents/tracker.md`: where feature/PRDs and work items live and how to create or update them
- `docs/agents/triage-labels.md`: valid `Status:` values or tracker labels
- `docs/agents/domain.md`: where domain context and ADRs live

If any of these files do not exist, proceed with the defaults in this skill.

Default conventions:

- Product intent hierarchy is `epic -> feature -> story`.
- The canonical planning artifact is a feature/PRD.
- Skip parent levels when they would only duplicate child content.
- Local markdown work items live under `docs/work-items/`.
- Each local markdown work item is a folder containing `item.md`.
- Top-level local markdown folders use `yyyy-MM-dd-<slug>` with the creation date.
- Child work item folders use only `<slug>`.
- Each `item.md` starts with the `#` heading as the first line, then `## Metadata`, then the item content.
- Required metadata fields are `Status:`, `Type:`, and `Created:`.

## PRD handoff

This skill's output is shared understanding, not the final document. At the end of the interview, summarize the agreed feature/PRD content and invoke `to-prd` to write it using the canonical structure from the `prd` skill.

The PRD may include proposal-like discussion, design notes, and specification-level details as sections, but those are not separate artifact types by default.

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context:

```
/
├── docs/
│   ├── context.md
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If `docs/context-map.md` exists, the repo has multiple contexts. The map points to where each one lives:

```
/
├── docs/
│   ├── context-map.md
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── docs/context.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── docs/context.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `docs/context.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `docs/context.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update docs/context.md inline

When a term is resolved, update `docs/context.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) and the repository-specific guidance in `docs/agents/domain.md` when present.

`docs/context.md` should be totally devoid of implementation details. Do not treat `docs/context.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

Before creating or updating an ADR, read `docs/agents/domain.md` when present and follow the repo's ADR location and context rules.

### Handoff to PRD

When the discussion crystallises, hand off to `to-prd`. The `to-prd` skill writes the PRD according to `docs/agents/work-items.md`, `docs/agents/tracker.md`, and the canonical `prd` skill format. The tracker defines the data store; do not assume files, GitHub, GitLab, or another backend unless `docs/agents/tracker.md` says so.

For local markdown defaults:

- Use `docs/work-items/<yyyy-MM-dd-slug>/item.md` for top-level epics.
- Use nested `<slug>/item.md` folders for child features and stories.
- Put the item title as the first line.
- Add `## Metadata` immediately after the title.
- Include `Status:`, `Type:`, and `Created:` metadata.
- Use `Status:` values from `docs/agents/triage-labels.md` when present.

Do not create implementation plans from this skill. Implementation plans are generated only after the feature/PRD is written and clear enough for explicit code-level sequencing.

</supporting-info>
