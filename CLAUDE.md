# cockpit repo

This repository ships seven process skills under `skills/` (pilot, grilling, grill-with-docs, orchestrate, handoff, diagnosing-bugs, domain-modeling). If you're here to **use** them, install per README.md.

If you're **working on this repo**:

- Skills are **harness-neutral by contract**: the body of a skill must work on any capable coding agent. Claude Code-specific machinery (AskUserQuestion, Agent/Workflow, TaskCreate, model names) may appear only in a "Harness notes" section or in an explicitly harness-labeled sentence, always paired with the fallback for harnesses without it.
- In-pack skill references (the seven above) must resolve; references to outside skills (maestro, hyperframes, code-review, …) must be phrased as optional specialists with a fallback.
- `AGENTS.md` is the Codex/other-harness router — keep its skill index in sync with `skills/` (names, triggers, paths) whenever a skill is added, renamed, or retriggered.
- Keep skills terse and imperative. pilot is the flagship; changes to its phase table or routing table ripple into AGENTS.md and README.
- Bump `.claude-plugin/plugin.json` version and add a `CHANGELOG.md` entry with every content change.
- The `maestro` marketplace entry in `.claude-plugin/marketplace.json` points at `leobbaroni/maestro` — that repo versions itself; nothing to sync here.
