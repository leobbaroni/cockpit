# Tracks

Pick the track silently, by the **end-state** — what must be true when the work is done. The
track adds decisive slots on top of the universal spine (goal, success criteria, scope,
non-goals, verification, phases), contributes its own plan sections, and imposes invariants on
the build phases. Never announce the classification and never ask "what kind of task is this" —
the user just gets a good first question.

| Track | End-state |
|---|---|
| Bug fix | A broken thing verifiably works again |
| Feature | A new capability exists in this codebase |
| From scratch | A new thing exists where nothing does |
| Refactor & hardening | Better code, identical behavior |
| Integration | A working connection to someone else's system |
| Performance | A number improves, behavior identical |
| Migration | A from-state moved to a to-state, system alive throughout |
| UI build | A screen judged by looking at it and clicking through it |
| Tech decision | A defensible decision, plus an optional thin proof |
| Quick task | A tiny obvious edit |

**Tie-breaks, in order:** (1) *Size guard* — a single small edit with no design choice is a quick
task regardless of topic. (2) *Diagnosis before build* — a described defect wins; "the export is
broken, and add PDF too" runs bug fix with PDF parked by name. (3) *End over means* — "migrate to
Postgres because queries are slow" is performance, and the named means becomes the leading
candidate fix, subject to measurement. (4) *Unresolved choice* — a pure "which should I pick?" is
a tech decision; a choice inside a committed build folds into that build. (5) *Core of work* —
otherwise, the track that owns the most build phases.

**Defaults:** code exists but the shape is unclear → feature; nothing to read → from scratch;
unclassifiable → quick task.

**Re-routing.** When answers reveal a different beast — the "bug" is a missing feature, the
"quick task" is a migration — switch silently, carry every filled slot forward, never re-ask, and
note the switch in the plan's Classification section. If classification churns twice, settle on
feature (code exists) or from scratch (none).

---

## Bug fix

**Decisive:** the definition of fixed (observed / expected / trigger); a reproduction, or an
evidence-capture path when repro is impossible; severity, and whether a stopgap comes first;
patch versus root cause; ranked hypotheses, each with the test that would kill it; the regression
guard.
**Adds:** Reproduction · Ranked Hypotheses · Confirmed Root Cause (`[open]` until evidence
exists) · Regression Guard.
**Invariants:** reproduce or capture evidence first; confirm the root cause before changing code;
the regression test fails before the fix and passes after.
**Landmines:** the "bug" is a missing feature; several bugs in one ask (fix the primary, park the
rest by name); the fault lives in a dependency or in the data.
**Route:** unknown cause, intermittent, or a fix that "didn't take" → the `diagnosing-bugs` skill
owns phases 1–2; this track plans around it.

## Feature — the default when code exists

**Decisive:** what "shipped" means in one sentence; the thinnest valuable slice plus explicit
non-goals; trigger and happy path; which existing pattern to extend (find the analogue first — if
there is none, say so rather than invent one); data and schema changes ("none" is a tagged
decision, not silence); failure behavior, defaulting to fail loudly.
**Adds:** User Flow.
**Invariants:** early phases deliver a demoable core; schema changes carry migration and
rollback.
**Landmines:** the "small feature" hiding a schema change or a new dependency; auth and
permission implications.

## From scratch — the default when there is nothing to read

**Decisive:** who it's for and the payoff moment; prototype or keeper; form factor (CLI, web,
service, job, mobile, desktop, library, script); the riskiest unknown, proven in phase 1; stack
and storage (boring defaults, tagged; the simplest storage that works; no accounts until forced);
guardrails around money, real data, and real people; the v1 finish line the user can run
themselves.
**Adds:** Stack Decisions (one-line reason each) · Riskiest Unknown · Guardrails · Project
Skeleton (layout, entry point, run command).
**Invariants:** phase 1 is a walking skeleton through the riskiest unknown; deployment is
deferred unless the ask includes it.
**Landmines:** not actually greenfield (existing data, users, or a system to match); credentials
the idea silently needs.

## Refactor & hardening

