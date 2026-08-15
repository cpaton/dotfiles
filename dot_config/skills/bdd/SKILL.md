---
name: bdd
description: Behaviour-driven development with specification-style tests. Use when the user wants to write specs, mentions "bdd", "specs", "behaviour tests", or wants feature-driven testing that avoids mocks in favour of state-based verification.
---

# Behaviour-Driven Development

BDD writes specifications, not unit tests. Each spec describes observable behaviour from the outside — what the system does, not how it's wired internally. Specs are organised by feature and context, not by class. They use real collaborators and verify state, never mock internals or assert on interactions.

When exploring the codebase, read `CONTEXT.md` (if it exists) so spec names and vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## What a good spec is

A spec reads like a sentence: the class/describe block names the context, the method/it block names the expected outcome. Together they form a readable specification of the system's behaviour. Specs survive refactors because they don't know about internals — only observable results.

See [specs.md](specs.md) for structure and naming conventions.
See [state-testing.md](state-testing.md) for how to avoid mocks.

## Seams — where specs go

A **seam** is the public boundary you verify at. Specs live at seams — the interface where you observe behaviour without reaching inside.

**Test only at pre-agreed seams.** Before writing any spec, confirm the seams with the user. No spec is written at an unconfirmed seam.

Ask: "What's the public interface, and which seams should we spec?"

## Anti-patterns

- **Mock-heavy** — mocking internal collaborators, verifying call counts, asserting on interaction rather than state. If the only way to verify is to check a mock was called, you're testing wiring not behaviour.
- **Implementation-coupled** — tests private methods, knows about internal class structure, breaks when you refactor but behaviour hasn't changed.
- **Tautological** — the assertion recomputes the expected value the way the code does. Expected values must come from an independent source: a known-good literal, a worked example, a constant defined once.
- **Class-per-class mirroring** — one test file per production class. Specs are organised by feature, not by implementation structure.

## Rules of the loop

- **Red before green.** Write the failing spec first, then only enough code to pass it.
- **One slice at a time.** One context, one behaviour, one minimal implementation per cycle.
- **Refactoring is separate.** It belongs to the review stage, not the red → green loop.
