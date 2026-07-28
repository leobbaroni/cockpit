# Changelog

## 1.3.0 — 2026-07-28

**grilling rewritten from a 10-line prompt into the pack's planning engine**, merging a
refined planning meta-prompt supplied by the author. It now ships three files: `SKILL.md`
(the interview discipline), `TRACKS.md` (ten work tracks), `PLAN-FORMAT.md` (skeleton,
artifact mapping, gates, completion bar).

- **Evidence discipline.** Every factual sentence — in the interview and in the plan —
  carries exactly one of `(user)` / `(verified: <source>)` / `[assumed: default X — if
  wrong: Y]`. **Memory is never a source**: a version not read from a lockfile, an API
  shape not read from docs this session, a changelog not actually opened, a timing not
  measured — all `[assumed]`, and the completeness gate demotes any `(verified)` whose
  source turns out to be a knowledge claim. This is the fix for the failure the pack had
  no defence against: a plan that reads as authoritative and contains a fact nobody checked.
- **A question contract with a visible budget.** One question per turn, always last, exactly
  one question mark; every question ships a `Recommended:` line acceptable in one word with
  a stated basis; a bare "yes" takes the recommendation, not the literal polarity. Turns open
  with `Locked: … · Open forks: n · Q<k>/14`. Hard cap 14, target 3–8. A necessity test
  gates every question — name the two plans the answer forks between, and if it's the same
  plan either way, decide it and tag it instead.
- **Four bins, one of which costs a question.** Settled (evidence answers it) · executor's
  latitude (any competent choice serves) · default-and-tag (clear default, cheap to reverse)
  · fork — which needs divergence *and* opacity *and* expensive-to-reverse cost, all three,
  to earn a question.
- **Ten tracks** (`TRACKS.md`), picked silently by end-state: bug fix, feature, from scratch,
  refactor & hardening, integration, performance, migration, UI build, tech decision, quick
  task. Each names its decisive slots, the sections it adds, its build-phase invariants
  (reproduce first, measure first, safety net first, delete the old path last), and its
  signature landmines. Ordered tie-breaks and silent re-routing when answers reveal a
  different beast.
- **Landmine falsifiers get reserved budget.** At least two questions spent on the sharpest
  named falsifier — a question that states your approach and asks the one fact that would
  kill it — early enough to still reshape the plan. A confirmed landmine must visibly change
  the plan, not get patched in a sentence. Plus a danger rule: destructive or irreversible
  steps earn their own confirmation and a rollback step, however casual the ask sounded.
- **A mid-budget checkpoint** aimed at the assumption whose failure would most damage the
  plan — the counterweight to agreement bias — and a coverage sweep before closing, where
  every uncovered category becomes a stated tagged default rather than a silent omission.
- **Two gates before handover**, fixed in the document and never by reopening the interview:
  the completeness gate with its provenance scan, and the **executor gate** — reread the plan
  as the stranger who will build from it, told only "execute this plan", and fix anywhere
  they would have to stop and ask.
- **The plan skeleton mapped onto cockpit's artifacts** rather than dumped into chat:
  contract sections into `SPEC.md`, build sections into `PLAN.md`, terms and hard-to-reverse
  choices into `CONTEXT.md` / `docs/adr/` per domain-modeling. New in `PLAN.md`: the
  **Assumptions Ledger** (every default adopted without asking, with basis, blast radius, and
  the phase that checks it) — which supersedes the old free-form risk register — and a
  Build Phases contract (≤12 phases, each provable by its done-check, any phase depending on
  an assumption verifies it in its first step).
- **pilot's PLAN phase** rewritten around it: pick the track as well as the phase, freeze per
  `PLAN-FORMAT.md`, run both gates before the handoff. Two new standing interceptors, live in
  every phase: a fact you can't name a source for is an assumption, and destructive steps earn
  their own confirmation.
- **orchestrate §3** now mines a plan instead of paraphrasing it — a plan written for a
  stranger already holds six of the seven delegation blocks (`Done when:` is the acceptance
  criteria, `Covers:` the objective, Out of Scope the non-goals, Key Decisions the reasoning,
  the Assumptions Ledger what the agent must verify first). Copy them verbatim; re-deriving
  a thinner version from memory is how a locked brief silently loosens.
- Marketplace/README: maestro is eleven upstreams and 21 reference modules now, with
  video-shotcraft leading product video.

## 1.2.1 — 2026-07-20

Adversarial-review fixes on 1.2.0.

- **"The only two moves" was self-contradictory.** Both skills said routing *down* and
  *sideways* were the only moves that leave the user's model choice intact, while the crew
  table simultaneously mandated hard work → Opus 5 — a third move (*up*) whenever the session
  isn't already on it. Restated as three moves with the actual invariant named: the **lead
  role** never moves; implementation routes down, up, or sideways around it, and routing a
  hard subtask up is not a demotion because the lead still decomposes, reviews, and decides.
- orchestrate §3 justified itself with "the lead is the strongest model in the room" — which
  stops being true exactly when §2 works as designed (session on a fast model, hard work
  routed up). Rewritten to the durable reason: the lead holds the full context.
