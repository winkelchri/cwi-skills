# cwi-skills

A Claude Code plugin that provides `/sdd`, subagent-driven development.

You plan a feature as a spec plus tickets. `/sdd` then works through them unattended. Your session becomes the **Operator**: it dispatches a fresh Implementer subagent per ticket, checks every claim itself (one commit, green Gate, passing smoke run), sends each diff to a Ticket reviewer, and runs fix rounds. Once every ticket is done, a Branch reviewer on Opus reviews the whole branch. Decisions only you can make are collected and asked at **Checkpoints**, so you are interrupted as rarely as possible.

## Setup

### 1. Install the dependency

`/sdd` builds on [mattpocock-skills](https://github.com/mattpocock/skills) (`tdd`, `code-review`, `prototype`, `resolving-merge-conflicts`, plus `to-spec`, `to-tickets` and `wayfinder` for planning). In Claude Code:

```
/plugin install mattpocock-skills@claude-plugins-official
```

### 2. Install cwi-skills

```
/plugin marketplace add winkelchri/cwi-skills
/plugin install cwi-skills@cwi-skills
```

To update later:

```
/plugin marketplace update cwi-skills
```

For local development, add the clone as a directory marketplace instead: `/plugin marketplace add /path/to/cwi-skills`.

### 3. Prepare the target project

`/sdd` reads its work from local markdown under `.scratch/<slug>/` in the project you run it in. Run once per project:

```
/setup-matt-pocock-skills
```

When asked, choose the **local markdown** issue tracker (`.scratch/<feature-slug>/`). See [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md) for the conventions.

The project also needs:

- **A Gate**: a typecheck plus full test suite that is green on the current branch. `/sdd` finds it in `CLAUDE.md`, `AGENTS.md` or the manifests (`package.json`, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`). If it finds several or none, it asks.
- **An E2E seam**: one command that drives the product the way a user does (a CLI call, an HTTP call, a browser test). Name it in the spec's Testing Decisions. `/sdd` refuses to start without one.

### 4. Permissions

A run lasts long and must not stall on a permission prompt. A hook checks the permission mode when `/sdd` starts:

| Mode | `/sdd` |
|---|---|
| `auto`, `bypassPermissions`, `dontAsk` | starts |
| Manual, `acceptEdits` | starts only with the allowlist in [skills/sdd/permissions.md](skills/sdd/permissions.md) |
| `plan` | refuses |

The simplest option is auto mode: `claude --permission-mode auto`, or press Shift+Tab before running `/sdd`.

## Usage

### Plan, then run

```
/to-spec                 # turn the conversation into .scratch/<slug>/spec.md
/to-tickets              # split it into .scratch/<slug>/issues/NN-<name>.md
/sdd <slug>              # work the tickets
/sdd <slug> --parallel   # build independent tickets in parallel worktrees
```

`/sdd` with no slug uses the only runnable slug, or lists all of them.

For an effort still too unclear to spec, map it first with `/wayfinder`. Then run `/sdd <slug>` on the map: Scout subagents resolve the research and task tickets, and you get the grilling and prototype tickets. Once the map is clear, continue with `/to-spec`.

### What a run does

1. **Startup**: checks permissions, finds the Gate and E2E seam, runs the Gate (it must be green), and switches from `main` to `sdd/<slug>`.
2. **Per ticket**: one Implementer builds it test-first as a single commit. The Operator verifies the commit, the Gate and a smoke run of the E2E seam. A Ticket reviewer then reviews the diff, with up to 5 fix rounds (rounds 4 and 5 run on Opus). Minor findings become new tickets.
3. **HITL tickets**: split into agent work plus a decision ticket. Prototype tickets get their variants built on `prototype/<name>` branches for you to compare.
4. **Checkpoint**: once nothing is workable, you answer every waiting item in one go: decisions, prototype picks, stuck tickets.
5. **Branch review**: reviews the whole branch and files its findings as bug tickets. After each fix wave it re-reviews, up to 3 times.
6. **Final Checkpoint**: summary, Rulings, leftover findings. It offers to push, open a PR and clean up branches and worktrees, and does so only for what you pick.

### Safety

Agents never push, reset, delete branches or rewrite history, and never read or write outside the repo (except installed skills under `~/.claude/plugins/`). Push and PR happen only when you pick them at the Final Checkpoint.

### State and resuming

Everything the run tracks lives in `.scratch/<slug>/`, uncommitted:

- `ledger.md`: ticket outcomes, Rulings (judgement calls made without you), open Checkpoint items and deferred findings
- `runs/`: briefs, reports, reviews and Gate and smoke logs

A run that stalls or stops at a Checkpoint resumes where it left off: run `/sdd <slug>` again. You can also answer a decision ticket offline by appending an `## Answer` section to it.

## Repository layout

| Path | Contents |
|---|---|
| `skills/sdd/` | The Operator skill and the permissions guide |
| `agents/` | Implementer, Ticket reviewer, Branch reviewer, Scout |
| `hooks/` | Permission preflight for `/sdd` |
| `evals/` | Cheap smoke eval (no Bash) |
| `evals-e2e/` | End-to-end eval cases on fixture repos |
| `CONTEXT.md`, `docs/adr/` | Domain glossary and decisions |

Run the evals:

```sh
claude plugin eval . --trust-plugin
claude plugin eval . --trust-plugin --eval-dir evals-e2e --scaffold --allow-tools Bash Write Edit --ablation none
```
