# Installing cockpit

Every command here was run on a real machine before it was written down, and the failure modes
in [Troubleshooting](#troubleshooting) are ones that actually happened rather than ones that
might. If you only read one section, read [The 60-second path](#the-60-second-path).

## The 60-second path

Claude Code, plugins enabled:

```
/plugin marketplace add leobbaroni/cockpit
/plugin install cockpit@cockpit
/reload-plugins
/cockpit:setup
```

The second command prints `+ 1 dependency: maestro` — that is the whole stack, both plugins,
in one install. The third makes them exist in the session you are already sitting in. The
fourth checks what the machine can do and walks you through anything missing.

Stop here if you only plan, build, review, and ship code. The rest of this document is the
video and rendering toolchain, which is separate on purpose.

## What arrives when

The single most common misunderstanding: installing cockpit does **not** install a video
toolchain. It installs the skills that know how to use one.

| | Arrives with `/plugin install cockpit@cockpit` | Notes |
|---|---|---|
| cockpit's eight process skills | ✅ automatic | 188 KB |
| maestro, with its vendored depth library | ✅ automatic, as a declared dependency | 5.6 MB, of which 5.0 MB is `library/` |
| Node ≥ 22 | ❌ | Your machine's job |
| FFmpeg on `PATH` | ❌ | Only needed for the HyperFrames render path |
| hyperframes suite, media-use, figma | ❌ | One plugin install — see [Step 4](#step-4--the-video-stack-optional) |
| Remotion | ❌ | Per-project scaffold, never global |

A clean machine has **none** of the bottom four. That is the default state, not a broken
install, and nothing in cockpit or maestro fails because of it — the routing tables detect
what is present and do the work directly when a specialist is absent.

## Step 1 — the pack

```
/plugin marketplace add leobbaroni/cockpit
/plugin install cockpit@cockpit
```

cockpit declares `dependencies: ["maestro"]`, so one install resolves both. Verified on a
genuinely clean config directory: cockpit and maestro both land `✔ enabled` with the complete
tree — all eight process skills, all ten vendored corpora.

Two consequences of the dependency worth knowing up front:

- **maestro cannot be disabled on its own** while cockpit is enabled. Claude Code refuses and
  prints a chained disable command.
- **Every cockpit install carries maestro's 5 MB library**, whether or not you do design work.
  It costs disk, not context — see [What this costs you in context](#what-this-costs-you-in-context).

CLI equivalents, if you prefer the terminal to the `/plugin` interface:

```bash
claude plugin marketplace add leobbaroni/cockpit
claude plugin install cockpit@cockpit
```

## Step 2 — reload

```
/reload-plugins
```

**This is not optional when you install mid-session.** Claude Code watches `~/.claude/skills/`
and a project's `.claude/skills/` for live edits, but a plugin install is invisible to that
watcher. Until you reload — or restart — the new commands do not exist and do not autocomplete.
"The command isn't there" is almost always this and almost never a failed install.

## Step 3 — verify

```bash
claude plugin list
```

You want both lines `✔ enabled`:

```
❯ cockpit@cockpit   Version: 1.6.2   Status: ✔ enabled
❯ maestro@cockpit   Version: 3.6.0   Status: ✔ enabled
```

Then confirm the commands resolve. **Plugin skills are namespaced by their plugin**, so the
names that autocomplete are `/cockpit:pilot`, `/cockpit:setup`, `/maestro:maestro`. The bare
`/pilot`, `/setup`, `/maestro` also work, but only while no other installed command claims
that name — prefer the namespaced form when writing anything down.

The eight process commands: `/cockpit:pilot` · `/cockpit:grilling` · `/cockpit:grill-with-docs`
· `/cockpit:orchestrate` · `/cockpit:handoff` · `/cockpit:diagnosing-bugs` ·
`/cockpit:domain-modeling` · `/cockpit:setup`.

## Step 4 — the video stack (optional)

Skip this entirely unless you render video. maestro gives you design judgment, art direction,
motion principles, critique, and 3D guidance with **nothing** installed beyond the plugin.

### Runtime prerequisites

| | Check | Install |
|---|---|---|
| **Node ≥ 22** | `node --version` | [nodejs.org](https://nodejs.org) or your version manager |
| **FFmpeg** | `command -v ffmpeg` | macOS `brew install ffmpeg` · Windows `winget install Gyan.FFmpeg` · Debian/Ubuntu `sudo apt install ffmpeg` |

Check FFmpeg with `command -v`, **not** with `ffmpeg -version`. A missing binary makes the
second one print nothing at all, which reads as an empty result rather than a failure — that
exact mistake shipped in cockpit 1.6.0 and reported a false pass. On Windows PowerShell the
equivalent is `Get-Command ffmpeg`.

FFmpeg is required for the HyperFrames render path only. Remotion bundles its own encoder, so
a Remotion-only user can skip it. After installing on Windows, open a new terminal before
re-checking — `PATH` changes do not reach an already-running shell.

### The HyperFrames suite

It is in Anthropic's official marketplace, so it installs the same way cockpit does:

```
/plugin install hyperframes@claude-plugins-official
```

That is **19 skills in one command**, verified against the installed plugin at 0.7.64 rather
than against a catalog listing:

- **Router** — `hyperframes`. Read first for any video request; it picks the workflow.
- **Domain (6)** — `hyperframes-core`, `-animation`, `-keyframes`, `-creative`, `-cli`,
  `-registry`.
- **Workflows (10)** — `product-launch-video`, `faceless-explainer`, `pr-to-video`,
  `embedded-captions`, `talking-head-recut`, `motion-graphics`, `music-to-video`, `slideshow`,
  `general-video`, `remotion-to-hyperframes`.
- **Companions (2)** — `media-use` and `figma`.

`website-to-video` is **not** among them. It exists in the plugin as a documentation guide
(`docs/guides/website-to-video.mdx`), not as an installable skill — so a routing table that
names it will find nothing. Upstream's `npx skills add` route does ship it as a skill; that is
the one capability the plugin path does not carry.

If the official marketplace is not configured:

```
/plugin marketplace add anthropics/claude-plugins-official
```

Outside Claude Code's plugin system, upstream's own installer does the same job:

```bash
npx skills add heygen-com/hyperframes --full-depth
```

**`media-use` is the one to care about beyond rendering.** Without it, requests for music,
SFX, images, icons, logos, voiceover, captions, and LUTs get hand-rolled instead of resolved
to real files. It ships inside the suite above; there is no separate install.

### Remotion

Per project, never global:

```bash
npx create-video@latest --yes --blank --no-tailwind my-video && cd my-video && npm i
```

`npx remotion upgrade` keeps both the library and its bundled skills current. maestro's
Remotion module is version-gated against the installed release, so this is worth running before
a build rather than after one breaks.

### Optional depth maestro cannot bundle

Two deliberate exclusions, not oversights. Only reach for these if you want the source material
behind a distilled module:

- **video-shotcraft previews and audio** — [Vincentwei1021/video-shotcraft](https://github.com/Vincentwei1021/video-shotcraft).
  The shot cards, tuned demos, and components are already vendored in maestro; the 108 MB
  preview gallery, the full template project, and the audio binaries are not. Browse the
  [hosted gallery](https://vincentwei1021.github.io/video-shotcraft/library.html) instead of
  cloning.
- **threejs-skills** — [CloudAI-X/threejs-skills](https://github.com/CloudAI-X/threejs-skills).
  The upstream declares **no license**, so it cannot be redistributed inside maestro. Its
  distilled module stands alone; clone the repo yourself if you want the ten source skills.

## What this costs you in context

Skill *descriptions* sit in context from the moment a skill is enabled; skill *bodies* load
only when invoked, and a vendored `library/` file costs nothing until something reads it.

Measured by summing each skill's frontmatter description (the part that is always resident),
against the actually-installed builds — cockpit 1.6.x, maestro 3.6.x, hyperframes 0.7.64:

| Installed | Skills | Always in context |
|---|---|---|
| cockpit | 8 | ~890 tokens |
| maestro | 1 | ~180 tokens |
| **cockpit + maestro** | **9** | **~1,070 tokens** |
| hyperframes suite | 19 | ~2,540 tokens |

**The hyperframes suite costs about 2.4× cockpit and maestro combined**, permanently, in every
session — because always-on cost scales with the *number* of skills, not their size. That is
why maestro is one skill with 24 reference modules rather than 24 skills: its 5 MB library and
every module in it are free until something reads them.

Numbers move between releases, and Anthropic's plugin catalog reports a higher figure for a
newer 21-skill hyperframes build than the 19-skill one measured here. Treat the ratio as the
durable part: a video suite is a couple of thousand always-on tokens, worth it if you render
video and a pure loss if you don't.

## Keeping it current

Nothing here updates itself. Each layer has its own mechanism, and `/cockpit:setup update` walks
all of them:

| Layer | Command |
|---|---|
| cockpit + maestro | `claude plugin marketplace update cockpit`, then `claude plugin update cockpit@cockpit` and `claude plugin update maestro@cockpit` |
| hyperframes suite | `claude plugin marketplace update claude-plugins-official`, then `claude plugin update hyperframes@claude-plugins-official` |
| Remotion, per project | `npx remotion upgrade` — updates the library **and** its bundled skills together |

**Refresh the marketplace first, every time.** `plugin update` compares against your local clone
of the marketplace listing, so skipping the refresh gives you a no-op that reports success. The
pair, in that order, is the whole trick.

Then `/reload-plugins`, since updates print *restart required to apply*. Confirm with
`claude plugin list` that the version column actually moved — an update that silently did
nothing looks identical to one that worked.

**maestro moves faster than cockpit, by design.** It tracks eleven upstream projects through a
pinned-commit drift checker and a weekly job that files an issue when a source repository
changes, so its version climbs on someone else's release schedule rather than its own. "I
updated last week" is not a reason to skip it.

## Non-Claude harnesses

There is no plugin system in Codex and other `AGENTS.md` harnesses. Clone both repos and point
your global `AGENTS.md` at cockpit's router:

```bash
git clone https://github.com/leobbaroni/cockpit
git clone https://github.com/leobbaroni/maestro
```

Then add to `~/.codex/AGENTS.md`:

```
Read <cockpit-clone>/AGENTS.md and follow its skill routing for process work.
For design, motion, or video work, read <maestro-clone>/AGENTS.md.
```

Steps 4 onward are identical — the prerequisites and the video toolchain do not care which
harness reads the skills. Verify by listing the cloned directories rather than with
`claude plugin list`.

## Troubleshooting

**A command doesn't show up / `/cockpit:setup` doesn't autocomplete.**
Run `/reload-plugins`, or restart. Plugin installs are not live-detected. This is the single
most common report and it is almost never an install problem.

**`Plugin "cockpit" not found` from `claude plugin update` or `enable`.**
Those subcommands want the qualified `name@marketplace` form:
`claude plugin update cockpit@cockpit`, not `claude plugin update cockpit`.

**`failed to load — Dependency "maestro@cockpit" is not installed`, with maestro `disabled`.**
You upgraded from cockpit ≤ 1.5.0, where maestro was installed separately. The existing install
was never *pulled in* to satisfy anything, so it never received the explicit enable a dependency
install writes. One command:

```bash
claude plugin enable maestro@cockpit
```

Clean installs never hit this.

**`error: unable to create file ... Filename too long` during install, on Windows.**
`MAX_PATH`. maestro's longest tracked path is 113 characters, and the standard user-scope
install lands around 176 of the 260 available — comfortable. A deep project-scope install or an
unusually long config directory can exceed it. Either install at user scope, or:

```bash
git config --global core.longpaths true
```

**Skills appear twice, or the wrong version answers.**
You have hand-installed skills in `~/.claude/skills/` shadowing a plugin's copies of the same
names — the normal result of installing by hand first and by plugin later. The plugin is the
maintained one; the hand-installed copies will never update. **Diff before deleting anything**:
distribution routes differ, and a name present locally but absent from the plugin (as
`website-to-video` is) must be kept. `/cockpit:setup` does this comparison for you and lists
what it would remove before removing it.

Worth knowing while you're in there: `npx skills add` installs into **`~/.agents/skills/`** —
the cross-tool Agent Skills location — and symlinks into `~/.claude/skills/`. Claude Code reads
only the latter, so removing a symlink resolves the shadowing while leaving the files in place
for any other tool that uses them. Run `ls -la ~/.claude/skills/` and look for `->` before
assuming an entry is a plain directory.

**Uninstalling.**

```bash
claude plugin uninstall cockpit@cockpit && claude plugin prune
```

`prune` removes maestro once nothing depends on it. Removing maestro first will be refused
while cockpit is enabled.

## Using it — start here if you've never used a skill

You do not need to learn nineteen commands. **You need one**, and the rest is the agent's job
to route to:

```
/cockpit:pilot
```

Type it with whatever you want to do after it — `/cockpit:pilot add dark mode to the settings
page`, or nothing at all if you just want to know where the project stands. Pilot reads the
repo, works out which phase you're in (planning, building, reviewing, fixing, shipping), and
runs the discipline that phase needs. **If you remember nothing else from this document,
remember that.**

You can also just describe what you want in plain English. Skills are picked up automatically
when their description matches — "make this page look better" reaches maestro, "why is this
throwing" reaches the debugging skill, "render a 30-second promo" reaches the video router. The
slash commands are for when you want to force a specific one.

### Three behaviors that surprise people

These are deliberate. They are not the tool malfunctioning:

- **Substantial work opens with an interview, not with code.** One question per turn, each with
  a recommended answer you can accept in a word. It ends with written plan files. Twenty
  minutes here routinely saves days, and small well-specified tasks skip it entirely.
- **Nothing is reported done without a check that was actually run.** A green typecheck is not
  "done"; the flow gets driven, the UI gets looked at.
- **You get asked which design house leads the look.** Structure-led, polish-led, craft-led, or
  a blend — it governs every design decision afterwards, so it is yours to pick rather than the
  agent's to assume.

### A first session that proves it works

1. Open a project — any project, even an empty folder.
2. `/cockpit:pilot` with no arguments. It should report the phase and a concrete next action.
3. `/cockpit:setup`. It should report Node, FFmpeg, and which companion skills it can reach.

If both of those produce sensible output, the install is good.

### What to type for what you want

| You want | Say |
|---|---|
| Anything, on an ongoing project | `/cockpit:pilot` |
| A plan before any code | `/cockpit:pilot plan this properly` |
| Design, UI, motion, or 3D work | `/maestro:maestro`, or just describe the design change |
| A video | Describe it — the video router picks the workflow |
| Something is broken | `/cockpit:diagnosing-bugs`, or describe the failure |
| A review before merging | `/cockpit:pilot review this` |
| Docs, a handover, or delivery cleanup | `/cockpit:handoff` |
| To know what this machine can do | `/cockpit:setup` |

### If it feels like it's doing too much

Say so, plainly, mid-run — "skip the interview", "just make the change", "don't refactor
anything else". The process is a default, not a cage, and an explicit instruction from you
outranks every ritual described above.
