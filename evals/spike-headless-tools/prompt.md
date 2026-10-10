---
max_turns: 6
runs: 1
allowed_tools: [AskUserQuestion, PushNotification]
---

This is a capability probe (fixture for ticket 01 of the sdd spec). Do exactly this, then stop:

1. Call the `AskUserQuestion` tool once, with one question "Spike probe: pick one" and two options "A" and "B".
2. Call the `PushNotification` tool once, with the message "cwi-skills spike probe".
3. If either tool is not available to you, say so instead of calling it.

End your reply with exactly these two lines, filling in what actually happened, quoting any tool result or error verbatim:

ASK_USER_QUESTION: <unavailable | error: ... | answered: ... | no answer: ...>
PUSH_NOTIFICATION: <unavailable | error: ... | sent: ...>
