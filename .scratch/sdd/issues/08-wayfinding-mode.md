# 08 — Wayfinding mode

**What to build:** `/sdd <effort>` on a folder containing a `map.md` and no implementation tickets works through the map unattended. The Operator follows upstream `wayfinder/SKILL.md`, read by path from the newest installed mattpocock-skills (ADR-0001).

- Research tickets run in parallel on Sonnet.
- Agent-doable task tickets run in sequence.
- Grilling and prototype tickets become Checkpoints.
- When the map is clear, the run stops, and its final message suggests `/to-spec`.

This replaces the behaviour of the old `wayfinder-loop`.

**Blocked by:** 05

**Status:** ready-for-agent

- [ ] The upstream wayfinder skill is resolved from the newest installed version, not copied
- [ ] Research tickets resolve and their findings land in the map's Decisions so far
- [ ] Grilling and prototype tickets are presented as Checkpoints, never worked by agents
- [ ] A clear map ends the run with a `/to-spec` suggestion
- [ ] Eval case "wayfinding" passes
