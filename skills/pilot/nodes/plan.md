# PLAN node


For "plan this properly" requests and every KICKOFF. The product is a plan another session — or another agent — can execute without re-asking anything.

1. **Interview first.** Run the `grilling` skill — it owns the discipline: look before you ask, one question per turn with a recommended answer, the open forks counted down in every turn, and every fact tagged `(user)` / `(verified: source)` / `[assumed: default — if wrong: …]`. When new domain terms or hard-to-reverse choices surface, fold in `domain-modeling` (that pairing is the `grill-with-docs` skill). Twenty minutes of interviewing is cheaper than days of spec-correction rounds.
2. **Pick the track, not just the phase.** The phase says which ritual applies now; the track (`grilling/TRACKS.md`) says what this plan must decide and which invariants bind its build phases — bug fix reproduces first, performance measures first, migration deletes the old path last, from scratch walks a skeleton through the riskiest unknown. Pick it silently and record it in the plan's Classification section, with every displaced ask parked by name.
3. **Freeze into files, not chat**, per `grilling/PLAN-FORMAT.md`:
   - `SPEC.md` — the contract: goal and success criteria, scope and non-goals, numbered testable requirements, key decisions with their provenance, data/interface/credential changes, edge cases, spec corrections as they land.
   - `PLAN.md` — ordered build phases, each small enough to verify alone, each with its acceptance check written as a command or observable behavior (`Done when: <check>`). Plus the **Assumptions Ledger** — every default adopted without asking, with its basis, blast radius, and the phase that checks it — and Risks & Landmines, where each discovered constraint names how the plan visibly adapted. Unknowns become named spike steps, not guesses.
   - `CONTEXT.md` + `docs/adr/` — terms and decisions, per `domain-modeling`.
4. **Run both gates before handing it over** (`grilling/PLAN-FORMAT.md`): the completeness gate, including the provenance scan that demotes any "verified" whose source was memory rather than a file, command, or artifact read this session; and the executor gate — reread the plan as the stranger who will build from it, told only "execute this plan", and fix anywhere they would have to stop and ask.
5. **Offer a done-condition** the user can drive the whole build with ("complete PLAN.md build order; done when `npm run build` passes and tests are green").
6. **Hard stop.** PLAN mode writes planning artifacts only — no scaffolding, no "small head start". End by offering the handoff: continue into BUILD here, or hand PLAN.md to `orchestrate` as a batch — and if it's the batch, hand it to `orchestrate`, which proposes the crew so the plan ships with its model assignment settled.



## KICKOFF


Run PLAN in full (never skip the interview for a multi-day build), ask once for the project's push policy and record it in the project's agent instructions file (`CLAUDE.md` / `AGENTS.md`), then hand the batch to `orchestrate`, which proposes the crew before fanning out. New UI surfaces go through `maestro`'s **direction round** (when installed) before implementation — and its grill decides, with the user, which design house leads the project's look; that pick belongs in the SPEC alongside the rest of the brief.
