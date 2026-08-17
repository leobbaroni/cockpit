# Changelog

## 1.7.0 — 2026-08-15

**Crews get a second model, and a ladder to climb instead of a place to stop.** A crew was one
decision — who does the work. It is now two: who does the work, and **who gets called when the
work fights back**. Both agreed in the same breath, because deciding the second one mid-failure
is deciding it while annoyed.

### The rescue crew (`pilot`)

One model and one number, asked during the crew proposal. The model is the strongest reasoner
reachable or whatever the user names; the number is the attempt count that wakes it, default 2.
Recorded with the rest of the mapping — in `PLAN.md` when the batch came from a plan — and not
re-asked.

**A count alone is a weak proxy for difficulty**, so three signals wake it regardless: the same
check red twice, a reviewer raising a blocking finding on the same file twice, and an agent
reporting itself blocked (which fires on attempt one, because waiting for a count discards the
information). The counter is **per task and clears on a passing verification** — task 7 failing
twice says nothing about task 8.

**It reviews and fixes in one pass, deliberately.** Splitting them hands the diagnosis to a
second model as a written finding, and the diagnosis is the expensive part — a correct diagnosis
re-derived from a summary is how you get a confident wrong fix. The original tier then runs the
**acceptance check only**, which restores independent eyes on the outcome without paying for a
second full pass.

### The ladder (`orchestrate` §2a)

Five rungs, ordered so **every rung costs more effort than the one below it** — a ladder whose
top rung is easier than its bottom rung is a ladder people fall down.

1. **Retry, same tier, better prompt.** Most misses are missing context, not a weak model.
2. **Rescue crew** — combined review + fix.
3. **Rescue crew again, every failed approach banned by name.** *Change the approach, not the
   model.* Two failures is evidence about the approach, and a pass left free to retry it will.
4. **Decompose.** A task that has failed three times is usually two tasks wearing one name.
5. **Hand back — external blockers only.**

Rung 3 is the one that gets skipped: banning an approach means *writing it down* in the
delegation prompt. An approach you merely intend not to retry is one the next agent rediscovers.

### The hand-back bar, and why it is this tight

**"It's hard" is not a blocker. "Two models failed" is not a blocker.** Those describe the work,
and the work is the job. Hand back only for something nameable and external — a missing
credential, an unreachable service, an ambiguity only the user can resolve.

The looser version was rejected for a specific reason: **any bound shaped "after N failures, stop
and report" makes reaching N a way to finish.** Climbing must always cost less than reaching the
top. Exhausting the ladder is how you *discover* whether a blocker is external — and if you
cannot name it, you have not finished climbing.

Since nothing stops the ladder automatically, **the one-line escalation announcement is the only
brake** — which rung, what fired it, which tier — stated without pausing for permission. Stalling
an unattended batch on the task that needed help most fails at the thing the batch exists for.

### Contradictions removed

Escalation was previously specified twice and differently: `orchestrate` said escalate when a
step **fails once**, `pilot` said reopen the crew on a stage **failing twice**. Both are gone —
one configured trigger, one ladder. Both skills also routed "anything that already failed once"
straight to the frontier tier, which skipped rung 1 entirely; the difficulty tables now describe
work **classified hard up front**, and a task that has already failed climbs instead.

## 1.6.6 — 2026-08-10

**A debloat pass that mostly refused to cut, and says so.** Six analysts proposed 49 deletions
across all twelve skill files; an adversarial pass whose only job was to *refute* each one — 
defaulting to keep when uncertain — confirmed **11** and rejected **38**. Net: 1,061 bytes,
about 1% of the pack.

- **pilot proposed 8 cuts and zero survived.** Every one turned out to name a failure mode, a
  trigger, or a conflict resolution. That is the honest answer to "debloat pilot": it is dense,
  not padded, and the 23 KB sits in 200 lines because the prose is doing work.
- **What did go** was genuinely inert: a paraphrase weaker than the two rules following it, a
  restatement of a fenced template three lines above it, an emphasis clause asserting a causal
  link already stated in the other direction, a provenance claim about the skill's own authoring
  that sat in tension with its first Rule, and three pieces of meta-commentary about a file's
  structure rather than instruction to follow.
- **The keep rule, now demonstrated rather than asserted:** a bare rule gets followed
  selectively; a rule attached to the failure it prevents gets followed. Anything naming a
  concrete symptom, threshold, command, or ambiguity survived by design.

Also: maestro's reference-module count tracked to 26 in INSTALL.md.

## 1.6.5 — 2026-08-03

**There is a third skills location, and the shadowing procedure was wrong without it.**
Verified while resolving a real shadowed install: `npx skills add` and similar cross-tool
installers write to **`~/.agents/skills/`** — the Agent Skills standard location, shared with
other harnesses — and drop a *symlink* into `~/.claude/skills/`. Claude Code reads only
`~/.claude/skills/`, the project's `.claude/skills/`, and plugin directories; it never reads
`~/.agents/skills/` itself.

