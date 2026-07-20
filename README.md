# Cockpit

**The process pack for AI coding agents — planning, orchestration, review, debugging, and delivery as installable skills. Claude Code native; Codex-compatible via AGENTS.md.**

Cockpit ships seven interlocking process skills, and its marketplace also serves [maestro](https://github.com/leobbaroni/maestro) — the companion design/motion/3D/video skill — so a single marketplace serves the complete stack (one add, two installs).

## What's inside

| Skill | Discipline |
|---|---|
| **pilot** | The flagship. Detects the project phase (PLAN / KICKOFF / BUILD / REVIEW / IMPROVE / DEBUG / DELIVER), enforces that phase's ritual, and routes to specialists. Ultra-planner mode produces SPEC + PLAN + risk register and stops before code; tiered review mode routes correctness/security/simplification/UX to the right reviewer; and before any fan-out it proposes the **crew** — which model runs which work — for your approval rather than choosing silently. |
| **grilling** | The brief-locking interview: one question at a time, recommended answer attached, until scope and non-goals are pinned. |
| **grill-with-docs** | Grilling plus documentation — glossary terms into CONTEXT.md and ADRs as decisions land, PLAN.md at the end. |
| **orchestrate** | Lead-dev mode for task batches: parse-and-echo every ask, route to subagents by difficulty, verify behaviorally, review with fresh eyes, report per-item — never silent omission. |
| **handoff** | End-of-phase packaging: append-only project log, how-to-run guides, end-user manuals, final-delivery cleanup with list-first-delete-second. |
| **diagnosing-bugs** | Repro-first debugging: build a tight red-capable feedback loop before any hypothesis, minimise, then fix with a regression test. |
| **domain-modeling** | The project's ubiquitous language: challenge fuzzy terms, maintain CONTEXT.md, record hard-to-reverse choices as ADRs. |

The skills reference each other by name and ship together, so every internal reference resolves. References to outside specialists (maestro, hyperframes, code-review, …) are optional: agents route to them when installed and fall back gracefully when not.

## Installation

**Claude Code — the full stack in three commands (recommended)**

```
/plugin marketplace add leobbaroni/cockpit
/plugin install cockpit@cockpit
/plugin install maestro@cockpit
```

**Claude Code — personal or project skills (no plugin system)**

```bash
# personal (macOS/Linux)                        # personal (Windows PowerShell)
cp -r skills/* ~/.claude/skills/                Copy-Item -Recurse skills\* "$env:USERPROFILE\.claude\skills\"
```

Or copy `skills/*` into a repository's `.claude/skills/` to scope them to that project.

**Codex (and other AGENTS.md harnesses)**

```bash
git clone https://github.com/leobbaroni/cockpit
```

Then add one line to `~/.codex/AGENTS.md` (global) or the project's `AGENTS.md`:

```
Read <path-to-clone>/AGENTS.md and follow its skill routing for process work.
```

[AGENTS.md](AGENTS.md) carries the full skill index with triggers; each skill's "Harness notes" section covers the mechanics without Claude-specific tooling.

**Agent-assisted setup** — paste this into any capable coding agent:

```text
Set up the "cockpit" process skills and the "maestro" design skill for me.

1. Detect my harness.
2. Claude Code: tell me to run
   "/plugin marketplace add leobbaroni/cockpit", then
   "/plugin install cockpit@cockpit" and "/plugin install maestro@cockpit".
   If plugins aren't available to me, instead clone
   https://github.com/leobbaroni/cockpit and https://github.com/leobbaroni/maestro
   and copy cockpit's skills/* plus maestro's skills/maestro into my skills
   directory (~/.claude/skills/ on macOS/Linux, %USERPROFILE%\.claude\skills\ on Windows).
3. Codex or another AGENTS.md harness: clone both repos and add to my global
   AGENTS.md (~/.codex/AGENTS.md): "Read <cockpit-clone>/AGENTS.md and follow its
   skill routing for process work. For design/motion/video work, read
   <maestro-clone>/AGENTS.md."
4. Verify: list the installed skills; cockpit ships 7 (pilot, grilling,
   grill-with-docs, orchestrate, handoff, diagnosing-bugs, domain-modeling) and
   maestro ships 1 skill with 17 reference modules.
5. Tell me the entry points: /pilot for any project work (it detects the phase),
   /maestro or just asking for design/motion/video work, and that substantial
   requests start with a short interview — that's by design.
6. OPTIONAL (ask me first — third-party repos): for the full video stack, install
   the HyperFrames suite per maestro's README dependency table
   (github.com/leobbaroni/maestro#full-capabilities-engine-and-companion-dependencies):
   Node ≥ 22 + FFmpeg, plus the hyperframes skills from github.com/heygen-com/hyperframes.
```

## Usage

`/pilot` is the entry point for any ongoing or new project — it opens with a deterministic session ritual (git state, project log, spec check), declares the phase, and enforces its ritual. Two behaviors are intentional across the pack:

- **Substantial work begins with an interview** (grilling): one question at a time until the brief is locked into files. Small, fully-specified tasks skip it.
- **Nothing is reported done unverified**: flows are driven, screenshots taken, adjacent surfaces checked — a green typecheck is not "done".

## Repository layout

```
cockpit/
├── .claude-plugin/          Plugin + marketplace manifests (serves cockpit AND maestro)
├── skills/                  The seven process skills (one folder per skill)
├── AGENTS.md                Codex / non-Claude harness router with the skill index
├── CLAUDE.md                Contributor rules (harness-neutrality contract)
└── LICENSE · CHANGELOG.md
```

## Companions

- **[maestro](https://github.com/leobbaroni/maestro)** — design, motion, 3D, and video: art direction, Design DNA, GSAP/Three.js/motion guidance, HyperFrames + Remotion video modules, a live-verified tool/library toolbox, and the same grill-first process. Installable from this marketplace.
- **Video stack (third-party, optional)** — maestro's README lists exact installs for the HyperFrames suite, Remotion scaffolding, and media tooling.

## License

MIT. The seven skills are original process material; maestro carries its own license and upstream attribution in its repo.