**Decisive:** the pain being removed (fear of the structure versus distrust of the tests);
behavior frozen bug-for-bug, with intended changes split into a named follow-up and discovered
bugs quarantined; the safety-net verdict from measured coverage (characterization tests first
when it's thin); a scope fence traced from actual dependents; green-to-green steps.
**Adds:** Behavior Contract · Safety Net · Scope Fence · Side-Fix Quarantine.
**Invariants:** the safety net exists before anything moves; every step leaves the build green;
"done" includes the original pain demonstrably gone.
**Landmines:** consumers outside the codebase; a "harden X" that is secretly a behavior change; a
suite that doesn't pass today.

## Integration

**Decisive:** the exact service and direction (we call them / they call us / both); the exact v1
operation list, nothing speculative; whether credentials exist, and secrets per the project's
existing convention (cited); the failure policy for down, slow, and rejecting (retries, backoff,
idempotency); the source of truth when data disagrees; the test strategy (recorded replay plus
one live smoke) and a contract-drift tripwire.
**Adds:** Verified API Facts (docs read or calls made this session — never memory) · Auth &
Secrets · Failure Policy & Source of Truth.
**Invariants:** phase 1 verifies the real API shapes; one operation works end to end before
breadth.
**Landmines:** no sandbox mode; credential or approval lead time; rate limits and per-call cost;
sensitive data leaving the system.

## Performance

**Decisive:** one specific slow action, not a vibe; the pain dimension (time, memory, cost); the
target number plus a stop rule; a baseline harness before any change; the load profile (always
slow, or only under load); suspects as hypotheses, each with the profiling test that confirms or
kills it — the profiler outranks every hunch, including the user's; frozen surfaces; the tradeoff
budget.
**Adds:** Baseline & Target · Ranked Hypotheses · Frozen Surfaces · Stop Rule & Regression Guard.
**Invariants:** phase 1 measures the baseline and locks behavior with tests; change one variable,
measure, keep or revert; the final phase installs the timing guard.
**Landmines:** "slow" that is actually broken — timeouts and hangs route to bug fix; production
load unlike the dev harness.

## Migration

**Decisive:** the forcing reason, which sets the risk budget; the current version verified from
the lockfile; the strategy (stepwise through supported intermediates versus one big-bang branch —
distance decides); behavior identical during the move, improvements parked; per-step rollback;
data safety (backup plus a dry run on a copy for anything irreversible); detector quality (add
smoke tests first if a green suite isn't meaningful); cutover and deletion of the old path.
**Adds:** Breaking-Change Inventory (from a changelog actually read, one search hit per entry —
otherwise building it *is* phase 1) · Rollback Plan · Data Safety · Cutover & Cleanup.
**Invariants:** smoke tests before the first step; every step revertible; the final phase deletes
the old path.
**Landmines:** real data with no rehearsal; the "simple bump" that spans several majors;
remembered changelogs.

## UI build

**Decisive:** the one core action on the screen; the design reference (an existing screen, a
named site, or a screenshot — a reference replaces a mockup); composing from the detected
framework and components (look up the stack; if it's unreadable and nothing was pasted, adopt a
tagged default framework — high blast radius, so this is one of the reserved falsifiers you may
spend a question on — and verify it in phase 1); data binding (an existing source, cited, or
mock-first with real wiring as its own phase); empty, loading, and error states batched into one
defaulted decision; the responsive and accessibility bar; the fidelity bar (a rough working
version first, polish as its own cuttable phase).
**Adds:** Design Reference · States · Fidelity Bar & Polish Backlog.
**Invariants:** an early phase delivers the clickable core flow; done-checks are observable
screen behavior ("renders the empty state matching the reference"), never "looks better".
**Landmines:** the "form" that is mostly backend — re-route to feature; visual micro-decisions
(spacing, color, copy) are defaults, never questions.
**Route:** design direction, page shape, motion, and critique belong to the `maestro` skill when
it's installed — including which design house leads the look, which is the user's pick and
belongs in the SPEC. Without it, do the work directly to the same standard and say so.

## Tech decision

**Decisive:** the real decision at the right level (a feasibility ask is option-versus-nothing,
not a forced comparison); criteria ranked *before* any scoring, since post-hoc criteria prove
whatever you want — fit with the existing stack is usually heaviest, and a lookup answers it;
candidates and deal-breakers, with "none" recorded explicitly; reversibility and exit path
(cheap-to-reverse earns a fast call, expensive earns the spike); the recommendation plus its
strongest objection, attacked exactly once; a timeboxed spike with predeclared falsifiable kill
criteria, or an explicit decide-on-paper.
**Adds:** Criteria (ranked) · Options & Deal-breakers · Decision Matrix · Recommendation &
Strongest Objection · Spike Plan.
**Invariants:** the spike's kill criteria are its done-check; the record states what would have
changed the answer, and how to back out.
**Landmines:** a rigged race; a load-bearing fact that would flip the ranking left unverified —
that fact *is* the spike question.
**Route:** the decision itself lands as an ADR per the `domain-modeling` skill.

## Quick task — the fallback when nothing else fits

**Decisive:** the gist plus a whole-ask check ("is that the whole thing, or one piece of
something bigger?", which doubles as routing repair); a blast-radius fence — the smallest correct
change, zero drive-by cleanups, adjacencies parked by name; the proof.
**Adds:** The Change (exact edits with cited paths) · Escalation Trigger.
**Invariants:** one or two phases; if a load-bearing assumption exists, verifying it is phase 1.
**Landmines:** destructive one-liners — the danger rule applies regardless of size; a
deliberate-looking target (a pinned version with a warning comment, a guarded config) — surface
the evidence before changing it.
