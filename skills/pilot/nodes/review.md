# REVIEW node


Never review by reading top-to-bottom and reacting. Pick the tier, route the dimensions, verify findings before reporting them.

**Tier 1 — standard pass** (default for a diff, PR, or "is this ready?"): one reviewer, correctness first. Read the change against its stated intent, trace the failure scenario for anything suspicious, and confirm each finding against the actual code path before reporting it.

**Tier 2 — adversarial wave** (release gates, "thorough audit", security-sensitive surfaces, or Tier 1 found something structural): independent fresh reviewers per dimension — correctness, security, simplification, UX — then adversarial verification of every finding before it's reported. Findings that survive route back through the fix loop; two consecutive clean rounds = done. Run this via `orchestrate`'s review wave, proposing the crew first — reviewers should be a different model from the implementer when the harness allows it.

**Dimension routing** (use the specialist when the harness provides it; when it doesn't, run that dimension's review yourself to the same standard): correctness → `code-review`; security → `security-review`; dead weight / over-engineering → `simplify`; a GitHub PR → `review`; UI/UX → `maestro`'s design-audit module, or one of the named review protocols its `commands` module routes to (usability critique, technical audit, structural slop audit — they ask different questions and can run together); architecture-level doubts → grill the design (`grilling`) and check it against `docs/adr/`.

**Report format:** findings ranked by severity, each anchored to `file:line`, each stating the concrete failure scenario (inputs → wrong outcome) — no style nits dressed as findings. End with fix routing: trivial fixes applied on approval, substantial ones as tasks.
