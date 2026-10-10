# Read user-only upstream skills by path instead of copying them

Some mattpocock-skills that `/sdd` builds on (`implement`, `wayfinder`, `to-spec`, `to-tickets`, `triage`) are marked `disable-model-invocation: true`, so neither the Operator nor a subagent can call them through the Skill tool. We want upstream updates to flow through rather than freezing a copy, so the Operator resolves the newest installed version under `~/.claude/plugins/cache/claude-plugins-official/mattpocock-skills/<version>/` and tells agents to read and follow that `SKILL.md`. Model-invocable skills (`tdd`, `code-review`, `diagnosing-bugs`, `prototype`, `resolving-merge-conflicts`) are called through the Skill tool as normal. The cost is a dependency on the plugin cache's on-disk layout; if it moves, path resolution is the one place to fix.

## Considered Options

- **Copy the skill text into `/sdd`'s prompts**: rejected, because copies drift from upstream and that drift is what we are trying to avoid.
- **Rebuild `/implement` from the callable skills (`tdd` and `code-review`) in our own Implementer agent**: chosen for the Implementer, since `/implement` is mostly glue around those two skills. Path reading is still needed for wayfinding and planning skills.