- **`ls` lies about what those entries are.** A name in `~/.claude/skills/` can be a symlink
  whose content lives 22 MB away. `setup` now says to run `ls -la` and check for `->` before
  treating an entry as a plain folder — and that `diff -r` following the link is correct, since
  content is what you are comparing.
- **Removing a symlink is not deleting the skill.** The files stay in `~/.agents/skills/`, still
  live for whatever other tool points there. Usually the desired outcome, but the skill now says
  to report it accurately rather than claiming a deletion that did not happen.

## 1.6.4 — 2026-08-03

**Verified against the installed plugin instead of the catalog, and it did not match.** 1.6.3
described the HyperFrames suite from Anthropic's plugin-catalog listing. Installing it and
counting told a different story, so this release corrects the numbers, adds the two detections
that would have caught the mismatch, and answers the question the guide never did: what a new
user actually *types* once it is installed.

- **19 skills, not 21.** The installed build (0.7.64) has no `hyperframes-media` — it does not
  exist — and **`website-to-video` is a documentation guide there, not a skill**. Only upstream's
  `npx skills add` route ships it. maestro's `companions.md` listed it as a routable workflow;
  it is now marked conditional, with the fallback for when it is absent, so the router cannot
  send work to a name that will not resolve.
- **~2,540 always-on tokens, not ~4,850 — about 2.4× cockpit and maestro (~1,070), not five.**
  Measured by summing each installed skill's frontmatter description. The old figure would have
  talked people out of an install that is cheaper than advertised, which is the wrong kind of
  wrong. The method is now written down next to the number so it can be re-measured rather than
  quoted forever.
- **`setup` detects shadowing.** Hand-installed skills plus a later plugin install leaves two
  copies of every shared name, the hand-installed ones frozen forever, and no way for the user
  to know which answers. The skill now diffs directory against directory and classifies each as
  identical, plugin-superset, or **local-has-files-the-plugin-lacks** — the third being why this
  is a diff and not an `rm -rf`. It also checks both locations when reporting what is installed;
  reading only one is how a present skill gets reported missing.
- **`setup update` mode, and a *Keeping it current* section.** Three layers, three different
  update mechanisms, none automatic. Both now lead with the step people skip: refresh the
  marketplace *before* `plugin update`, or the update is a no-op that reports success.
- **INSTALL.md now covers using it, not just installing it.** A near-zero-knowledge user gets
  one command to remember (`/cockpit:pilot`), a three-step first session that proves the install
  works, a what-to-type table, the three deliberate behaviors that read as malfunctions
  (interview-before-code, no-unverified-done, being asked which design house leads), and
  explicit permission to say "skip the interview" — the process is a default, not a cage.

## 1.6.3 — 2026-08-03

**A guide, and a `setup` that can actually close the gaps it finds.** 1.6.2 documented that the
plugin install covers cockpit and maestro only; this release says what to do about the rest,
with commands verified against a real machine rather than recalled.

- **[INSTALL.md](INSTALL.md).** The full path end to end — the four-command quick start, what
  arrives at each tier and what does not, runtime prerequisites per OS, the video toolchain,
  what the whole thing costs in context, the Codex path, and a troubleshooting section built
  from failures this install path actually produced: the missing `/reload-plugins`, the
  qualified `name@marketplace` form, the ≤ 1.5.0 dependency trap, Windows `MAX_PATH`, and
  hand-copied skills shadowing the plugin.
- **The HyperFrames suite is one command, from the official marketplace.**
  `/plugin install hyperframes@claude-plugins-official` installs the router, six domain skills,
  ten workflow skills, **and `media-use` and `figma`, which ship inside it**. Both this repo and
  maestro previously implied hand-copying a `skills/` folder and hunting for `media-use`
  separately. Neither was necessary. *(Counts and token figures in this entry were corrected in
  1.6.4 after measuring the installed plugin rather than the catalog listing.)*
- **`setup` now states the context bill before recommending the suite**, because always-on cost
  scales with the number of skills rather than their size. Right trade for someone who renders
  video, pure loss for someone who doesn't — the skill makes the user decide knowingly instead
  of recommending by default.

## 1.6.2 — 2026-08-03

The clean-machine install path, verified in an isolated config dir rather than assumed. One
command does resolve the dependency — `claude plugin install cockpit@cockpit` prints
`+ 1 dependency: maestro` and leaves both `✔ enabled` with the complete tree, all eight
process skills and all ten vendored corpora. The docs around that command were wrong in two
ways that would stop any new user cold.

