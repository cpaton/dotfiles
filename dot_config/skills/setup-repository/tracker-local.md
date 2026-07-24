# Tracker: Local Markdown

Work items for this repo live as markdown files in the repository.

## Conventions

- Record the chosen root directory here, for example `docs/work-items/`.
- Each work item is a folder containing an `item.md` file.
- Top-level work item folders use `yyyy-MM-dd-<slug>` with the date the work item was created.
- Child work item folders live under their parent work item folder and use only `<slug>`, without a date prefix.
- Nested folders represent the parent/child hierarchy.
- Each `item.md` starts with a `#` heading as the first line, followed by a `## Metadata` section.
- The `## Metadata` section contains key/value metadata lines, including `Status:` and `Type:`.
- Triage state is recorded in the `Status:` metadata line, using the values in `triage-labels.md`.
- Comments and conversation history may append to the bottom of the file under a `## Comments` heading.

Example:

```text
docs/work-items/
`- 2026-04-01-browser-opening/
   |- item.md                         # Type: epic
   |- windows-browser-launch/
   |  |- item.md                      # Type: feature
   |  |- detect-default-browser/
   |  |  `- item.md                   # Type: story
   |  `- launch-url-from-session/
   |     `- item.md                   # Type: story
   `- remote-open-command/
      |- item.md                      # Type: feature
      |- parse-open-request/
      |  `- item.md                   # Type: story
      `- report-open-failures/
         `- item.md                   # Type: story
```

Example `item.md` structure:

```markdown
# Browser Opening

## Metadata

Status: ready-for-agent
Type: epic
Created: 2026-04-01

## Description
```

## Publishing

When a skill says "publish to the tracker", create the work item folder and its `item.md` file under the chosen tracker root, creating parent directories if needed.

## Fetching

When a skill says "fetch the relevant work item", read the referenced file. The user will normally pass the path directly.
