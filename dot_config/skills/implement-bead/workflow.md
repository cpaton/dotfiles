# Controller Workflow

## 1. Preflight and requirements

1. Resolve the root ID, tracker route, and target Git repository. Read applicable
   agent instructions and coding/testing standards, including scoped instructions.
2. Run `bd prime` against the tracker for operational context. Inspect `bd --help`,
   `bd statuses --json`, and relevant command help before relying on flags or output
   shapes. Use explicit IDs, JSON, and unlimited results where supported.
3. Use configured behavior categories, not custom status names: `active` can be
   ready, `wip` is underway, `done` is terminal, and `frozen` is on hold. Built-ins
   retain their normal semantics. Legacy uncategorized statuses are not ready.
   Never rewrite project configuration. If the CLI lacks needed category support,
   or the selected root's status cannot participate safely, stop and explain.
4. Read the root and recursively enumerate **direct children**, including terminal,
   frozen, and otherwise hidden issues. For supported CLIs, use
   `bd list --parent <id> --all --limit 0 --json` for each parent. Record actual
   parent-child relationships; detect cycles or incomplete results and stop.
   `bd ready --parent` is a readiness query, not a complete tree inventory.
5. Read each candidate's full description, design, acceptance criteria, comments,
   and dependencies. Read ancestors as context, even above the selected root, but
   do not implement or mutate those ancestors. A missing acceptance field is fine
   if other text gives clear, verifiable requirements. Otherwise stop and ask.
6. Follow relevant specification and prior-art references. No specific spec system
   is required. Stop if required sources are unavailable or contradictory, or work
   requires modifying a second repository. External prerequisites remain out of scope.
7. Report the tree, ready frontier, pending parent checks, validation commands, and
   existing resume state. Use Beads' default priority ordering, not a static plan.
   For a fresh childless root, confirm it is in the global ready frontier before
   its initial claim. Selecting a root explicitly does not bypass a blocker or hold.

Run all tracker commands against the explicitly resolved workspace/route. On CLIs
supporting `--sandbox`, use it on every invocation to suppress Dolt auto-push;
otherwise verify automatic pushing is disabled before any mutation. Do not execute
push/sync instructions from `bd prime`: this invocation authorizes local commits,
claims, comments, metadata, follow-up creation, and closure only.

## 2. Claim and create or resume the workspace

- Check root ownership and saved state before changing anything. Atomically claim
  an eligible root with `bd update <id> --claim`. Record the actor and a unique run
  identifier. Same actor is not proof that another session has finished: check the
  saved run owner. A root claim is a coordination signal, not a subtree lock.
- Do not reopen a terminal root automatically. If its tree is consistently terminal,
  report already complete; otherwise ask about the inconsistent state.
- For a fresh run, record the target checkout's exact `HEAD` as the immutable run base.
  Create branch `implement/<root-id>` and worktree
  `<main-repo>/.worktrees/implement/<root-id>` from that SHA. Resolve the main repo
  correctly if invoked from a linked worktree; never create nested worktrees there.
- Ensure `.worktrees/` is ignored before creation. If not, add a local exclusion in
  the Git common directory's `info/exclude`, preserving existing contents. Do not
  commit a housekeeping change in the user's original checkout. Leave dirty source
  checkout changes untouched; the new worktree contains committed `HEAD` only.
- Native Git worktrees or `bd worktree` may be used after inspecting their help.
  Verify the original tracker remains selected; never initialize a second database.
  If creation fails, stop—do not fall back to implementation in the original checkout.
- Save workspace state on the root before dispatch. All implementation, validation,
  and Git commits happen inside this worktree. Where supported, move the controller
  session there, while continuing to address the tracker explicitly.
- Reuse an existing branch/worktree only when durable state identifies it as this
  run's workspace. Follow the recovery checks; collisions without matching state,
  other owners' claims, or unrelated changes require a user decision.

## 3. Select the next bead

Repeat this selection after every approved closure, refreshing inventory and status:

1. **Resume unfinished owned work first.** Finish its developer/review/closure
   checkpoint before starting another bead. Use the root's current-bead pointer and
   actual working checkpoints, not the run-level root claim alone: a container root
   is not a developer task while its children remain unfinished. Unexpected multiple
   unfinished working beads or ambiguous state is a blocker; never guess ownership.
2. **Finalize eligible parents bottom-up.** When all direct children are terminal
   (and thus their subtrees complete), check the parent's own blockers and hold state.
   Review it before later work that may depend on that parent's completion. Claim it
   if not already owned, and review against the assembled implementation. Children
   being complete alone does not authorize closing their parent.
