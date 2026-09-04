# cockpit repo

This repository ships ten process skills under `skills/` (pilot, grilling, grill-with-docs, orchestrate, test-driven-development, using-worktrees, handoff, diagnosing-bugs, domain-modeling, setup). If you're here to **use** them, install per README.md.

If you're **working on this repo**:

- Skills are **harness-neutral by contract**: the body of a skill must work on any capable coding agent. Claude Code-specific machinery (AskUserQuestion, Agent/Workflow, TaskCreate, model names) may appear only in a "Harness notes" section or in an explicitly harness-labeled sentence, always paired with the fallback for harnesses without it.
- In-pack skill references (the ten above) must resolve; references to outside skills (maestro, hyperframes, code-review, …) must be phrased as optional specialists with a fallback.
- `AGENTS.md` is the Codex/other-harness router — keep its skill index in sync with `skills/` (names, triggers, paths) whenever a skill is added, renamed, or retriggered.
- Keep skills terse and imperative. pilot is the flagship; changes to its phase table or routing table ripple into AGENTS.md and README.
- `pilot` is now a **task graph**, not a monolith: `SKILL.md` is the router (phase detection and dispatch, ~75 lines), `nodes/<phase>.md` hold one ritual each and load **one per turn**, `STATE.md` is the state contract (which files, who may write each, what is frozen), `CONTRACT.md` the four gates, `ROUTING.md` the outside-pack table. Never re-inline a node into the router — the split is what makes pilot affordable to run. The crew proposal lives in `orchestrate` §2a, not in pilot.
- `grilling` ships three files — `SKILL.md` (the interview discipline), `TRACKS.md` (the ten work tracks), `PLAN-FORMAT.md` (the plan skeleton, artifact mapping, gates, completion bar). pilot's PLAN phase, grill-with-docs, and orchestrate §3 all cite them by path: keep the section names in `PLAN-FORMAT.md` and the track names in `TRACKS.md` stable, or fix every citation in the same change.
- **Run `node scripts/check-pack.mjs` before committing** (pass `../maestro` to include the companion). It verifies
  the things that break silently: a skill citing a sibling that isn't shipped, an `AGENTS.md` index drifted from
  `skills/` — which breaks every non-Claude harness without any visible error — Claude-only machinery written with
  no label or fallback, and a stated count that no longer matches disk.
- Bump `.claude-plugin/plugin.json` version and add a `CHANGELOG.md` entry with every content change.
- The `maestro` marketplace entry in `.claude-plugin/marketplace.json` points at `leobbaroni/maestro` — that repo versions itself; nothing to sync here. cockpit's `plugin.json` also declares `dependencies: ["maestro"]`, so installing cockpit installs maestro. Keep it a **bare string**, not an object with a `version`: version constraints resolve against `{plugin-name}--v{version}` git tags on the *marketplace* repo, and maestro is sourced from its own repo, so a constrained entry would fail to resolve. Run `claude plugin validate .` after touching either manifest.
