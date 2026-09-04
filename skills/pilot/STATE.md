# State — what travels between phases, and who may write it

*State drift is the way a graph rots. Every phase reads and writes these files; nothing else carries work across a phase boundary or a context reset. Read this before writing any of them.*

## The files

| File | Written by | Read by | Frozen? |
|---|---|---|---|
| `SPEC.md` | **PLAN** creates it. Afterwards **append-only**: corrections land under a dated `## Corrections` heading, never as edits to the frozen text | Every phase | **Yes, after PLAN.** It is the anchor the build is judged against; a build that rewrites its own acceptance criteria has not passed them |
| `PLAN.md` | **PLAN** creates it. **BUILD** checks items off and records each phase's evidence. Nobody else | BUILD, REVIEW | The build order is frozen; the checkboxes are not |
| `CONTEXT.md`, `docs/adr/` | **PLAN**, and any phase through `domain-modeling` | Every phase | ADRs are append-only by construction |
| `PROJECT_LOG.md` | **Every phase**, one dated entry per session, append-only | Step 0 of the next session | Never edited, only extended |
| The test suite | **BUILD** — red first, then green (`test-driven-development`) | Every phase, as the anchor | — |
| Code | **BUILD**, and REVIEW/IMPROVE/DEBUG through BUILD's loop | — | — |

**One writer per file.** When a phase needs to change a file it does not own, it hands back to the phase that does — a REVIEW that finds the spec wrong records a finding for PLAN; it does not edit `SPEC.md`. This is the rule that keeps two sessions from silently overwriting each other, and it costs nothing to keep.

## What a phase must leave behind

A node is done when the next node — possibly in a different session, on a different model — can start **without asking anything it could have read.** Concretely:

| Leaving | Must exist on disk |
|---|---|
| PLAN | `SPEC.md` (frozen), `PLAN.md` with `Done when:` on every phase, the Assumptions Ledger, a done-condition the user can drive the build with |
| BUILD | The item checked off in `PLAN.md` **with the evidence pasted** (the command and its output), a commit, one line in `PROJECT_LOG.md` |
| REVIEW | Findings ranked by severity, each anchored to `file:line` with its failure scenario, in the log — and a routing line saying which go to BUILD and which are declined, with reasons |
| IMPROVE | The done-condition it was measured against, and the measurement |
| DEBUG | The repro (a command that fails), then the regression test that guards it |
| DELIVER | Whatever `handoff` produced, and the log closed out |

## Anchors — what the graph may not rewrite

An anchor is an external, fixed reference the optimizing machinery is forbidden to change. Without them a system becomes perfectly self-consistent while drifting arbitrarily far from what was asked. These are pilot's:

- **`SPEC.md`'s acceptance criteria**, once frozen. Corrections are appended with a date and a reason, so the drift is visible rather than silent.
- **The test suite's verdict.** A failing test is a fact about the code, not a negotiation. Tests may be *added*; a test may be *changed* only when the behavior it asserts was wrong, and that change is called out by name.
- **`check-pack.mjs`, `check-upstreams.mjs`, and any repo-owned check** — they exit non-zero or they don't. Their word beats yours.
- **The user's actual approval.** Not silence, not a successful run, not your own preference. A human gate is a person saying yes to a specific artifact.

When a node's output contradicts an anchor, the node is wrong. Not sometimes — by definition. That is what an anchor is for.

## Separated speeds

Not every loop runs at the same rate, and mixing them is how a fast loop rewrites what a slow one decided. In pilot: the **edit loop** (CONTRACT, per change) runs fastest; the **phase loop** (a node's ritual, per task) sits above it; the **plan loop** (SPEC/PLAN, per feature) above that; and the **user's intent** above everything, on whatever cadence the user chooses. A faster loop may *report up* to a slower one — a build that keeps hitting the same wall reports a plan problem — but may not *reach up* and change its target. That is what the frozen column is enforcing.
