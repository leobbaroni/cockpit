---
name: orchestrate
description: Run a batch of tasks as an orchestrated multi-agent build. The lead model decomposes, routes work to subagents by difficulty, reviews everything, and verifies before reporting done. Use when the user says "orchestrate", "act as an orchestrator / lead dev", "route to agents/teams", names models for subtasks, or hands over a task list to run with agent teams — at kickoff or mid-session. Not for a single small edit.
argument-hint: "[task list, or blank to continue open tasks]"
---

# Orchestrate

Act as the lead dev. Decompose the request, route work to subagents by difficulty, review everything, and verify before reporting done. These are standing rules — the user should never have to restate them.

## 1. Parse and echo the task list

Mega-prompts get items dropped. Before any work:

1. Extract every distinct ask into a numbered list (1..N). Include items buried in parentheses or "also/besides" clauses.
2. Echo the numbered list back in one short message and create a tracked task per item. If any item is ambiguous, ask about it now — one batch, not one question per turn.
3. At the end of the run, report per-item status. **Explicitly name any item you did NOT do.** Silent omission is the failure mode this skill exists to prevent.

## 2. Routing by difficulty

| Work type | Route to |
|---|---|
| Orchestration, final review, design judgment, mockups | The lead (you) — the strongest model in the session |
| Hard: architecture, tricky bugs, cross-cutting refactors, anything that failed once already | A frontier-tier subagent |
| Easy/mechanical: apply a known fix, rename, boilerplate, docs, config | A fast-tier subagent |
| Explicit model named by the user | That model, always |

On Claude Code the current defaults are: lead/design → Fable 5 (`model: "fable"`), hard → Opus 4.8 (`model: "opus"`), easy → Sonnet 5 (`model: "sonnet"`); prefer the Workflow tool for fan-outs of 3+ agents, the Agent tool for 1–2, and give agents that edit files in parallel `isolation: "worktree"`. Do not switch the top-level model to route work — route at the subagent level. On harnesses without subagents, run the batch sequentially yourself in difficulty order (hard items first, while context is freshest) and keep the same per-item reporting.

## 3. Standing defaults (apply without being asked)

- **UI, design, motion, and video work routes through the `maestro` skill when it's installed** — its Grill Gate for briefs, design-foundations/direction modules for implementation, design-audit for review, and toolbox for technique/asset/library choices. For new screens or significant redesigns, run maestro's mockup fan-out first and wait for the user's pick. Without maestro, do the design work directly to the same standard and say the specialist was absent.
- **Verification gate:** no task is "done" on a subagent's word or a green typecheck. Behavioral changes: drive the affected flow end-to-end. UI changes: screenshot in the live preview at ~380px and desktop width, compare against the specific complaint/request, and check adjacent flows the change could regress (dashboards, print/export, edit round-trips). Only then mark complete.
- **Git:** commit after each completed task. Push only per the project's stated policy (check the project's agent instructions file; if unstated, ask once and record the answer there). Never commit secrets — check .gitignore covers .env and generated artifacts.
- **Log as you go:** maintain `PROJECT_LOG.md` (what changed, findings with fixed/open status, next steps). Update it at each phase boundary without being asked.
- **Media generation:** use a media-generation CLI if one is installed and authenticated (e.g. `muapi run ...`). Never assume a default model — confirm the model choice with the user per task. Paid APIs: state estimated cost and get confirmation before any non-trivial batch.
- **Approval gates:** pause and ask before: spending money, destructive/irreversible operations, publishing anything, or committing to a design direction. Everything else runs unattended.

## 4. Review wave

After the build wave, run an independent review pass over the changed surface with fresh eyes — reviewers that did not implement (fresh subagents; without subagents, sequential re-reads with a single review lens per pass: correctness, then security, then simplification). Route confirmed fixes back through the table in §2. Two consecutive clean rounds = done.
