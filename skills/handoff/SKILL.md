---
name: handoff
description: End-of-phase packaging. Update PROJECT_LOG.md (changes, findings fixed/open, next steps), write how-to-run + revert guides, produce polished manuals in the requested languages (.docx or .md), and clean the repo of AI artifacts for final delivery. Use when the user asks for a change log, handout, user guide/manual, "next steps" doc, revert instructions, "log all that was changed", or delivery cleanup ("remove unnecessary/AI files"). For a promo/demo/teaser/product video of the app, use HyperFrames (/hyperframes) or Remotion (maestro's video-remotion module), not this skill. Not for code documentation like README API docs.
argument-hint: "[log | guide | manual | delivery] [languages, e.g. EN PT]"
---

# Handoff

Turn a work phase into durable, human-readable deliverables. Pick the mode from the argument or infer it; when the user says "prepare everything", run log → guide → delivery in that order. (Promo/demo videos are not a handoff mode: use HyperFrames or Remotion.)

## Mode: log (default)

Create or update `PROJECT_LOG.md` at the repo root. Append a dated section per work phase:

- **Changed** — what was built/modified, by area, one line each.
- **Findings** — issues discovered, each marked `fixed` or `open`.
- **Next steps** — concrete, ordered; the next session should be able to start from this list alone.
- **Revert notes** — for risky changes: what to undo and where (files, commits, config), so another user/agent can roll back without this conversation.

Never rewrite history in the log — append. Keep entries terse; this file is read at every session start.

## Mode: guide

A `HANDOUT.md` (or user-named file) for the next human/agent: how to run the app (exact commands, ports, env vars by NAME only — never paste secret values), what was configured on this machine vs. in the repo, known flaky spots and their workarounds, and where the log/manual live.

## Mode: manual

A polished end-user manual: how to use the app, maintain it, and troubleshoot — written for a non-technical reader, with screenshots of the real UI (capture from the live preview, not mockups).

- Languages: produce the requested languages (e.g. EN and PT); when multiple are requested, keep the structure identical between versions.
- Format: `.docx` when the deliverable is a document to send (via a docx skill if the harness has one, else generate the file directly); `.md` when it lives in the repo.

## Promo / demo videos: HyperFrames or Remotion (the agent decides, or both)

Promo, demo, teaser, and product-film videos are NOT a handoff mode. Two animated-video toolchains may be installed; choose per the job (or combine them), don't hand-roll a bespoke pipeline:

- **HyperFrames** (`/hyperframes`) — renders video from animated HTML/GSAP; routes to its own workflows (product-launch-video, general-video, motion-graphics, website-to-video, etc.). Strong for bespoke UI-recreation promos, a linted check/snapshot/render loop, and template-driven product launches. Needs Node ≥ 22 and a standalone ffmpeg on PATH.
- **Remotion** (maestro's `video-remotion` module) — React/TSX compositions rendered to MP4 via `remotion render`. Strong when you already have React components, want frame-precise programmatic control, or reuse an existing Remotion project; it bundles its own encoder (no external ffmpeg).

Decide from the starting asset and the look you want; you may use both in combination. When unsure, read `/hyperframes` (its router also covers when a specialized workflow fits) and pick from there. If neither toolchain is installed, say so and point at maestro's README dependency table rather than improvising a pipeline.

## Mode: delivery

Final-delivery cleanup, in this order:

1. **List first, delete second.** Enumerate candidate junk: AI-generated scratch files, mockup HTML, agent-config project files, throwaway scripts, generated media not referenced by the app. Show the list and get confirmation before deleting anything you didn't create this session.
2. Verify `.gitignore` covers `.env`, secrets, and generated artifacts; confirm no secret values are committed anywhere in history you're about to push.
3. Refresh README for the final structure (structure only for gitignored assets — link, don't embed).
4. If the audience is non-technical, add a one-click launcher (e.g. a `.bat`/`.cmd` or shell script that installs deps and starts the app).
5. Run the app once end-to-end after cleanup to prove deletion broke nothing.
