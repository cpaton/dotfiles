---
name: implement-bead
description: >-
  Implements a Beads issue and its entire descendant tree sequentially using developer
  and parallel Standards/Requirements reviewer subagents, with resumable progress and
  one commit per implemented bead in a shared Git worktree. Use when the user provides
  a bead ID to implement, asks to implement a Beads epic or issue tree, or invokes
  "implement-bead" or "implement bead".
---

# Implement Bead

**Announce:** "I'm using the implement-bead skill to implement this bead tree."

## Input

- **Root bead ID** (required).
- **Tracker directory** (optional): defaults to the current Beads workspace. Preserve
  any explicit database routing supplied by the user.
- **Target repository** (optional): defaults to the current Git repository. The
  tracker can live elsewhere, but implementation targets exactly one repository.

Examples:

```text
/implement-bead ficsit-abc
/implement-bead ficsit-abc — tracker /path/to/planning, repo /path/to/service
```

No OpenSpec installation, change directory, or markdown task list is required.
Bead descriptions, design, acceptance criteria, comments, and ancestor context
provide the requirements; follow references when relevant, without inventing scope.

## Contract

- Include the **entire descendant tree**, discovered through parent-child edges,
  never ID prefixes. Refresh the tree and Beads readiness after each completion.
- Implement **one bead at a time**. Issues with children get bottom-up integration
  review after their children finish; issues without children get direct implementation.
- Dispatch one developer, then **two parallel read-only reviewers**: Standards and
  Requirements. Both must approve. Parent review checks the assembled subtree.
- Allow **five total developer/review rounds per bead**, including the initial round.
  Resume preserves the count; failure or exhausted rounds stops the entire run.
- Use one worktree and branch for the tree, starting from the target's current `HEAD`.
  Resume the matching worktree; never silently reuse unrelated isolation.
- Produce **one conventional commit per implemented bead**, with its ID in the
  message. Amend that bead's commit during fixes. No empty verification commits.
- Claim the root for the run and each bead before work. Never steal another actor's
  claim. Keep unfinished owned beads `in_progress` and retain claims on a stop.
- Persist progress and learnings on the **corresponding bead**; shared workspace
  information belongs on the root. The controller owns all tracker mutations.
- Create discovered bugs/improvements as **follow-up beads outside the selected
  tree**, with `discovered-from` links. Do not implement them during this run.
- Full available repository validation must pass before closing the root. Completion
  means implemented, reviewed, and validated locally, **not merged**.
- Stop on ambiguous requirements, implementation/review failures, ownership conflicts,
  or unsafe resume state. Preserve all work and ask the user when a decision is needed.
- Never push Git or Dolt, open a PR/MR, merge, remove the worktree, discard changes,
  force-close issues, or expand implementation to another repository.

## Execution

Read these references before dispatching work:

1. [Workflow](workflow.md): preflight, worktree, scheduling, review, and completion.
2. [State and resumption](state.md): durable records, checkpoints, and recovery.
3. [Developer prompt](developer-prompt.md): fill for initial work and review fixes.
4. [Reviewer prompts](reviewer-prompts.md): fill both axes and dispatch in parallel.

Use the host's normal general-purpose subagents and configured models. Do not
hard-code a provider or let children delegate further. Pass absolute working paths;
child sessions must not assume they inherit the controller's directory or context.

When no bead is actionable, exit without polling: report **COMPLETE** only if the
root is terminal and verified, otherwise **STOPPED — unfinished/blocked**. Include
bead outcomes, rounds, commits, validation, blockers, follow-ups, branch/worktree,
and how to resume. Do not equate an empty ready frontier with completion.
