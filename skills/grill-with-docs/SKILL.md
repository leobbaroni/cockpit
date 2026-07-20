---
name: grill-with-docs
description: Like /grilling, plus docs — a relentless interview to sharpen a plan or design that also creates ADRs and a glossary (CONTEXT.md) as decisions land.
disable-model-invocation: true
argument-hint: "[the plan, design, or idea to stress-test]"
---

Load BOTH the `grilling` skill and the `domain-modeling` skill (on Claude Code, invoke them via the Skill tool — actually invoke them, don't just apply their ideas; on other harnesses, open both skill files and follow them together), then run the interview on the plan given in the arguments.

As decisions crystallise during the interview — not at the end — capture them per domain-modeling's rules: glossary terms into `CONTEXT.md`, hard-to-reverse choices into `docs/adr/`.

When the interview concludes, persist the outcome: write or update `PLAN.md` with the agreed scope and build order, and offer a done-condition the user can drive the build with (e.g. a goal statement such as "complete PLAN.md build order; done when `npm run build` passes").
