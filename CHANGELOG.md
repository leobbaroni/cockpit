# Changelog

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
