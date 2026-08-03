# Cockpit

**The process pack for AI coding agents — planning, orchestration, review, debugging, and delivery as installable skills. Claude Code native; Codex-compatible via AGENTS.md.**

Cockpit ships eight interlocking process skills and pulls in [maestro](https://github.com/leobbaroni/maestro) — the companion design/motion/3D/video skill — as a dependency, so **one install gets the complete stack**.

## What's inside

| Skill | Discipline |
|---|---|
| **pilot** | The flagship. Detects the project phase (PLAN / KICKOFF / BUILD / REVIEW / IMPROVE / DEBUG / DELIVER), enforces that phase's ritual, and routes to specialists. Ultra-planner mode produces SPEC + PLAN + risk register and stops before code; tiered review mode routes correctness/security/simplification/UX to the right reviewer; and before any fan-out it proposes the **crew** — which model runs which work — for your approval rather than choosing silently. Whatever model you've selected stays the lead and the designer; only mechanical work routes down and only adversarial review routes sideways. Underneath every phase sits the **execution contract**: restate the ask before touching anything, name what you'll touch and touch only that, a tripwire list of the justifications that precede scope creep, and "done" meaning a check you actually ran. |
| **grilling** | The interview that turns an opening ask into a build-ready plan. Looks before it asks; one question per turn with a recommended answer you accept in a word; no question cap — the open forks are counted down in every turn and the run is as long as the work actually is; every fact tagged as stated, verified, or assumed — with memory explicitly not a source. Ten work tracks set what each kind of job must decide, and two gates run before the plan is handed over, the last one rereading it as the stranger who has to execute it. |
| **grill-with-docs** | Grilling plus documentation — glossary terms into CONTEXT.md and ADRs as decisions land, SPEC.md + PLAN.md at the end. |
| **orchestrate** | Lead-dev mode for task batches: parse-and-echo every ask, route to subagents by difficulty, verify behaviorally, review with fresh eyes, report per-item — never silent omission. |
| **handoff** | End-of-phase packaging: append-only project log, how-to-run guides, end-user manuals, final-delivery cleanup with list-first-delete-second. |
| **diagnosing-bugs** | Repro-first debugging: build a tight red-capable feedback loop before any hypothesis, minimise, then fix with a regression test. |
| **domain-modeling** | The project's ubiquitous language: challenge fuzzy terms, maintain CONTEXT.md, record hard-to-reverse choices as ADRs. |
| **setup** | What can this machine actually do? Detects installed plugins, companion skills, Node, and FFmpeg, reports each gap as the capability it costs you rather than a package name, and closes them in tiers — asking before each one, and never cloning a third-party repo without approval. |

The skills reference each other by name and ship together, so every internal reference resolves. References to outside specialists (maestro, hyperframes, code-review, …) are optional: agents route to them when installed and fall back gracefully when not.

## Installation

**[INSTALL.md](INSTALL.md) is the full guide** — every tier, the video toolchain, what it costs
in context, and a troubleshooting section for every failure this path is known to produce. The
short version follows.

**Claude Code — the full stack in three commands (recommended)**

```
/plugin marketplace add leobbaroni/cockpit
/plugin install cockpit@cockpit
/reload-plugins
```

**maestro comes with it.** cockpit declares it as a plugin dependency, so installing cockpit resolves and installs maestro automatically — the install prints `+ 1 dependency: maestro`. Two consequences worth knowing: maestro can't be disabled on its own while cockpit is enabled (Claude Code refuses and prints a chained disable command), and every cockpit install carries maestro's ~5 MB depth library whether or not you do design work.

**`/reload-plugins` is not optional when you install mid-session.** Claude Code live-detects edits under `~/.claude/skills/`, but *not* plugin installs — until you reload (or restart), none of the new commands exist and none of them autocomplete. "The command isn't there" almost always means this.

Then run **`/cockpit:setup`**. Plugin skills are namespaced by their plugin, so `/cockpit:setup`, `/cockpit:pilot`, and `/maestro:maestro` are the names that autocomplete; the bare `/setup`, `/pilot`, `/maestro` also work unless another installed command already claims that name.

Setup checks what this machine can actually do and gives you the exact command for each gap. Be clear on what the two install commands did and did not do:

| | Comes with `/plugin install cockpit@cockpit` |
|---|---|
| cockpit's eight process skills | ✅ automatic |
| maestro, including its ~5 MB vendored library | ✅ automatic, as a dependency |
| Node ≥ 22, FFmpeg on PATH | ❌ your machine's job |
| hyperframes suite, media-use, Remotion | ❌ separate installs |

The second group is what `setup` exists to find. It reports each gap as the capability it costs you and hands you the command — it does not install anything without your say-so. The whole video toolchain is one further command, `/plugin install hyperframes@claude-plugins-official`, and [INSTALL.md](INSTALL.md) covers when it's worth it: 21 skills is ~4,850 always-on tokens, roughly five times cockpit and maestro combined.

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

**Agent-assisted setup** — for a harness with no plugin system, paste this into any capable coding agent:

```text
Set up the "cockpit" process pack and its "maestro" companion for me.

1. Detect my harness and tell me which path applies.
2. Claude Code with plugins: I run "/plugin marketplace add leobbaroni/cockpit"
   then "/plugin install cockpit@cockpit". maestro installs automatically as a
   dependency — don't tell me to install it separately.
3. Claude Code without plugins: clone https://github.com/leobbaroni/cockpit and
   https://github.com/leobbaroni/maestro, then copy cockpit's skills/* plus
   maestro's skills/maestro into my skills directory (~/.claude/skills/ on
   macOS/Linux, %USERPROFILE%\.claude\skills\ on Windows).
4. Codex or another AGENTS.md harness: clone both repos and add to my global
   AGENTS.md (~/.codex/AGENTS.md): "Read <cockpit-clone>/AGENTS.md and follow its
   skill routing for process work. For design/motion/video work, read
   <maestro-clone>/AGENTS.md."
5. If I installed via plugins, tell me to run /reload-plugins (or restart) before
   looking for the new commands — plugin skills are not live-detected, so they
   simply will not exist in a session that started before the install.
6. Then load the "setup" skill and run it — it detects what this machine can
   actually do and walks the remaining gaps. Everything below is its job, not
   yours: don't install Node, FFmpeg, or any third-party skill on your own.
7. Tell me the entry points: /cockpit:pilot for any project work (it detects the
   phase), /cockpit:setup to check the install, /maestro:maestro or just asking
   for design, motion, or video work. Plugin skills are namespaced by plugin;
   the bare names work too unless something else claims them. Substantial
   requests start with a short interview — that's by design, and one of its
   questions is which design house leads the look.
```

## Usage

`/pilot` is the entry point for any ongoing or new project — it opens with a deterministic session ritual (git state, project log, spec check), declares the phase, and enforces its ritual. Two behaviors are intentional across the pack:

- **Substantial work begins with an interview** (grilling): one question at a time until the brief is locked into files. Small, fully-specified tasks skip it.
- **Nothing is reported done unverified**: flows are driven, screenshots taken, adjacent surfaces checked — a green typecheck is not "done".

## Repository layout

```
cockpit/
├── .claude-plugin/          Plugin + marketplace manifests (cockpit declares maestro as a dependency)
├── skills/                  The eight process skills (one folder per skill)
├── AGENTS.md                Codex / non-Claude harness router with the skill index
├── CLAUDE.md                Contributor rules (harness-neutrality contract)
└── LICENSE · CHANGELOG.md
```

## Companions

- **[maestro](https://github.com/leobbaroni/maestro)** — design, motion, 3D, and video: art direction, page anatomy (macrostructures, component fingerprints, themes), Design DNA, GSAP/Three.js/motion guidance, shot-card-led product video with HyperFrames and Remotion beneath it, a live-verified tool/library toolbox, and the same grill-first process — which asks *you* which design house leads. Eleven upstream projects distilled into one voice over a vendored library of their full corpora, so their named protocols (audit, critique, redesign, study, polish, bolder, typeset, brand kit…) run for real. Installable from this marketplace.
- **Video stack (third-party, optional)** — maestro's README lists exact installs for the HyperFrames suite, Remotion scaffolding, and media tooling.

## License

MIT. The eight skills are original process material; maestro carries its own license and upstream attribution in its repo.
