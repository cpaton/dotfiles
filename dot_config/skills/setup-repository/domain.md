# Domain Docs

How software-development skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- `docs/context.md`, or
- `docs/context-map.md` if it exists; it points at one `docs/context.md` per context. Read each context relevant to the topic.
- `docs/adr/`; read ADRs that touch the area you're about to work in. In multi-context repos, also check context-specific `docs/adr/` directories.

If any of these files do not exist, proceed silently. Do not flag their absence or suggest creating them upfront. Producer skills create them lazily when terms or decisions are resolved.

## Single-context repo

Most repos have one context:

```text
/
|- docs/context.md
|- docs/adr/
`- src/
```

## Multi-context repo

A multi-context repo has `docs/context-map.md`:

```text
/
|- docs/context-map.md
|- docs/adr/              <- system-wide decisions
`- src/
   |- ordering/
   |  |- docs/context.md
   |  `- docs/adr/        <- context-specific decisions
   `- billing/
      |- docs/context.md
      `- docs/adr/
```

## Use the glossary's vocabulary

When output names a domain concept, use the term defined in `docs/context.md`. Do not drift to synonyms the glossary explicitly avoids.

If the concept you need is not in the glossary yet, either reconsider the term or note the gap for a domain-doc update.

## Flag ADR conflicts

If output contradicts an existing ADR, surface it explicitly rather than silently overriding it.
