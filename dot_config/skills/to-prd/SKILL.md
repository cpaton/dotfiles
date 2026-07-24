---
name: to-prd
description: Turn the current conversation context into a canonical feature/PRD and publish it to the repository tracker data store. Use after plan-work-item reaches shared understanding or when user wants to create a PRD from current context.
---

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know. If more discussion is needed, stop and recommend `plan-work-item` first.

Load and use the canonical feature/PRD structure from the `prd` skill before writing. Read repo-specific conventions from `docs/agents/` before writing.

## Process

1. Read repo-specific conventions when present:

   - `docs/agents/work-items.md`
   - `docs/agents/tracker.md`
   - `docs/agents/triage-labels.md`
   - `docs/agents/domain.md`

2. Explore the repo to understand the current state of the codebase, if you haven't already. Use `docs/context.md` vocabulary throughout the PRD, and respect ADRs in the area you're touching.

3. Write the PRD using the canonical structure from the `prd` skill.

4. Publish it to the tracker-defined data store from `docs/agents/tracker.md`. For local markdown defaults, create an `item.md` file under the appropriate `docs/work-items/` folder.

5. Set `Status:` to the correct value from `docs/agents/triage-labels.md`. Use `ready-for-agent` only if the PRD is clear enough to convert into a detailed implementation plan.

## Canonical output

Follow the `prd` skill template exactly:

- Title as the first line.
- `## Metadata` immediately after the title.
- `Status:`, `Type: feature`, and `Created:` metadata.
- The PRD body sections from `prd`.

Do not create a detailed implementation plan in this skill. That is a separate step after the PRD is accepted or marked ready for agent.
