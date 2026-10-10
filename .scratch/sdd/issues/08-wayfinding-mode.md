# 08 — Wayfinding mode

**What to build:** `/sdd <effort>` on a folder containing a `map.md` and no implementation tickets works through the map unattended. The Operator follows upstream `wayfinder/SKILL.md`, read by path from the newest installed mattpocock-skills (ADR-0001).

- Research tickets run in parallel on Sonnet.
- Agent-doable task tickets run in sequence.
- Grilling and prototype tickets become Checkpoints.
- When the map is clear, the run stops, and its final message suggests `/to-spec`.

This replaces the behaviour of the old `wayfinder-loop`.

**Blocked by:** 05

**Status:** done

- [x] The upstream wayfinder skill is resolved from the newest installed version, not copied
- [x] Research tickets resolve and their findings land in the map's Decisions so far
- [x] Grilling and prototype tickets are presented as Checkpoints, never worked by agents
- [x] A clear map ends the run with a `/to-spec` suggestion
- [ ] Eval case "wayfinding" passes

## Comments

- Built: `agents/scout.md`, the Wayfinding mode section, mode detection and the wayfinding Ledger template in `skills/sdd/SKILL.md`, the Scout and Map ticket terms in `CONTEXT.md`, a wayfinding note in `permissions.md`, and the `evals-e2e/wayfinding` case. Evidence is in the spec's "Build notes (ticket 08)".
- Eval box left unticked: the case needs Bash, which `claude plugin eval` cannot grant on this machine. Two headless runs on its fixture met every grader by hand. The default suite (`claude plugin eval . --trust-plugin`) passes 3/3.
- "Newest installed version" was checked with only one installed version (1.2.3), so picking between versions was not exercised.
- Not exercised: a Scout reporting HITL or FAILED, a failed verification, a Scout changing the repo (stall), resuming an interrupted `dispatched` ticket, Map updates that add tickets, graduate fog or rule a ticket out of scope, the `Map` item for leftover fog, the Ledger rename when a map folder gains implementation tickets, and the stall count.
- Known gaps: in Manual or acceptEdits mode the permission hook still requires `Bash(git commit:*)`, which wayfinding never uses. `/to-tickets` numbers from `01`, so implementation tickets written into a map folder can collide with map ticket numbers.

- implement-loop: closed by commit cc24a79 (gate green: validate ok, default eval suite 3/3). Wayfinding e2e case verified by 2 headless runs only.
