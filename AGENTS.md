# Cockpit — agent instructions

This repository ships eight **process skills**: self-contained markdown instruction files under `skills/<name>/SKILL.md`. Each one is a discipline for a phase of software work. They are harness-neutral: written for any capable coding agent (Claude Code, Codex, or other AGENTS.md-compatible harnesses). Where mechanics differ per harness, the skill has a "Harness notes" section — follow the branch that matches yours, and ignore tool names your harness doesn't have.

## The rule

When the user's request matches a trigger below, **open that skill file and follow it** before improvising your own process. `pilot` is the umbrella: when in doubt — or at the start of any session on an ongoing project — load `pilot` and let it detect the phase and route.

## Skill index

| Skill | Load when the user says / needs | File |
|---|---|---|
| **pilot** (router + `nodes/`, `STATE.md`, `CONTRACT.md`, `ROUTING.md`) | "plan / ultra-plan / spec this out", "kick off / start building X", "review this / audit", "improve / polish", "what's next / continue", any vague build/improve/review ask — or session start on an ongoing project. Also carries the **execution contract**, the four gates every code change runs through in any phase | `skills/pilot/SKILL.md` |
| **grilling** | "grill me", stress-test a plan or design before building, or any ask too big to start on — the interview that turns it into a build-ready plan (`TRACKS.md` and `PLAN-FORMAT.md` sit alongside it) | `skills/grilling/SKILL.md` |
| **grill-with-docs** | A grilling interview that must also produce ADRs + a glossary as decisions land | `skills/grill-with-docs/SKILL.md` |
| **orchestrate** | "orchestrate", a batch of 3+ tasks handed over at once, multi-agent builds, lead-dev mode | `skills/orchestrate/SKILL.md` |
| **handoff** | Change log, how-to-run guide, end-user manual, revert instructions, final-delivery cleanup | `skills/handoff/SKILL.md` |
| **diagnosing-bugs** | "diagnose / debug this", something broken/throwing/failing/slow with unknown cause, a fix that "didn't take" | `skills/diagnosing-bugs/SKILL.md` |
| **test-driven-development** | Implementing any feature, fix, refactor, or behavior change — the failing test comes first and you watch it fail | `skills/test-driven-development/SKILL.md` |
| **using-worktrees** | Isolating a workspace before a feature or a batch, and taking the clean test baseline | `skills/using-worktrees/SKILL.md` |
| **domain-modeling** | Pinning domain terminology, recording an architectural decision (ADR), maintaining CONTEXT.md | `skills/domain-modeling/SKILL.md` |
| **setup** | "set up cockpit", "install the stack", "what's missing", "why can't it render video", or a fresh machine | `skills/setup/SKILL.md` |

Skills reference each other by name (pilot routes to grilling, orchestrate, diagnosing-bugs, test-driven-development, using-worktrees, handoff, domain-modeling); all ten ship here, so every in-pack reference resolves. References to skills outside this pack (`maestro`, `hyperframes`, `media-use`, `graphify`, `agent-reach`, `deep-research`, `code-review`, `simplify`, `security-review`, `review`, `docx`, and `headcount`'s per-department business skills) are **optional specialists**: route to them when installed, otherwise do the work directly to the same standard and say the specialist was absent.

## Companion: maestro

Design, UI, motion, 3D, and video work routes to the **maestro** skill — a separate repo, [github.com/leobbaroni/maestro](https://github.com/leobbaroni/maestro), with its own AGENTS.md. On Claude Code it installs automatically as a plugin dependency of cockpit; on other harnesses clone it alongside (the README covers both, and the `setup` skill checks the result).

Two things to know when routing to it: its interview asks **the user** which design house should lead the look (structure-led / polish-led / craft-led / blend) — that pick is the user's, and it governs the rest of the project. And when a request names a design action (audit, critique, redesign, study a reference, polish, bolder, typeset, brand kit…), maestro's `commands` module maps it to the originating project's real protocol — run that, not an approximation of it.

## Codex setup

Full instructions, including the runtime prerequisites and the optional video toolchain, are in [INSTALL.md](INSTALL.md) — its "Non-Claude harnesses" section is this path, and its troubleshooting list applies regardless of harness.

For a global install, add one line to `~/.codex/AGENTS.md` (create the file if absent):

```
Read <absolute path to this clone>/AGENTS.md and follow its skill routing for process work (planning, orchestration, review, debugging, handoff).
```

For a per-project install, copy this repo's `skills/` folder into the project and add the same line (with the project-relative path) to the project's `AGENTS.md`.

## Contributing

Edit rules for the skill files themselves are in [CLAUDE.md](CLAUDE.md).
