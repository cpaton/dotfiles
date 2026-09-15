---
name: implement-spec
description: >-
  Orchestrate implementation of a multi-ticket spec with developer and reviewer subagent loops.
  Use when the user has a spec broken into numbered ticket files under an issues/ directory
  and wants them implemented end-to-end with code review. Triggers: "implement spec",
  "execute tickets", "implement these issues".
---

# Implement Spec

Orchestrate sequential implementation of a spec's tickets using developer and reviewer subagents.

**Announce at start:** "I'm using the implement-spec skill to implement this spec."

## Input

- **Spec directory** (required) — path containing `issue.md` and `issues/*.md`
- **Repo path** (optional) — defaults to `git rev-parse --show-toplevel` from the spec directory. Override when the spec lives in a different repo from the implementation target.

## Step 1: Discover and Order Tickets

1. Read `issue.md` (parent spec) and all `issues/*.md` files
2. Parse numeric prefixes (01, 02, 03) for default ordering
3. Parse `Blocked by:` lines to build a dependency graph
4. Compute execution order: respect dependency edges, break ties by numeric prefix
5. Report the plan: ticket order, dependency edges, and which tickets are independent

## Step 2: Create Worktree

Read the `/git-worktrees` skill file and follow its Steps 0–2 exactly. The worktree **must** end up under `$REPO_ROOT/.worktrees/`, not alongside the repo. Use branch name `implement/<spec-directory-name>`. All subsequent work happens inside the worktree directory.

## Step 3: Implement Each Ticket (Sequential)

For each ticket in execution order:

### 3a. Construct Developer Prompt

Read [developer-prompt.md](developer-prompt.md) and fill the template with:
- Full ticket markdown + file path reference
- Summarised spec (sections relevant to this ticket) + path to full spec
- Prior art files inlined (files referenced as patterns in the ticket)
- Worktree working directory path
- Coding standards (`CLAUDE.md`, `AGENTS.md`, `CODING_STANDARDS.md` if present)
- Completed ticket outputs (for dependent tickets: files created, key interfaces)
- Accumulated learnings from all prior tickets (even non-dependent ones)

### 3b. Dispatch Developer Subagent

Report: `⏳ Dispatching developer for <ticket-name>...`

Dispatch a single `default` subagent with the constructed prompt. Wait for completion.

Report: `📝 Developer finished <ticket-name>. Verifying commit...`

### 3c. Capture Commit Range

Record `BASE_SHA` (before developer) and `HEAD_SHA` (after commit). Developer must produce exactly one conventional commit.

### 3d. Dispatch Two-Axis Review (Parallel)

Report: `🔍 Dispatching Standards + Spec reviewers for <ticket-name>...`

Dispatch two `default` subagents **in parallel** using the templates in [reviewer-prompts.md](reviewer-prompts.md):
- **Standards reviewer** — coding standards, code smells, diff quality (read-only)
- **Spec reviewer** — spec compliance, ticket checkbox walk, scope creep (read-only)

Both reviewers are **read-only** — they must not modify files, index, or HEAD.

Report each verdict as it arrives.

### 3e. Evaluate Verdict

- If **both APPROVED** (no Critical or Important issues): move to next ticket
- If **NEEDS_CHANGES** (any Critical or Important issue on either axis): construct a new developer prompt including the reviewer feedback, re-dispatch developer to amend the commit. **Max 3 iterations.**
- If **max iterations reached**: halt and report to user with the last reviewer feedback

### 3f. Report Ticket Complete

```
✅ <ticket-name> — APPROVED (N review iterations)
   commit: <conventional commit message>
```

## Step 4: Final Verification

Run the project's build and full test suite in the worktree. Report pass/fail.

## Step 5: Write Learnings

Collect all developer learnings and reviewer feedback patterns into `<spec-directory>/learnings.md`, structured as: developer learnings (grouped by ticket), recurring reviewer patterns across tickets, and actionable suggestions for improving repo coding standards or this skill's prompts. This file persists beyond the run for future reference.

## Step 6: Summary Report

Report a table of all tickets (status, review iterations, commit message), final verification result, worktree path, branch name, and path to the learnings file.

## Failure Policy

**Hard stop on any failure.** Never skip tickets. If the developer crashes, gets blocked, or max review iterations are reached — halt the entire run and report to the user with full context. Downstream tickets may depend on the failed ticket's output.