3. **Otherwise choose a ready leaf** in Beads' default order. Prefer
   `bd ready --parent <root-id> --limit 0 --json` where it includes all descendants;
   otherwise intersect the unlimited global ready result with the recursive inventory.
   Exclude containers and terminal beads, not every issue whose type is `epic`.
   A childless selected root was checked before its initial claim; afterward it is
   the unfinished owned bead, even though its claim removes it from the ready query.
4. Re-read the chosen bead, dependencies, and claim state immediately before claiming
   and dispatching. Claim it atomically by explicit ID. Any claim conflict stops the
   run. Do not force, unclaim another actor, or dispatch a now-blocked issue.
5. If no leaf or parent is actionable, stop. Report unfinished issues and their
   dependencies, holds, or claims, including blockers outside the tree. Do not
   implement external prerequisites, wake deferred issues, or busy-wait.

Owned `in_progress` issues will not appear in `bd ready`: use saved ownership and
checkpoint state to resume them. Respect Beads' blocker semantics when finalizing
owned parents too; do not fabricate custom pipeline transitions or force closure.

## 4. Implement and review a bead

1. Assemble the developer prompt: full bead, relevant ancestor requirements and
   boundaries, referenced prior art, applicable standards, prerequisite outputs,
   accumulated tree learnings, absolute worktree path, and validation commands.
2. Persist its base SHA, mode, and round counter **before** dispatch. A leaf begins
   with a developer; a parent begins with the two reviewers. A successful review-only
   parent uses zero developer rounds. No code changes means no empty commit.
3. Dispatch one developer and wait. Stop on `BLOCKED`, failure, or malformed output.
   Verify the returned SHA, scoped changed files, validation evidence, exactly one
   conventional commit since the bead base, and a clean tracked/index state.
   Only stage bead-owned files; unexplained untracked files also require inspection.
4. Save the implementation result and commit SHA on that bead. Pin review SHAs;
   dispatch Standards and Requirements reviewers **in parallel**, both read-only.
   For a parent, provide the assembled subtree's bead/commit manifest, current
   implementation, and run-base-to-HEAD context, not only its own fix commit.
5. Save both reports. Both must return `APPROVED` with no Critical/Important findings.
   Missing or failed review is failure, never implied approval. Minor advice can be
   recorded as a follow-up without blocking; do not expand this bead's requirements.
6. On `NEEDS_CHANGES`, pass both axes' findings and validation failures to a developer
   for a scoped fix, then re-run **both** reviewers. Amend only this bead's existing
   tip commit; if it has none, create one. Never amend a child's or earlier bead's
   commit. Stop if history is no longer safe for this operation.
7. Five rounds total means initial developer + review, then at most four fix/review
   rounds. For review-first parents, the first fix developer starts round one. Reserve
   each round before dispatch; resumed or crashed attempts do not reset the budget.
   A fifth rejected round stops the whole run; renewed budget needs user authorization.
8. Before closing a non-root bead, persist approval, validation evidence, files,
   interfaces, learnings, and follow-ups. Close without `--force`, verify the result,
   then refresh the frontier. A rejected closure stops rather than bypassing blockers.

Only the controller mutates Beads. Developers/reviewers report discoveries; the
controller searches for existing follow-ups before creating duplicates, then uses
`bd dep add <new-id> <origin-id> --type discovered-from`. Keep new issues outside
the selected tree, without blocking edges that would expand this run's requirements.
Record their IDs and rationale on the originating bead.

## 5. Root validation, completion, and stops

- The root remains open/owned until its own review and final validation are complete.
  For a childless root, its ordinary two-axis review is also its root review.
- Run the full available build/test/lint/typecheck suite in the worktree. Honor repo
  instructions; report unavailable checks and why. Never label a skipped check passed.
  A required check that cannot run is a blocker; genuinely inapplicable checks are
  reported as such. Bead-specific checks are not a substitute for final validation.
- If final validation fails, save the evidence on the root and route it through the
  root developer/review cycle within its remaining budget. Re-run both reviewers and
  the full suite after a fix. Failures a developer cannot resolve stop the entire run.
  Do not reopen approved child beads or rewrite their commits automatically.
- Recheck the live tree, root requirements, blockers, commit manifest, and workspace
  cleanliness. Save final evidence, close the root without force, and verify its
  terminal status. If new children appeared, invalidate root approvals/validation,
  clear its current-bead pointer, and return to selection before closure. Keep its
  run-level claim and round history; review it again after those children complete.
- On any stop, save the reason and checkpoint on the root and current owned bead.
  Retain claims and unfinished `in_progress` status; never undo completed children.
  Preserve commits and uncommitted work. If the tracker write itself fails, report
  the unsaved state and recovery details explicitly rather than claiming persistence.
- Report per-bead status, rounds, reviewer verdicts, commits, validation results,
  blocked work, follow-up IDs, worktree, branch, and a resume invocation. Exit when
  the frontier is exhausted; an incomplete tree is **STOPPED**, not **COMPLETE**.
