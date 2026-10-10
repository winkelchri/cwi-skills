---
type: llm
weight: 1
---

The response ends with an `ASK_USER_QUESTION:` line and a `PUSH_NOTIFICATION:` line, each stating a concrete outcome (unavailable, an error with its text, an answer, or sent). It passes whatever the outcome is; it fails only if either line is missing or says nothing concrete.
