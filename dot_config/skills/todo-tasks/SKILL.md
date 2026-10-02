---
name: todo-tasks
description: Retrieve and display active (non-completed) tasks from the user's Microsoft To Do "Work" list via the ent-msgraph MCP. Use when the user mentions todo, tasks, work list, task list, my tasks, what's on my plate, or wants to see their outstanding work items.
---

# To Do Tasks

Retrieve active tasks from the user's Microsoft To Do **Work** list via the `ent-msgraph` MCP.

## Defaults

- **List**: "Work" — ID `AAMkADkwY2QxZDljLTA5YzItNDU3NS1iYjYwLWUwNGI1MDEzN2Y5MAAuAAAAAAA5DUGXZUBVT4O2vAXGECHEAQCBtuKPf2sZRo-Fq7SH7zr-AAS_XohiAAA=`
- **Filter**: `status eq 'notStarted'` (excludes completed, deferred, waitingOnOthers)
- **Sort**: `createdDateTime desc` (newest first) — this is the server default; drag-and-drop ordering is **not** exposed by the Graph API
- **Limit**: 50 tasks per request (paginate with `@odata.nextLink` if more)

## Quick retrieval

Use `msgraph___run_script` for a single call that fetches and formats:

```python
import json

WORK_LIST_ID = "AAMkADkwY2QxZDljLTA5YzItNDU3NS1iYjYwLWUwNGI1MDEzN2Y5MAAuAAAAAAA5DUGXZUBVT4O2vAXGECHEAQCBtuKPf2sZRo-Fq7SH7zr-AAS_XohiAAA="

resp = call_api("GET", f"/me/todo/lists/{WORK_LIST_ID}/tasks", params={
    "$filter": "status eq 'notStarted'",
    "$top": "50",
    "$orderby": "createdDateTime desc"
})
data = json.loads(resp) if isinstance(resp, str) else resp
tasks = data.get("value", data.get("results", []))

result = {
    "count": len(tasks),
    "tasks": [
        {
            "title": t["title"],
            "importance": t.get("importance", "normal"),
            "categories": t.get("categories", []),
            "created": t.get("createdDateTime", "")[:10],
            "modified": t.get("lastModifiedDateTime", "")[:10],
            "due": (t.get("dueDateTime") or {}).get("dateTime", "")[:10] or None,
            "body_preview": (t.get("body", {}).get("content", "") or "")[:150],
            "id": t["id"],
        }
        for t in tasks
    ]
}
result
```

## Presentation

Present tasks as a table grouped or sorted by what the user asked for. Default format:

```
| # | Title | Categories | Created | Due |
|---|-------|------------|---------|-----|
```

When the user asks to filter by category, add `and categories/any(c:c eq 'sso')` to the `$filter` parameter (OData lambda). Multiple categories: chain with `or` inside the lambda or filter client-side.

## Other lists

If the user asks for a different list, query `/me/todo/lists` first to find the list ID by `displayName`, then substitute. Known lists:

| List | Purpose |
|------|---------|
| **Work** (default) | Active work items |
| **SDS** | Secure Developer Spaces tasks |
| **Improvement** | Personal/tooling improvement ideas |
| **Work-Old** | Archived older work tasks |
| **Flagged Emails** | System list from flagged Outlook emails |

## Limitations

- **No drag-and-drop ordering**: the Graph API does not expose the manual sort order set in Outlook/To Do. `orderHint` does not exist on `todoTask` (confirmed via beta API). The `OrderDateTime` open extension reported in community posts is not present on these tasks.
- **Importance** is the only priority signal: `low`, `normal`, or `high`. It maps to the flag marker in Outlook, not positional rank.
- **Categories** are the primary organizational mechanism — they're user-defined coloured labels.
- Tasks created from flagged emails or Teams messages include the source link in the body.

## Scopes required

`Tasks.Read` (minimum) or `Tasks.ReadWrite` — configured in the apex vault under `graph.microsoft.com`.
