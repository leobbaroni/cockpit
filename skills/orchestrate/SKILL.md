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
| Orchestration, final review, design judgment, mockups | The lead (you) — **on the model the session is set to** |
| Hard: architecture, tricky bugs, cross-cutting refactors, anything that failed once already | A frontier-tier subagent |
| Easy/mechanical: apply a known fix, rename, boilerplate, docs, config | A fast-tier subagent |
| Explicit model named by the user | That model, always |

**The session model is the lead and the designer.** Whatever the user selected runs orchestration, design judgment, and final review — never demote it to save cost, never hand lead work to a subagent on a different model, never switch the top-level model to route work. **The lead role is what never moves**; implementation routes around it in three directions: *down* to the fast tier for mechanical items, *up* to the strongest reasoner for hard implementation (routing a hard subtask up is not a demotion — the lead still decomposes, reviews, and decides), and *sideways* to a different model for adversarial review. When the session model is already the strongest reasoner available the up-route is a no-op and lead and hard are one tier — say so instead of inventing a split.

On Claude Code the current defaults are: lead/design → the session's own model (unchanged), hard → Opus 5 (`model: "opus"`), easy → Sonnet 5 (`model: "sonnet"`; Haiku 4.5 for trivial bulk); prefer the Workflow tool for fan-outs of 3+ agents, the Agent tool for 1–2, and give agents that edit files in parallel `isolation: "worktree"`. On harnesses without subagents, run the batch sequentially yourself in difficulty order (hard items first, while context is freshest) and keep the same per-item reporting.

**Announce the crew before spending on it.** If `pilot` already proposed a model mapping and the user accepted it, use that mapping and do not re-ask. Otherwise state the assignment in one short table (task or dimension → role → model) before the first agent runs, and invite correction — the user may know a step deserves a stronger model than its difficulty suggests. Any model the user names explicitly wins over these defaults, always. Escalate a step to the stronger tier when it fails once; say so when you do, rather than silently re-running it bigger.

## 3. Write the prompt as if the agent can never ask you anything

Because it can't. A subagent starts cold: no conversation, no prior turns, none of the reasoning that made you choose this task, this approach, this file. **Whatever is not in the prompt does not exist for it.** The lead holds the full context and the delegation prompt is the only channel it travels through — a thin prompt throws that context away and buys back generically-correct, contextually-wrong work.

Over-specify on purpose. A long prompt costs tokens once; a misunderstood task costs a rewrite, a review cycle, and the user's trust. Every delegation carries:

| Block | What goes in it |
|---|---|
| **Objective** | The outcome in one or two sentences — what is true when this is done, not the activity |
| **Why this way** | The reasoning behind the approach, and the alternatives you already considered and rejected, with the reason. Prevents both re-litigation and silent drift into an approach you ruled out |
| **Context** | Concrete paths, symbols, commands, and the findings that led here. Paste the actual error text, the actual snippet, the user's actual words — never "the file mentioned above" or "as discussed" |
| **Constraints & non-goals** | What must not change, the conventions to match, the approaches that are banned and why. Usually the highest-value line in the whole prompt |
| **Acceptance criteria** | How the agent proves it worked — the command to run, the flow to drive, the state to observe. Not "make sure it works" |
| **Output contract** | Exactly what to return: a summary of edits, a ranked findings list, a structured object. Say whether it edits files or only reports |
| **Escalation** | What to do when an assumption turns out false or it gets blocked: report back with what it found, rather than guessing or half-finishing |

Rules that carry the intent:

- **Give the reasoning, not just the conclusion.** "Use the existing `formatMoney` helper" tells it what to type; "use `formatMoney` — it handles the minor-unit rounding that broke invoicing last month, so don't hand-roll `toFixed`" lets it adapt when reality differs from your assumption. The second one survives surprises.
- **Quote the user verbatim** for anything about taste, tone, priority, or preference. Your paraphrase is already a lossy compression of the thing the work will be judged against.
- **One agent, one bounded deliverable.** If you can't state its acceptance criteria in a sentence, it's two tasks.
- **For parallel agents, state the boundary explicitly** — which files or modules are theirs, and that they must not touch the others' — or they collide and you arbitrate merges instead of reviewing work.
- **Say what "done" is not.** Name the tempting-but-wrong finish ("do not also refactor the surrounding component", "do not add tests for unrelated paths") — scope creep in a subagent is invisible until review.
- **Review prompts get the same treatment, aimed adversarially:** the specific claim to attack, what evidence would refute it, and an instruction to verify against the real file before reporting — never "review this code".
- **Never assume shared vocabulary.** Project codenames, your own shorthand from earlier turns, and abbreviations you invented mean nothing to a cold agent. Spell them out once.
- **When the batch came from a plan, mine it instead of paraphrasing it.** A plan written per `grilling`'s format was already written for a stranger, so it holds six of the seven blocks outright: the phase's `Done when:` is the acceptance criteria, its `Covers:` requirements are the objective, Out of Scope & Parked Items is the non-goals block, Key Decisions carry the reasoning behind the approach, and the Assumptions Ledger rows that phase checks are exactly what the agent must verify before building on them. Copy them across verbatim — re-deriving a thinner version from memory is how a locked brief silently loosens.

Read the returned work against the prompt you actually wrote before accepting it. When an agent misses, check the prompt first — most misses are missing context, not a weak model, and re-running with a better prompt beats escalating a tier.

**On harnesses without subagents**, write the same seven blocks as your own working brief before starting each item, and read the result against it the same way. The contract is a thinking checklist first and a delegation format second — writing down the rejected alternatives and the acceptance criteria catches the same drift whether the reader is another agent or you in twenty minutes.

## 4. Standing defaults (apply without being asked)

- **UI, design, motion, and video work routes through the `maestro` skill when it's installed** — its Grill Gate for briefs (including the user's pick of which design house leads, which is theirs to make, not yours), page-anatomy for page shape and theme, design-foundations/direction for implementation, design-audit for review, and toolbox for technique/asset/library choices. When a request names a design action — audit, critique, redesign, study a reference, polish, bolder, typeset, brand kit — maestro's `commands` module maps it to that source project's real protocol; run the protocol rather than an approximation. For new screens or significant redesigns, run maestro's mockup fan-out first and wait for the user's pick. Without maestro, do the design work directly to the same standard and say the specialist was absent.
- **Verification gate:** no task is "done" on a subagent's word or a green typecheck. Behavioral changes: drive the affected flow end-to-end. UI changes: screenshot in the live preview at ~380px and desktop width, compare against the specific complaint/request, and check adjacent flows the change could regress (dashboards, print/export, edit round-trips). Only then mark complete.
- **Git:** commit after each completed task. Push only per the project's stated policy (check the project's agent instructions file; if unstated, ask once and record the answer there). Never commit secrets — check .gitignore covers .env and generated artifacts.
- **Log as you go:** maintain `PROJECT_LOG.md` (what changed, findings with fixed/open status, next steps). Update it at each phase boundary without being asked.
- **Media generation:** use a media-generation CLI if one is installed and authenticated (e.g. `muapi run ...`). Never assume a default model — confirm the model choice with the user per task. Paid APIs: state estimated cost and get confirmation before any non-trivial batch.
- **Approval gates:** pause and ask before: spending money, destructive/irreversible operations, publishing anything, or committing to a design direction. Everything else runs unattended.

## 5. Review wave

After the build wave, run an independent review pass over the changed surface with fresh eyes — reviewers that did not implement (fresh subagents; without subagents, sequential re-reads with a single review lens per pass: correctness, then security, then simplification). Give each reviewer the §3 treatment: the change's stated intent, the specific risks you suspect, and an instruction to verify every finding against the real file before reporting it. Route confirmed fixes back through the table in §2. Two consecutive clean rounds = done.