- **`/reload-plugins` was missing from the install sequence.** Claude Code live-detects edits
  under `~/.claude/skills/`, but a plugin install is invisible to that watcher — so a skill
  installed mid-session does not exist, does not autocomplete, and reads to the user as a
  failed install. It is now the third command in the README's install block, and the first
  thing `setup` checks when someone says "no command shows up".
- **The README named the wrong command.** It said `/setup`, but plugin skills are namespaced
  by their plugin: `/cockpit:setup`, `/cockpit:pilot`, `/maestro:maestro` are what autocomplete
  (bare names resolve too, but only while nothing else claims them). Both files now give the
  namespaced form, because it is the one that cannot collide.
- **What the install does *not* cover is now stated, not implied.** A table in the README
  separates what arrives automatically (both plugins, maestro's library) from what does not
  (Node, FFmpeg, the hyperframes suite, media-use, Remotion). Tier 2 of `setup` now leads with
  the fact that a clean machine has none of the companion skills — absence there is the default
  state, not a broken install.


## 1.6.1 — 2026-08-03

Two defects in 1.6.0, both found by actually running `setup` on a real machine rather than
reading it.

- **The FFmpeg check reported a false pass.** `ffmpeg -version | head -1` prints *nothing* when
  the binary is missing, so a missing FFmpeg rendered as a blank cell instead of a failure —
  precisely the "tool you know is installed" assumption the skill exists to prevent. Now
  `command -v ffmpeg` (`Get-Command` in PowerShell), with the reason written next to it: test
  for the binary, not for its output.
- **Updating from ≤ 1.5.0 lands in a broken state.** Where maestro was already installed
  separately, introducing the dependency leaves cockpit `failed to load — Dependency
  "maestro@cockpit" is not installed` with maestro `disabled`: the existing install was never
  "pulled in" to satisfy anything, so it never received the explicit enable a dependency
  install writes. `claude plugin enable maestro@cockpit` fixes it, and that is now in the skill
  alongside two other CLI facts worth knowing — `update` and `enable` need the qualified
  `name@marketplace` form (a bare name fails with `Plugin not found`), and updates require a
  restart before the new skill bodies load.


## 1.6.0 — 2026-08-03

**One install gets the whole stack, and a new `setup` skill tells you what that stack can
actually do on your machine.**

- **cockpit declares `dependencies: ["maestro"]`.** Installing cockpit now resolves and
  installs maestro automatically — `/plugin install cockpit@cockpit` is the only command.
  The two repos, version lines, licenses, and maestro's upstream-drift machinery all stay
  separate, which a merge would have welded together: maestro shipped six minor versions in
  thirteen days driven by *upstream* churn across eleven external projects, while cockpit
  shipped five driven by its own design. Kept as a **bare string** rather than a version
  constraint on purpose — constraints resolve against `{plugin}--v{version}` git tags on the
  *marketplace* repo, and maestro is sourced from its own, so a constrained entry wouldn't
  resolve. Noted in CLAUDE.md so nobody "improves" it later.
- Two consequences documented rather than discovered: **maestro can no longer be disabled on
  its own** while cockpit is enabled (Claude Code refuses and prints a chained disable
  command), and every cockpit install now carries maestro's ~5 MB depth library.
- **New skill: `setup`.** Answers "what can this machine actually do?" — detects installed
  plugins, companion skills, Node, and FFmpeg by *running the checks*, then reports each gap
  as the capability it costs you rather than as a missing package name ("FFmpeg not on PATH:
  HyperFrames can compose and check a video but cannot encode one"). Closes gaps in four
  tiers — the pack, runtime prerequisites, companion skills, and the two source corpora
  maestro cannot bundle — **asking before each tier**, never cloning a third-party repo on
  blanket approval, and re-verifying with the detection command rather than trusting an
  installer's exit code. Its standing rule: a tool you "know" is installed is an assumption.
- The two corpora that can't ship inside maestro are now surfaced at install time instead of
  being buried: **threejs-skills** (upstream declares no license) and genjutsu's
  **ui-ux-pro-max** (1.7 MB of Python tooling). Previously nothing told you they existed.
- README's agent-assisted setup prompt rewritten — it no longer tells agents to install
  maestro separately, and it now hands the environment work to the `setup` skill instead of
  having a context-free agent guess at your machine.
- Marketplace manifest gained the description it was missing; `claude plugin validate` is
  clean.

## 1.5.0 — 2026-07-30

**pilot's coding discipline rewritten as the execution contract.** It was four principles
derived from Karpathy's observations on LLM coding pitfalls — think before coding, simplicity
first, surgical changes, goal-driven execution — and every model agrees with all four while
following them selectively. The rewrite keeps the substance and changes what kind of thing it
is: **triggers and artifacts instead of virtues**, because nobody experiences themselves as
assuming, over-engineering, or drifting. You won't catch "I'm making an assumption"; you will
catch "I just typed a filename I never opened."

- **Named the real failure mode up front.** The strongest models fail these hardest — not from
  carelessness but from competence: a capable model sees a better design, a missing edge case,
  an adjacent flaw, and has a genuinely good reason to act. **The quality of the reason is not
  evidence that it's in scope.**
- **Gate 1 — restate the ask, then work.** One line in the user's own terms, naming what's out.
  If you can't write it, you don't have the ask. That line is the scope contract; anything not
  in it is a proposal. Four halt conditions replace "if uncertain, ask" — two readings that
  produce different diffs, a request that contradicts the code, a file you'd guess at instead
  of reading, or a change that breaks something unmentioned.
- **Gate 2 — name what you'll touch, then touch only that.** Nine specific moves listed,
  because that is what over-engineering looks like in a diff and each one is individually
  defensible: a config parameter with one call site, a branch for an impossible case, a helper
  extracted for a single use, an abstraction for one implementation, a fix to an adjacent nit,
  a test for behavior you didn't change. **Noticing is not fixing** — name it, leave it.
- **Gate 3 — the rationalization tripwire, new.** A deviation almost never arrives as "I'll
  ignore the scope"; it arrives wearing a reason. Fourteen of them listed near-verbatim —
  "while I'm here", "this will be needed later", "for robustness", "it's cleaner this way",
  "the more general solution is actually simpler". When one shows up in your own reasoning,
  that *is* the signal: ask, or write it down as a follow-up. Never proceed silently because
  the argument was good — the argument is always good, which is why the failure survives.
- **Gate 4 — done is a check you ran.** Paste the command and its output. Green typecheck,
  passing build, and "this should work" are each named as not-done. If you can't state the
  check, the task isn't specified — back to Gate 1. (This absorbs the old standing interceptor
  on unexercised behavior, which said the same thing twice.)
- **The exemption is narrow and defined against the obvious loophole:** trivial changes may run
  the gates in your head, and **"trivial" is a property of the change, not of your confidence
  in it** — a task you're sure about that touches four files is not trivial.
- Cross-wired: Step 0 states that the phase decides the ritual while the contract decides how
  any single edit is made, and BUILD routes into it by name. Attribution to the Karpathy source
  kept in the section footer.
- Marketplace: maestro is 3.5.0 with the new generative-media family.

## 1.4.0 — 2026-07-28

**The question cap is gone.** 1.3.0 shipped a hard cap of 14 — an arbitrary constant that
optimized for the agent's economy rather than the project's. The plan is the deliverable, so
the interview is as long as the work actually is.

- **The count is an output, not a budget.** Whatever survives §4's fork test gets asked;
  nothing else does. A large project earns more questions only by genuinely holding more
  forks — never by being large. The status line drops `/14` and keeps both live numbers:
  `Locked: … · Open forks: <n> · Q<k>`.
- **The waterline replaces the cap.** Every answer re-ranks the open forks by
  cost-of-wrong-branch; close the moment the top-ranked fork would cost less to fix wrong
  than to ask about — with the asking price rising as the interview lengthens, because
  fatigue compounds. This is the honest version of what 14 was approximating: a fifteenth
  question on a real migration can clear that bar while a sixth on a one-file fix does not.
  It is a per-question condition, not a total, so it scales with the project natively.
- **The run's shape is stated up front and the user sets it.** The opening turn names the
  surviving-fork count — "recon left <n> forks I can't settle by looking" — with both ramps
  standing: *"just plan it"* closes now on tagged defaults, *"grill me harder"* digs past
  them. The pack had an exit ramp and no way to ask for more depth; now it has both.
- **"Grill me harder" has mechanics, not vibes:** it re-opens the default-and-tag bin, walking
  the Assumptions Ledger from highest blast radius down and converting rows into questions
  under the full contract. Deeper means more of the queue, never softer questions.
- **The checkpoint is triggered structurally**, not at "mid-budget" — the turn after scope and
  shape stop moving, before the mechanism questions — and it **re-fires after any landmine
  that redraws the plan**, since agreement bias is most dangerous right after the user has
  watched you rebuild around their answer. A long run needs that counterweight more, not less.
- **A churn signal, since there's no ceiling to hit:** two consecutive answers that fail to
  shrink the open-fork count mean the interview is circling, not converging — checkpoint if
  you haven't, otherwise close.
- **The Interview Ledger now audits itself.** Mark any question whose answer changed no line
  of the plan; that one failed the necessity test in hindsight, and two in one interview mean
  the bar for asking is set too low. That's the feedback loop the cap used to substitute for.
- Two changes considered and rejected on review: a periodic re-rank (weaker than the existing
  "re-rehearse after every answer", which is already continuous), and a rule requiring each
  question to name the plan slot it fills — which duplicates the necessity test and would
  reward leaving slots undefaulted to keep questions justifiable.

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
