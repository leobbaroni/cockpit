# Plan format

The plan is written for a competent developer with zero context of the interview: explicit,
jargon-free, self-contained. No "as discussed", no "the file mentioned above". Depth scales with
the ask — never pad, never omit a section. A section with nothing in it says "none" **plus a
basis** ("No persistent data — decided, not omitted"); it never silently disappears.

## Where each section lands

Cockpit splits the plan across the project's durable artifacts so each one has a single owner.
Write the sections into the files, not into chat.

| File | Sections |
|---|---|
| **`SPEC.md`** — the contract | Classification · Goal & Success Criteria · Scope (v1) · Out of Scope & Parked Items · Requirements · Key Decisions · Data & State Changes · Interfaces, Integrations & Credentials · Edge Cases & Failure Handling |
| **`PLAN.md`** — the build | Current State · Approach · Build Phases · Verification · Risks, Landmines & Adaptations · Assumptions Ledger · Open Items · Interview Ledger |
| **`CONTEXT.md`** · **`docs/adr/`** | Glossary terms and hard-to-reverse decisions, per the `domain-modeling` skill — written as they crystallise during the interview, not at the end |

Track-specific sections (`TRACKS.md`) slot in where they fit: evidence-shaped ones — Reproduction,
Verified API Facts, Baseline & Target, Breaking-Change Inventory, Design Reference — go in
`SPEC.md`; work-shaped ones — Ranked Hypotheses, Safety Net, Rollback Plan, Spike Plan, Polish
Backlog — go in `PLAN.md`.

When there is no project to write into — a bare question, a chat-only harness — emit the whole
skeleton as one titled markdown document in the reply instead. Same content, one file's worth.

## The skeleton

```markdown
# Plan: <one-line title>

One-line goal: what is true when this ships that is not true now.

## Classification
Track: <track> — <one line why>. Parked secondary asks: <named, or "none">.

## Interview Ledger
One line per question spent: "Q3 export scope → exclude soft-deleted (accepted)". Mark any whose
answer changed no line of this plan — that one failed the necessity test in hindsight, and two of
them in a single interview mean the bar for asking is set too low. Close with the count.

## Goal & Success Criteria
- <observable, testable — "a user can X and sees Y", never "works well"; numbers where degree matters>

## Current State
- <fact> (verified: `<source>`) / <fact> (user)    <from scratch: emptiness confirmed; environment facts>

## Scope (v1)
<the thinnest valuable slice>

## Out of Scope & Parked Items
- <every cut, deferral, or displaced ask — named, with a one-line reason. None silently dropped>

## Approach
<mechanism, track-flavored: hypotheses for bugs, strategy for migrations, matrix summary for
decisions, walking skeleton for greenfield. Mark latitude: "executor's choice: internal layout">

## Requirements
Numbered R1, R2… and testable: "WHEN <trigger> THE SYSTEM SHALL <behavior>". Business rules
explicit ("a user cannot submit the same form twice"), never implied. Each carries an
acceptance check.

## Key Decisions
- <decision>: <choice> — (user | verified: `<source>` | [assumed: default — if wrong: <line>])

## Data & State Changes
<schema and data changes with migration and rollback notes, or "none" + basis>

## Interfaces, Integrations & Credentials
<APIs exposed and consumed with request/response shapes; external deps with versions
(verified: `<source>` | [assumed]); secrets as ${ENV_VAR} per the project's convention; fixed
contracts flagged — or "none" + basis>

## Edge Cases & Failure Handling
- <case> → <behavior>    (default posture: fail loudly with a clear message)

## Risks, Landmines & Adaptations
- <constraint discovered> → <how the plan visibly adapts>
- <residual risk> → <mitigation, or the check that covers it>    <or "none found — probed <what>">

## Assumptions Ledger
| ID | Assumption | Basis | Blast radius if wrong | Check |
|----|-----------|-------|----------------------|-------|
| A1 | <default adopted without asking> | convention (verified) | <what moves> | <phase / check> |

Every default adopted without asking lives here. Inline references elsewhere use [A1].

## Open Items (none blocking)
- <item> — proceed with <default> unless told otherwise

## Verification
- <exact command, test, or observable check — "it should work" is not a step>
- <how the user personally confirms it's done>

## Build Phases
- [ ] Phase 1: <imperative title>
      Done when: <exact command, test, or observable behavior>
      Steps: <2–6 bullets an executor runs directly>
      Covers: <R#s>; checks: <A#s>
- [ ] Phase 2: <title>
      Done when: <check>
      Steps: <bullets>
```

## Build Phases contract

Phase lines are exactly `- [ ] Phase N: <title>`; `Done when:`, `Steps:`, and `Covers:` sit
indented beneath, never inline. **Twelve phases maximum.** Each phase is small, independently
verifiable, traceable to requirements, and provable by its done-check — a phase whose completion
cannot be proven is malformed. Early phases deliver the working core.

Track invariants bind (`TRACKS.md`): bug fix reproduces first; performance measures first;
migration reads the changelog first and deletes the old path last; integration verifies API
shapes first; refactor builds the safety net first; from scratch walks the skeleton through the
riskiest unknown first. **Any phase depending on an `[assumed]` item verifies it in its first
step or states its fallback.** Where a test suite exists, each phase writes its failing test
first.

## The two gates

Run both silently before handing the plan over. Fix the document where either fails — as a
decision or an Assumptions Ledger row with a check, **never by reopening the interview**.

**Completeness gate.** Zero open questions or clarification markers survive; every unknown became
a tagged assumption with a default and a basis. Run the **provenance scan**: every factual
sentence carries exactly one status, and any `(verified)` whose source is a knowledge claim —
memory, training, "general knowledge" — is demoted to `[assumed]`. Every requirement is testable.
Every vague adjective is a number or an observable. Every surfaced landmine has a visible
adaptation. Frameworks are used directly, with no speculative abstraction; complexity beyond
present need carries a one-line justification.

**Executor gate.** Reread the plan as the stranger who will execute it, told only "execute this
plan", and walk the build phases once more. Anywhere you would stop and ask the user something,
the plan is incomplete. Phase 1 verifies the riskiest surviving assumptions before anything
builds on them.

## Completion bar

Approval-ready when all of these hold:

- Every core section is filled, or carries an explicit "none" with a basis.
- The track's decisive slots are each decided (user or verified) or defaulted with an `[assumed]`
  tag and a hedge.
- The provenance scan passes — no untagged claim of fact, in the plan or in the interview.
- No load-bearing assumption is unverified without a hedge.
- The coverage sweep found no plan-changing gap left unaddressed.
- Verification lists exact runnable checks, and the build phases are well-formed with done-checks.
- The plan survives the executor gate: readable as a standalone execution prompt, zero follow-up
  questions needed.