- §3 was the only section in the pack with no no-subagent fallback, and §5 depends on it —
  added: without subagents, write the seven blocks as your own working brief per item; the
  contract is a thinking checklist first, a delegation format second.
- orchestrate's fast tier now names the Haiku rung for trivial bulk, matching pilot's table.

## 1.2.0 — 2026-07-20

- **The session's model is the lead and the designer.** Whatever model the user selected
  now runs orchestration, design judgment, and final review — pilot's crew table and
  orchestrate's routing table no longer name a fixed lead tier. Only two moves are allowed
  against the user's choice: route *down* to the fast tier for mechanical work, and
  *sideways* to a different model for adversarial review. When the session model is already
  the strongest reasoner reachable, lead and hard collapse into one tier and the skill says
  so rather than inventing a split.
- **Opus 5 replaces Opus 4.8** as the hard/frontier default in both skills.
- **orchestrate §3, new: "Write the prompt as if the agent can never ask you anything."**
  A subagent starts cold — no conversation, no prior turns, none of the lead's reasoning —
  so the delegation prompt is the only channel the lead's judgment travels through. Defines
  a seven-block contract (objective · why this way, including rejected alternatives ·
  concrete context pasted verbatim · constraints and non-goals · acceptance criteria ·
  output contract · escalation) plus the rules that carry intent: give reasoning not just
  conclusions, quote the user verbatim on anything about taste, state parallel agents'
  file boundaries, name the tempting-but-wrong finish, and never reference "the above" to
  something that has no above. When an agent misses, check the prompt before escalating a
  tier — most misses are missing context, not a weak model.
- Review-wave prompts get the same treatment, aimed adversarially.
- maestro routing updated for its 3.1.0 capabilities: the design-house pick belongs to the
  user (pilot records it in the SPEC), and named design actions route to maestro's
  `commands` module so the originating project's real protocol runs instead of an
  approximation. README/AGENTS.md synced (19 reference modules, vendored library).

## 1.1.1 — 2026-07-20

- Marketplace: maestro entry description updated for maestro 3.0.0 — ten upstream
  knowledge bases (taste-skill and hallmark absorbed) and the new vendored depth
  library. Source URL unchanged; the maestro repo versions itself.

## 1.1.0 — 2026-07-20

- **pilot: new "Crew proposal" step.** Before any fan-out to `orchestrate` (PLAN handoff,
  KICKOFF, a 3+ task BUILD batch, a Tier-2 review wave), pilot now proposes *which models
  run which work* and gets approval instead of routing silently: read what the session can
  actually reach, map the four roles (lead / hard / mechanical / review), show the concrete
  per-task assignment with its cost-latency implication, and offer proposal vs all-frontier
  vs all-fast vs custom. The accepted mapping is remembered for the session — asked once,
  not per task — and a user-named model always wins. Small uniformly-mechanical batches
  state the crew in one line and skip the ceremony.
- Harness-aware by design: on Claude Code this is a real per-subagent model choice
  (mixed-tier batches, reviewers differing from implementers); on Codex and other
  single-model harnesses it degrades honestly into a sequencing-and-escalation decision
  rather than implying a choice the harness can't offer.
- `orchestrate` now honors a mapping pilot already got approved (no re-asking), announces
  the crew before spending when it wasn't, and says so out loud when it escalates a failed
  step to a stronger tier.

## 1.0.1 — 2026-07-20

- **Fixed: `/plugin install maestro@cockpit` failed on machines without GitHub SSH keys.**
  The `github` plugin-source type clones over SSH, so the install died with
  `Host key verification failed` for anyone authenticating to GitHub over HTTPS
  (gh CLI, credential manager) — the common case. Switched the maestro entry to the
  `url` source type with an explicit `https://github.com/leobbaroni/maestro.git`,
  which clones over HTTPS and needs no SSH setup. Verified end-to-end: both plugins
  now install from this marketplace alone.

## 1.0.0 — 2026-07-20

Initial release: seven process skills, harness-neutral (Claude Code native, Codex via
AGENTS.md), plus a marketplace that also serves maestro from its own repo.

- **pilot v2** — the flagship, rewritten: dedicated PLAN phase (ultra-planner: grill →
  SPEC/PLAN/risk register, hard stop before code), first-class tiered REVIEW phase
  (standard pass vs adversarial wave, dimension routing to code-review/security-review/
  simplify/maestro-audit), full specialist routing table with if-installed fallbacks,
  deterministic session-start ritual, and per-harness mechanics notes.
- **grilling, grill-with-docs, orchestrate, handoff, diagnosing-bugs, domain-modeling**
  ported from the author's personal library with a generalization pass: harness-specific
  tool names moved behind harness notes or paired with fallbacks, personal defaults
  generalized (languages, media CLI), two dangling skill references fixed
  (verify, improve-codebase-architecture).
- AGENTS.md router for Codex and other AGENTS.md-compatible harnesses; CLAUDE.md
  contributor contract (harness-neutrality rules).
- README with a four-path install matrix and a paste-ready agent setup prompt covering
  cockpit + maestro + the optional third-party video stack.
