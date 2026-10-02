---
name: teams-to-todo
description: Create a To Do task from a Teams message. Finds the message, builds a deep link, assigns a category, and creates the task in the Work list. Use when the user wants to turn a Teams message into a task, create a todo from a chat, or save a Teams request as a task.
---

# Teams Message → To Do Task

Turn a Teams chat message into a task in the user's **Work** To Do list with a deep link back to the original message.

## Constants

```
WORK_LIST_ID = "AAMkADkwY2QxZDljLTA5YzItNDU3NS1iYjYwLWUwNGI1MDEzN2Y5MAAuAAAAAAA5DUGXZUBVT4O2vAXGECHEAQCBtuKPf2sZRo-Fq7SH7zr-AAS_XohiAAA="
```

## Workflow

### 1. Find the message

Locate the Teams message the user refers to. The user may give a person's name, a topic, or a timeframe.

**Search strategy** — use `msgraph___run_script`:
- `GET /me/chats` (`$top=50`) to list recent chats
- For each candidate chat, `GET /me/chats/{chatId}/messages` (`$top=10`, `$orderby=createdDateTime desc`)
- Match on sender `displayName` and/or message content
- For **unread** messages: compare `chat.viewpoint.lastMessageReadDateTime` with `message.createdDateTime`
- Reading messages via the API does **not** mark them as read

### 2. Build the Teams deep link

The `webUrl` field on chat messages is often `null` for 1:1 chats. Construct the link:

```
https://teams.microsoft.com/l/message/{chatId}/{messageId}?context=%7B%22contextType%22%3A%22chat%22%7D
```

Where `chatId` is the full chat ID (e.g. `19:xxx@unq.gbl.spaces`) and `messageId` is the numeric message ID (e.g. `1789570529049`). URL-encode the context JSON.

### 3. Assign a category

Match the message content and context to one of these existing categories:

| Category | When to use |
|---|---|
| `ai` | AI tooling, Kiro, agents, LLMs, AI-DLC |
| `PACE` | Platform & Cloud Engineering team work |
| `sso` | Okta, SAML, OAuth, identity federation |
| `gitlab` | GitLab admin, repos, pipelines, MRs |
| `FXO` | FX Options / tpVol platform |
| `fusion-platform` | Fusion / NextGen platform |
| `obseravability` | Monitoring, logging, Grafana, Cribl, OTEL, Lens (note: intentional typo, keep as-is) |
| `messaging` | Solace, message brokers |
| `usfo` | iSwap / USFO platform |
| `digital-assets` | Digital Assets / DASE |
| `cdp` | CDP platform |
| `small` | Quick tasks (< 30 min) — add alongside the domain category |

If the domain is unclear, omit the category rather than guessing. Multiple categories are fine (e.g. `["sso", "small"]`).

### 4. Create the task

`POST /me/todo/lists/{WORK_LIST_ID}/tasks` via `msgraph___call_api_mutate`:

```json
{
  "title": "<concise summary of the request>",
  "body": {
    "content": "Link to message<{teams_deep_link}>\r\n\r\n<summary of what was asked and key details>",
    "contentType": "text"
  },
  "importance": "normal",
  "categories": ["<matched-category>"]
}
```

**Title**: write a short action-oriented summary, not the raw message text.

**Body format**: the `Link to message<url>` format on the first line matches how Outlook itself creates tasks from Teams messages — To Do renders it as a clickable link.

**Body content**: after the link, include a plain-text summary of the request with key details (account numbers, resource names, deadlines, etc.) so the task is self-contained.

### 5. Confirm

Tell the user: task title, assigned category, and that the link to the original message is included.
