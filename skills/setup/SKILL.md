---
name: setup
description: Check what the cockpit + maestro stack can actually do on this machine, and close the gaps. Detects installed plugins, companion skills, and runtime prerequisites (Node, FFmpeg), reports what each missing piece costs you in capability, and gives the exact command to fix it. Use on "set up cockpit", "install the stack", "what's missing", "why can't it render video", "is everything installed", or after a fresh install on a new machine.
argument-hint: "[check | fix | full]"
---

# Setup

Report what this stack can and cannot do **on this machine**, then close the gaps with consent. Never guess at the environment — every line of the report comes from a command you ran this session.

Modes: `check` (detect and report, change nothing — the default) · `fix` (report, then offer each gap in order) · `full` (report, then walk every tier including the optional third-party ones) · `update` (refresh everything already installed — see [Step 4](#step-4--keep-it-current)).

The written companion to this skill is **[INSTALL.md](../../INSTALL.md)** in the cockpit repo — the same tiers, the same commands, plus a troubleshooting section covering every failure this install path is known to produce. Point users there when they want to read ahead, when they are setting up a machine without an agent session to run this in, or when they hit a symptom in that list.

## Step 1 — Look

Run these and read the output. Missing tools are a normal result, not an error to hide.

| What | Command | Reading it |
|---|---|---|
| The pack itself | `claude plugin list` | Both `cockpit` and `maestro` present, enabled, and on the versions you expect |
| Node | `node --version` | **≥ 22** is the floor for the video toolchain |
| FFmpeg | `command -v ffmpeg` (`Get-Command ffmpeg` in PowerShell) | Must be a standalone binary on `PATH`. A bundled encoder inside a library does not satisfy this. **Test for the binary, not its output** — `ffmpeg -version \| head -1` prints nothing when the command is missing, which reads as a blank cell rather than a failure |
| Companion skills | list the skills directory (`~/.claude/skills/` on macOS/Linux, `%USERPROFILE%\.claude\skills\` on Windows) **and** the plugin cache (`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/skills/`) | Which specialists the routing tables can actually reach. Check both — a skill can arrive either way, and reporting only one location is how you get a false "missing" |
| **Shadowing** | any name appearing in *both* locations | See below. This is the most common broken state on a machine that has been set up more than once |
| Remotion, if a project exists | `npx remotion versions` | Version-gated APIs depend on this, and the CLI self-updates its own skills |

On harnesses without `claude`, read the plugin cache directory directly, or ask the user to paste their installed-skill list.

### Shadowing — hand-installed copies competing with a plugin

A user who installed skills by hand (`npx skills add …`, or copying a `skills/` folder) and
*later* installed the plugin that provides the same skills now has two copies of each. The
hand-installed ones never update, and which one answers is not something they chose.

**First, know that there are three locations, not two.** `npx skills add` and similar
cross-tool installers write to **`~/.agents/skills/`** — the Agent Skills standard location,
shared with other harnesses — and drop a **symlink** into `~/.claude/skills/`. Claude Code
itself reads only `~/.claude/skills/`, the project's `.claude/skills/`, and plugin directories;
it never reads `~/.agents/skills/` directly. Two consequences that change what you do:

- `ls ~/.claude/skills/` shows a directory name whose real content lives elsewhere. Use
  `ls -la` and check for `->` before treating an entry as a plain folder.
- **Removing a symlink does not remove the skill's files.** The content stays in
  `~/.agents/skills/`, still used by whatever other tools point there. That is usually what you
  want — say so rather than implying you deleted 22 MB you did not.

Resolve it by evidence, never by assumption:

1. **Diff every shared name**, directory against directory (`diff -r` follows the symlink, which
   is correct here — you want to compare content). Do not compare version strings — these skills
   mostly do not carry one.
2. **Classify each**: identical · plugin is a superset · **local has files the plugin lacks**.
   That third case is the only one that matters, and it is why this is a diff and not a
   `rm -rf`. A local-only file means deleting would destroy a capability.
3. **Check for local-only *skills*, not just files.** Distribution routes differ — the
   hyperframes plugin ships 19 skills while upstream's `npx skills add` ships one more. A name
   present locally and absent from the plugin must be kept.
4. **Back up, then remove only the proven-redundant ones**, and list what you kept and why.

Once resolved, the plugin is the maintained copy: it updates with `claude plugin update`, and
a hand-installed skill never will.

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
| **hyperframes** suite — 19 skills | HTML-to-video authoring, the lint/check/snapshot/render loop, every specialized workflow (product launch, explainer, captions, motion graphics, slideshow), **and `media-use` and `figma`, which ship inside it** | `/plugin install hyperframes@claude-plugins-official` — it is in Anthropic's official marketplace, so it installs exactly like cockpit. Add the marketplace first if needed: `/plugin marketplace add anthropics/claude-plugins-official`. Outside the plugin system: `npx skills add heygen-com/hyperframes --full-depth`, which ships one extra skill (below) |
| **media-use** | Resolving music, SFX, images, icons, logos, voiceover, captions, grades, and LUTs to real files instead of improvising them | **No separate install** — it ships inside the hyperframes suite above. Do not send the user hunting for it |
| **Remotion** | React-to-video, frame-exact programmatic control, and shotcraft's template mode | `npx create-video@latest --yes --blank --no-tailwind my-video && cd my-video && npm i`, per project. `npx remotion upgrade` keeps the library and its bundled skills current |

**`website-to-video` is not in the plugin.** It exists there as a documentation guide, not an
installable skill, so any routing table naming it will find nothing. Only the `npx skills add`
route ships it. If a user needs website capture specifically, say this plainly rather than
sending them to a command that will not resolve.

**State the context cost before installing the suite.** Measured on hyperframes 0.7.64: 19
descriptions, ~2,540 always-on tokens, against ~1,070 for cockpit and maestro together — about
2.4×. Always-on cost scales with the *number* of skills, not their size, which is why maestro
is one skill with 24 modules rather than 24 skills. That is a fine trade for someone who renders
video and a pure loss for someone who does not. Let the user make it knowingly, and re-measure
rather than quoting these figures forever — sum each installed `SKILL.md`'s frontmatter
description, since that is the part that stays resident.

### Tier 3 — source corpora maestro cannot bundle

Only surface these when the user asks for depth maestro doesn't ship. Both are deliberate exclusions, not oversights:

- **threejs-skills** (`github.com/CloudAI-X/threejs-skills`) — the upstream declares **no license**, so it cannot be redistributed inside maestro. Its distilled module stands alone; clone the repo if you want the ten source skills.
- **genjutsu's `ui-ux-pro-max`** (`github.com/AThevon/genjutsu`) — 1.7 MB of Python tooling and CSV data, excluded for size and its Python dependency. The other 14 sub-skills plus the `cast` and `paint` orchestrators are already vendored.

Everything else each upstream ships is vendored in maestro's `library/` and needs no install.

## Step 4 — Keep it current

A stack that installs correctly once and then rots is not set up. Each layer updates by a
different mechanism, and none of them are automatic:

| Layer | Command | Cadence |
|---|---|---|
| cockpit + maestro | `claude plugin marketplace update cockpit` then `claude plugin update cockpit@cockpit` and `claude plugin update maestro@cockpit` | When you want fixes. maestro moves fastest — it tracks eleven upstream projects |
| hyperframes suite | `claude plugin marketplace update claude-plugins-official` then `claude plugin update hyperframes@claude-plugins-official` | Ships often |
| Remotion, per project | `npx remotion upgrade` | Before a build, not after one breaks — it updates the library *and* its bundled skills together |
| FFmpeg, Node | your package manager | Rarely; only when a toolchain asks for a newer floor |

**The marketplace refresh is the step people skip.** `plugin update` compares against your local
clone of the marketplace, so without refreshing it first the update is a no-op that reports
success. Run the pair, in that order, always.

Two more facts worth stating rather than rediscovering: `update` and `enable` need the qualified
`name@marketplace` form (a bare `claude plugin update cockpit` fails with `Plugin not found`),
and every update prints *restart required to apply* — the running session keeps the old skill
bodies until `/reload-plugins` or a restart. Verify afterwards with `claude plugin list` and
check the version column actually moved.

**maestro tracks its own sources.** It carries `upstreams.json` with a pinned commit per watched
path, a drift checker, and a weekly job that opens an issue when an upstream moves. Nothing for
the user to run — but it is why maestro's version climbs faster than cockpit's, and why
"already updated last week" is not a reason to skip it.

## Rules

- **Detection beats memory.** Never report a tool as present or absent without having run the check this session. A tool you "know" is installed is an assumption.
- **Ask per tier, not once.** Blanket approval for "the stack" is not approval to clone four repositories.
- **Re-verify after installing.** The install command exiting 0 is not the check; re-running the detection command is.
- **Don't moralize about gaps.** A machine with no FFmpeg is fine if the user never renders video. Report, recommend, move on.
- **Never touch credentials.** Nothing here needs an API key. If a companion skill asks for one, that is the user's to enter, in its own interface.

## Harness notes

- **Claude Code:** `claude plugin list`, `/plugin`, and `/reload-plugins` are all available; the `/plugin` interface also shows dependency errors in its Errors tab. Batch the tier approvals through AskUserQuestion when the harness offers it.
- **Codex and other AGENTS.md harnesses:** there is no plugin system — the equivalent is cloning both repos and pointing the global `AGENTS.md` at cockpit's router, per the README. Tiers 1–3 are identical; skip Tier 0's plugin commands and verify by listing the cloned directories.
