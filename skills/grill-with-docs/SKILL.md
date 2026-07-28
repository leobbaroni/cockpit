---
name: grill-with-docs
description: Like /grilling, plus docs — a relentless interview to sharpen a plan or design that also creates ADRs and a glossary (CONTEXT.md) as decisions land.
disable-model-invocation: true
argument-hint: "[the plan, design, or idea to stress-test]"
---

Load BOTH the `grilling` skill and the `domain-modeling` skill (on Claude Code, invoke them via the Skill tool — actually invoke them, don't just apply their ideas; on other harnesses, open both skill files and follow them together), then run the interview on the plan given in the arguments.

`grilling` owns the interview: look before you ask, one question per turn with a recommended answer and a visible open-fork count, every fact tagged as stated / verified / assumed, and both gates run before the plan is handed over. Its `TRACKS.md` sets which slots this particular kind of work must decide; its `PLAN-FORMAT.md` sets where each section lands.

As decisions crystallise during the interview — not at the end — capture them per domain-modeling's rules: glossary terms into `CONTEXT.md`, hard-to-reverse choices into `docs/adr/`. A term pinned in `CONTEXT.md` is a `(verified: CONTEXT.md)` source for the rest of the interview; an ADR records what would have changed the answer.

When the interview concludes, persist the outcome per `PLAN-FORMAT.md` — `SPEC.md` for the contract, `PLAN.md` for the build order, Assumptions Ledger, and risks — and offer a done-condition the user can drive the build with (e.g. "complete PLAN.md build order; done when `npm run build` passes").
