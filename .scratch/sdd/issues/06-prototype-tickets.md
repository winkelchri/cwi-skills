# 06 — Prototype tickets

**What to build:** For prototype tickets, an agent builds the prototype with `mattpocock-skills:prototype` on a `prototype/<name>` branch. The resulting Checkpoint item gives the branch, how to run it and the variants to choose between. The developer's choice is written back to the ticket so dependent tickets can proceed.

**Blocked by:** 05

**Status:** ready-for-agent

- [ ] Prototype work happens on its own `prototype/<name>` branch and never lands on the feature branch
- [ ] The Checkpoint item includes branch, run instructions and variants
- [ ] The chosen variant is recorded on the ticket and unblocks its dependents
- [ ] The "mixed" eval case, extended with a prototype ticket, passes
