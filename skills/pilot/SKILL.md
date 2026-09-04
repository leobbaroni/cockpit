---
name: pilot
description: Project-phase pilot — detects the phase, loads only that phase's ritual, and enforces its discipline. Use on "plan / spec this out", "init / kick off / start building X", "review this / check the PR", "improve / refine / polish", "what's next / continue", "debug this", "deliver / handout", or any vague build/improve/review request that names no concrete task. Prevents the four expensive failures: building before the spec is frozen, improving without criteria, reviewing by vibes, debugging without a repro. NOT for a single concrete edit, a pure task-batch handoff (orchestrate), or design/UI/video work already named for maestro.
argument-hint: "[phase: plan|kickoff|build|review|improve|debug|deliver — or a task]"
---

# Pilot

Read the project's state, declare the phase, **load that phase's node and nothing else**, run its ritual. This file is the router; the rituals live in `nodes/`, the state contract in `STATE.md`, the per-edit discipline in `CONTRACT.md`, the outside-pack routing in `ROUTING.md`. Load one node per turn — loading them all is the cost this structure exists to remove.

## Step 0 — read state, declare the phase

Cheap and deterministic, in this order:

1. **If this is a git repo** (`git rev-parse --git-dir` succeeds): `git log --oneline -5` and `git status --short`. If it isn't, say so in four words and skip — never fail the opener on a folder that has no history yet.
2. Tail of `PROJECT_LOG.md` (last dated section) if it exists — what the previous session left open.
3. Existence check: `SPEC.md`, `PLAN.md`, `CONTEXT.md`, a test command, a dev-server config.

Then declare, in two lines: **"Phase: <X> — because <signal>. Next: <concrete action>."** An explicit phase argument from the user always beats detection.

| Signal | Phase | Load |
|---|---|---|
| "plan / spec this out / don't build yet", or a plan-only session | **PLAN** | `nodes/plan.md` |
| No SPEC/PLAN and the user describes something worth more than one session | **KICKOFF** | `nodes/plan.md` (it ends by handing to BUILD) |
| PLAN exists with open items; "continue / next" | **BUILD** | `nodes/build.md` |
| "review / audit / check this diff / is this ready" | **REVIEW** | `nodes/review.md` |
| "improve / better / polish / refine", bare "cleanup" | **IMPROVE** | `nodes/improve.md` |
| Something is broken with unknown cause, or a fix "still" fails | **DEBUG** | `nodes/debug.md` |
| "handout / manual / log / deliver / cleanup for others" | **DELIVER** | `nodes/deliver.md` |

**When signals collide, the earliest unmet ritual wins**: DEBUG > REVIEW > IMPROVE > DELIVER. A broken thing gets a repro before a review; a review's findings feed the improvement; delivery comes last.

## The graph, in one paragraph

pilot is a small task graph and is run as one. The phases are **nodes** — each a job with one job — and they exchange work only through **state on disk** (`STATE.md` says which files, who may write each, and which are frozen). Every node has a **human gate** where a mistake is expensive to undo, and *only* there: a gate on every step makes the user the bottleneck; a gate on none means nobody is watching. And the graph is judged on **anchors** — tests that ran, a check that exited 0, an approval the user actually gave — never on its own self-report. The four gates in `CONTRACT.md` are prose you read and can rationalize past; the anchors are the part you can't.

## What every node does regardless

- **Runs `CONTRACT.md` on every edit** — restate, scope, tripwire, fresh evidence. Read it once per session; it is short on purpose.
- **Writes only the state files its row in `STATE.md` allows.** One writer per file. A node that needs to change a file it doesn't own hands back to the node that does.
- **Fans out only through `orchestrate`**, which owns the crew proposal, the stop rule, and the model routing. pilot never proposes a crew itself.
- **Routes outside the pack through `ROUTING.md`** — and when the specialist isn't installed, does the work directly to the same standard and says so. Never fail a task because an optional specialist is absent; never install one without asking.

## Standing interceptors

- **Five or more asks in one message:** echo them back as a numbered list before working; report per item DONE / NOT DONE / PARTIAL at the end. Silent omission is the failure this exists to prevent.
- **The user states a rule mid-session** ("X always counts as Y"): it's a spec correction — append it to `SPEC.md` (or `CONTEXT.md` for a term) **now**, and cite the file in your reply. It must survive a context reset.
- **A fact you can't source is an assumption**, in every phase. Versions from the lockfile, API shapes from docs read this session, timings from a measurement you took. Memory is never a source.
- **Destructive or irreversible steps get their own confirmation**, naming the irreversibility, with a backup or rollback in the plan.
- **Paid actions** state the estimated cost and get a yes before anything non-trivial.

## Harness notes

- **Claude Code:** batched decisions via AskUserQuestion; fan-out and review waves via `orchestrate` and its subagents; PLAN pairs with plan mode.
- **Codex and other AGENTS.md harnesses:** questions as plain text one at a time with a recommended answer; no subagents, so `orchestrate` runs its batch sequentially and its "crew" shrinks to an ordering-and-escalation decision; PLAN writes the planning files and touches nothing in `src/`.
