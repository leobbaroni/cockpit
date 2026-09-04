# BUILD node


Take the next open PLAN.md item (or the user's named task). Run every change through `CONTRACT.md` — restate, scope, tripwire, fresh evidence. Route outside the pack through `ROUTING.md` before improvising.

**The build loop, in order.** Each step exists because skipping it makes a later step lie:

1. **Isolate.** Anything multi-file, or any batch, starts in an isolated workspace — `using-worktrees`. It also takes the **baseline test run**, without which you cannot tell your regression from one that was already there.
2. **Red.** The failing test comes before the implementation — `test-driven-development`. A bug fix starts with a test that reproduces it; a feature starts with a test that demands it. A test you never watched fail is a test you never watched work.
3. **Green, minimally.** The least code that passes, then the **whole** suite — a local green with three regressions elsewhere is a red.
4. **Refactor while green**, running the tests after each step.
5. **Verify behaviorally** — drive the flow, screenshot at ~380px and desktop. A typecheck is not a verification.
6. **Commit** per the project's push policy and append one line to `PROJECT_LOG.md`.

Batches of 3+ tasks → propose the crew, then `orchestrate`. Never start implementation on `main`/`master` without the user's explicit say-so.
