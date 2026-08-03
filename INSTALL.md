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

That is 21 skills in one command — the `/hyperframes` router, the domain skills
(`-core`, `-animation`, `-keyframes`, `-creative`, `-cli`, `-registry`, `-media`), the workflow
skills (`product-launch-video`, `faceless-explainer`, `pr-to-video`, `embedded-captions`,
`talking-head-recut`, `motion-graphics`, `music-to-video`, `slideshow`, `general-video`,
`website-to-video`, `remotion-to-hyperframes`), plus **`media-use`** and **`figma`**.

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

| Installed | Always in context | Loaded on invoke |
|---|---|---|
| cockpit + maestro | ~900 tokens (9 descriptions) | Per skill, on demand |
| hyperframes suite | ~4,850 tokens (21 descriptions) | ~123,000 tokens across the suite |

Worth sitting with: **the hyperframes suite costs roughly five times cockpit and maestro
combined**, permanently, in every session — because always-on cost scales with the *number* of
skills, not their size. maestro's 5 MB library is free until read. If you do not render video,
not installing the suite is a real saving, and if you do, it is worth every token.

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
You have hand-copied skills in `~/.claude/skills/` shadowing the plugin's. Delete the personal
copies; the plugin is the maintained one and updates with `claude plugin update`.

**Updating.**

```bash
claude plugin marketplace update cockpit && claude plugin update cockpit@cockpit
```

Updates print *restart required to apply* — the running session keeps the old skill bodies
until you reload or restart.

**Uninstalling.**

```bash
claude plugin uninstall cockpit@cockpit && claude plugin prune
```

`prune` removes maestro once nothing depends on it. Removing maestro first will be refused
while cockpit is enabled.

## After the install

`/cockpit:pilot` is the entry point for any ongoing or new project — it detects the phase and
enforces that phase's ritual. Two behaviors are intentional and are not the tool being
difficult: **substantial work opens with an interview** rather than with code, and **nothing is
reported done unverified**. One of the interview's questions is which design house leads the
look; that pick is yours, and it governs the rest of the project.
