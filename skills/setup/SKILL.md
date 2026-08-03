---
name: setup
description: Check what the cockpit + maestro stack can actually do on this machine, and close the gaps. Detects installed plugins, companion skills, and runtime prerequisites (Node, FFmpeg), reports what each missing piece costs you in capability, and gives the exact command to fix it. Use on "set up cockpit", "install the stack", "what's missing", "why can't it render video", "is everything installed", or after a fresh install on a new machine.
argument-hint: "[check | fix | full]"
---

# Setup

Report what this stack can and cannot do **on this machine**, then close the gaps with consent. Never guess at the environment — every line of the report comes from a command you ran this session.

Modes: `check` (detect and report, change nothing — the default) · `fix` (report, then offer each gap in order) · `full` (report, then walk every tier including the optional third-party ones).

The written companion to this skill is **[INSTALL.md](../../INSTALL.md)** in the cockpit repo — the same tiers, the same commands, plus a troubleshooting section covering every failure this install path is known to produce. Point users there when they want to read ahead, when they are setting up a machine without an agent session to run this in, or when they hit a symptom in that list.

## Step 1 — Look

Run these and read the output. Missing tools are a normal result, not an error to hide.

| What | Command | Reading it |
|---|---|---|
| The pack itself | `claude plugin list` | Both `cockpit` and `maestro` present, enabled, and on the versions you expect |
| Node | `node --version` | **≥ 22** is the floor for the video toolchain |
| FFmpeg | `command -v ffmpeg` (`Get-Command ffmpeg` in PowerShell) | Must be a standalone binary on `PATH`. A bundled encoder inside a library does not satisfy this. **Test for the binary, not its output** — `ffmpeg -version \| head -1` prints nothing when the command is missing, which reads as a blank cell rather than a failure |
| Companion skills | list the skills directory (`~/.claude/skills/` on macOS/Linux, `%USERPROFILE%\.claude\skills\` on Windows) plus any plugin-provided ones | Which specialists the routing tables can actually reach |
| Remotion, if a project exists | `npx remotion versions` | Version-gated APIs depend on this, and the CLI self-updates its own skills |

On harnesses without `claude`, read the plugin cache directory directly, or ask the user to paste their installed-skill list.

## Step 2 — Report gaps as capability, not as inventory

A missing package name means nothing. Say what stops working:

> **FFmpeg — not on PATH.** HyperFrames can compose and check a video but cannot encode one. Renders fail at the last step.
> **media-use — not installed.** Music, SFX, icon, logo, voiceover, and LUT requests fall back to hand-rolling instead of resolving to a real asset.

Rank by what the user actually does. Someone who only plans and orchestrates needs none of the video stack, and telling them they're "incomplete" is noise.

## Step 3 — Close the gaps, in tiers

Ask before each tier. Never install anything from a third-party source without explicit approval naming the source.

### Tier 0 — the pack

```
/plugin marketplace add leobbaroni/cockpit
/plugin install cockpit@cockpit
/reload-plugins
```

**maestro installs automatically** — cockpit declares it as a dependency, so one install brings both, and the install prints `+ 1 dependency: maestro`. Two consequences worth stating when they come up: maestro cannot be disabled on its own while cockpit is enabled (Claude Code refuses and prints a chained disable command), and cockpit carries maestro's ~5 MB library whether or not the user does design work.

**A skill installed mid-session does not exist until `/reload-plugins`.** Claude Code live-detects edits under `~/.claude/skills/` and a project's `.claude/skills/`, but a plugin install is invisible to that watcher. When the user reports "the command isn't there" or "no command shows up", this is the first thing to check and usually the whole answer — reload or restart, then look again. Nothing is wrong with the install.

**Plugin skills are namespaced by their plugin.** `/cockpit:setup`, `/cockpit:pilot`, `/maestro:maestro` are what autocomplete; the bare `/setup`, `/pilot`, `/maestro` also resolve unless another installed command already claims that name. Give the namespaced form when telling a user what to type — it is the one that cannot collide.

If maestro is somehow missing, re-running the install resolves it, provided the marketplace is still configured.

**On a genuinely clean machine this tier is verified to work in one command.** A fresh config dir with only the marketplace added, then `claude plugin install cockpit@cockpit`, yields cockpit and maestro both `✔ enabled` with the full tree — all eight process skills and all ten vendored corpora. Do not send a new user to install maestro separately; that is the path that creates the mess below.

**Updating from a version before the dependency existed** (cockpit ≤ 1.5.0, where maestro was installed separately) can land in a broken state: cockpit reports `failed to load — Dependency "maestro@cockpit" is not installed` while maestro sits `disabled`. The already-installed maestro was never "pulled in" to satisfy anything, so it never got the explicit enable that a dependency install writes. One command fixes it:

```
claude plugin enable maestro@cockpit
```

Note the CLI wants the **qualified** `name@marketplace` form for `update` and `enable`; a bare `claude plugin update cockpit` fails with `Plugin "cockpit" not found`. Updates also print *restart required to apply* — the running session keeps the old skill bodies until then.

### Tier 1 — runtime prerequisites

Unlocks: rendering video at all.

- **Node ≥ 22** — the floor for both video toolchains.
- **FFmpeg on PATH** — a standalone install (`brew install ffmpeg` · `winget install Gyan.FFmpeg` · `apt install ffmpeg`). HyperFrames shells out to it; Remotion bundles its own encoder and does not need it, so a Remotion-only user can skip this.

Verify by re-running the detection command, not by trusting the installer's output.

### Tier 2 — companion skills

A clean machine has **none** of these — Tier 0 installs cockpit and maestro and nothing else. Absence here is the default state, not a broken install, and a user who only plans and ships code never needs any of it. Each is optional, and the pack degrades honestly without it — the routing tables say so and do the work directly. Install what the user's work actually needs:

| Skill | Unlocks | Install |
|---|---|---|
| **hyperframes** suite — 21 skills | HTML-to-video authoring, the lint/check/snapshot/render loop, every specialized workflow (product launch, explainer, captions, motion graphics, slideshow, website-to-video), **and `media-use` and `figma`, which ship inside it** | `/plugin install hyperframes@claude-plugins-official` — it is in Anthropic's official marketplace, so it installs exactly like cockpit. Add the marketplace first if needed: `/plugin marketplace add anthropics/claude-plugins-official`. Outside the plugin system: `npx skills add heygen-com/hyperframes --full-depth` |
| **media-use** | Resolving music, SFX, images, icons, logos, voiceover, captions, grades, and LUTs to real files instead of improvising them | **No separate install** — it ships inside the hyperframes suite above. Do not send the user hunting for it |
| **Remotion** | React-to-video, frame-exact programmatic control, and shotcraft's template mode | `npx create-video@latest --yes --blank --no-tailwind my-video && cd my-video && npm i`, per project. `npx remotion upgrade` keeps the library and its bundled skills current |

**State the context cost before installing the suite.** Its 21 descriptions sit in every session
at roughly 4,850 tokens — about five times cockpit and maestro combined — because always-on cost
scales with the *number* of skills, not their size. That is a fine trade for someone who renders
video and a pure loss for someone who does not. Let the user make it knowingly.

### Tier 3 — source corpora maestro cannot bundle

Only surface these when the user asks for depth maestro doesn't ship. Both are deliberate exclusions, not oversights:

- **threejs-skills** (`github.com/CloudAI-X/threejs-skills`) — the upstream declares **no license**, so it cannot be redistributed inside maestro. Its distilled module stands alone; clone the repo if you want the ten source skills.
- **genjutsu's `ui-ux-pro-max`** (`github.com/AThevon/genjutsu`) — 1.7 MB of Python tooling and CSV data, excluded for size and its Python dependency. The other 14 sub-skills plus the `cast` and `paint` orchestrators are already vendored.

Everything else each upstream ships is vendored in maestro's `library/` and needs no install.

## Rules

- **Detection beats memory.** Never report a tool as present or absent without having run the check this session. A tool you "know" is installed is an assumption.
- **Ask per tier, not once.** Blanket approval for "the stack" is not approval to clone four repositories.
- **Re-verify after installing.** The install command exiting 0 is not the check; re-running the detection command is.
- **Don't moralize about gaps.** A machine with no FFmpeg is fine if the user never renders video. Report, recommend, move on.
- **Never touch credentials.** Nothing here needs an API key. If a companion skill asks for one, that is the user's to enter, in its own interface.

## Harness notes

- **Claude Code:** `claude plugin list`, `/plugin`, and `/reload-plugins` are all available; the `/plugin` interface also shows dependency errors in its Errors tab. Batch the tier approvals through AskUserQuestion when the harness offers it.
- **Codex and other AGENTS.md harnesses:** there is no plugin system — the equivalent is cloning both repos and pointing the global `AGENTS.md` at cockpit's router, per the README. Tiers 1–3 are identical; skip Tier 0's plugin commands and verify by listing the cloned directories.
