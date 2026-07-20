# Changelog

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
