# Durable State and Resumption

## Storage

Beads is the execution source of truth. Never create a tracked progress/learnings
file, a second task list, or a separate Beads database in the worktree.

Use a namespaced `implement_bead` metadata object on each worked bead. Read the
current metadata, merge only this namespace, and preserve unrelated keys. Use
supported CLI metadata writes, for example `bd update <id> --metadata @<temp-file>`.
Store long evidence as append-only structured comments rather than replacing the
bead's description, design, acceptance criteria, or existing notes.

Illustrative metadata (omit fields that do not yet apply):

```json
{
  "implement_bead": {
    "schema_version": 1,
    "root_id": "proj-abc",
    "run_id": "unique-run-id",
    "actor": "recorded-claim-actor",
    "phase": "review_pending",
    "rounds_used": 1,
    "bead_base_sha": "full-sha-before-this-bead",
    "commit_sha": "full-sha-or-null",
    "standards_verdict": null,
    "requirements_verdict": null,
    "stop_reason": null,
    "run": {
      "tracker_directory": "/path/to/planning",
      "tracker_route": "record any explicit database override",
      "target_repository": "/path/to/repo",
      "worktree": "/path/to/repo/.worktrees/implement/proj-abc",
      "branch": "implement/proj-abc",
      "run_base_sha": "immutable-starting-head",
      "current_bead_id": "proj-abc.1",
      "expected_head_sha": "last-confirmed-head"
    }
  }
}
```

The `run` object belongs **only on the root**. All worked beads carry their own
identity, phase, rounds, commit and verdict state; the root also needs these fields
for its own acceptance/fix cycle. JSON null means no commit/verdict, not approval.

Phases: `claimed`, `developer_pending`, `review_pending`, `changes_requested`,
`approved`, `validation_pending` (root), `close_pending`, `closed`. Record a stop
reason alongside the last recoverable phase, rather than erasing that phase.

## Comments and checkpoints

Prefix each comment with `implement-bead | <run-id> | <event> | round <n>`.
Events include implementation, standards-review, requirements-review, validation,
learnings, follow-ups, and stopped. Each event carries the reviewed SHAs where
relevant, evidence, and an explicit outcome.

- **Before developer:** write phase, fixed bead base SHA, incremented/reserved round,
  expected HEAD, task mode, and any feedback. Save the current bead on the root.
- **After developer:** record full output, validation commands and results, files,
  interfaces, discoveries, learnings, and verified commit SHA. Update expected HEAD.
- **After reviewers:** record each complete report, both verdicts, and reviewed SHAs.
  Approval applies to those SHAs only; any code change invalidates both verdicts.
- **Before closure:** save final evidence and `close_pending`. Close, confirm terminal
  status, then save `closed` and clear the root's current-bead pointer.
- **On stop:** append the cause, current phase, remaining budget, dirty-file status,
  and safe next action. Retain unfinished owned claims and original run identity.

Pass prerequisite bead outputs and learnings to dependent developers; pass accumulated
tree learnings to later developers even if they are not direct dependents. Retrieve
these from bead comments on resume, not from an assumed surviving chat transcript.

## Recovery checks

1. Read the root's state, actual live tree, current bead state, comments, and claims.
   Verify the tracker route, target repo, branch, worktree, run base and run identity.
   Never treat an identical actor name as proof that no competing run is active.
2. Confirm the recorded directory is the expected linked Git worktree and its branch
   is correct. Compare HEAD, history, index, tracked changes, and untracked files with
   saved checkpoints. Unrelated files, unexpected commits, or ownership ambiguity
   require a user decision; never stash, reset, clean, or drop changes automatically.
3. If the recorded branch remains but its worktree was removed, recreate the worktree
   only when saved state proves the last checkpoint was clean and branch history
   matches. If dirty work may have been lost, stop. Do not silently create a new branch.
4. Skip terminal descendants. Recover an interrupted owned bead before new work.
   Do not take another actor's claim or automatically reclaim an expired one: verify
   abandonment and ownership with the user when not demonstrably safe.
5. Reconcile crash windows explicitly. A saved `close_pending` bead already terminal
   needs bookkeeping, not reimplementation. A confirmed commit awaiting review needs
   review, not a second commit. A developer committed but its checkpoint was not saved
   requires validating the single commit, scope, linkage and ownership before adopting
   it; commit message or actor alone is insufficient evidence.
6. Preserved dirty changes may be resumed only when attributable to this bead/run.
   Give the developer their status and last feedback; never tell it to overwrite them.
   Do not reset counters or count interrupted attempts as free retries.
7. Recheck approvals against actual HEAD. Re-run missing/stale reviewers and incomplete
   validation. If the five-round budget was exhausted, ask for explicit authorization
   before extending it, recording the new budget without deleting the prior history.

Tracker metadata and Git are separate writes, not a transaction. If they disagree
and cannot be reconciled safely, stop with both versions of the evidence.
