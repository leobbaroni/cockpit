---
name: grilling
description: The interview that turns an opening ask into a build-ready plan. One question at a time, each with a recommended answer, with the open forks counted down in every turn — and every fact tagged as stated, verified, or assumed. Use when the user wants to stress-test a plan or design before building, uses any 'grill' trigger phrase, or hands over a request too big to start on.
argument-hint: "[the ask, plan, design, or idea to sharpen]"
---

# Grilling

Interview the user until the plan is executable, then stop. Ask only where the plan genuinely
forks; look up everything else.

**The executor is a stranger.** Whoever builds from this — a fresh session, another agent, a
different human — has none of this conversation and no way to ask you anything. Every rule
below exists to satisfy that constraint. Write for them, not for the person you are talking to.

## 1. Look, don't ask

Anything a tool you hold — or code, docs, or
links the user gave you — can settle is a lookup, not a question. Ask only for what nothing can
look up: intent, constraints, stakes, taste, what exists outside this machine.

Take inventory of your own reach silently (files, shell, web, repo, database, connected tools),
then **ask once, early, what access the user can grant**: a repository, a spec or design doc, a
running or staging instance, a connected tool — or confirmation that the credentials the work
needs already exist in the environment as env vars. Never ask for secret values; reference them
as `${ENV_VAR}`. That one question also routes the work: what they hand over tells you
existing-project from greenfield.

That broad opener is not the last word on access. Whenever the rehearsal below reveals a single
named artifact that would settle a live fork — an API's docs, a config file, one screenshot —
ask for exactly that. "Paste me exactly X" beats a tagged assumption whenever X is cheap to hand
over.

Recon proportionately to what you can reach: list the tree, read the manifest and lockfile, skim
the README, check history on the area in question, read the implicated files and the test setup,
and verify each claim in the ask by looking. Enough to ground recommendations and learn the
project's conventions — not a full audit. Keep reconning between turns; a fork a later read can
settle is never a question.

With nothing to read, the method is identical and more items end up assumed. That is correct,
not a failure. **Never invent a fact to avoid tagging it.**

## 2. Evidence discipline

Every sentence that states a fact — in the interview and in the plan — carries exactly one of
three statuses. An untagged claim of fact is a bug. (Conversational glue that asserts nothing
needs no tag.)

| Status | Means |
|---|---|
| **(user)** | The user said it, this session |
| **(verified: `<source>`)** | Established this session from a named source — the exact file, command, tool call, search, or artifact the user provided. Cite the specific thing (`package.json`, `ran: npm ls react`, `the spec you pasted`), never "verified" alone |
| **[assumed: default X — if wrong: Y]** | Your default, tagged, with the consequence stated in line |

**Memory is never a source.** Training data, "general knowledge", and "the docs say" without a
read are `[assumed]`, not `(verified)` — that substitution is the single most common way a plan
ships a fact that was never true. Versions come from a lockfile or a live check. API shapes from
docs read or calls made this session. Breaking-change lists from a changelog actually opened,
otherwise building that list *is* the first build phase. Measurements you didn't take don't exist.

"I'd need to check" is always acceptable — log it as an open item with a proceed-with default so
it never blocks execution. When the user asserts something a source contradicts, present both
and let them pick; never silently comply and never silently override.

A tagged default is not an invention. Torn between inventing a fact and spending a question, do
neither: default it, tag it, move on.

## 3. The question contract

1. **One question per turn, always last in the message.** Exactly one question mark — no
   rhetorical, compound, or "also, quickly…" questions. A single "A or B?" fork is one question.
2. **Every question ships a `Recommended:` line** — a concrete answer acceptable in one word,
   plus a one-line basis. Basis quality, best first: cited evidence > the user's own conventions
   > a named industry default > reversibility. No basis → say so and recommend the more
   reversible option. A basis is not a licence to smuggle in an unverified fact: if the
   recommendation rests on a remembered version, price, or API shape, tag that specific
   `[assumed]` inline or drop it from the basis.
3. **A bare "yes" accepts the `Recommended:` line**, not the literal polarity of the question.
   Prefer "A or B?" or open phrasing over yes/no. Free-form answers outrank the options offered.
4. **Number the questions and show the queue.** Open each question turn with
   `Locked: <one line> · Open forks: <n> · Q<k>`. **There is no fixed cap** — the count is an
   output of §4, not a budget you spend: what survives the fork test gets asked, nothing else
   does. A large project earns more questions only by genuinely holding more forks, never by
   being large. Every question turn counts toward `Q<k>` — access requests, the checkpoint,
   confirmations, the closing approval — and each one raises the price of the next, because
   fatigue compounds: the bar for asking climbs as the interview lengthens. `Open forks` must
   trend toward zero. Finishing in three with a tight plan is success, not laziness.
5. **Necessity test before every question:** name the two plans the answer forks between. Same
   plan either way → don't ask; decide, tag, move on. A lookup could answer it → look.
6. **Sharp beats broad.** A named probe extracts a decision; a catch-all extracts one fact at
   most. At most one catch-all per interview, as a last resort — replace every trawl with the
   concrete falsifiable default it is hiding.
7. **Recommendations are genuine positions.** Put the fork in the question rather than asking
   the user to ratify a summary. When evidence contradicts their stated approach, lead with the
   evidence and recommend the correction.

### Turn shape

```
Locked: <what is settled, one line> · Open forks: <n> · Q<k>

<1–2 sentences naming the fork and the evidence framing it — cite sources for looked-up facts>

Q<k>. <one specific question>
Recommended: <concrete answer> — <one-line basis>.
Also credible: <second branch> — <when it would be right instead>.   ← only when genuinely live
```

No filler, no progress theater.

## 4. Before the first question

Silently: harvest the ask (every noun, number, named tool, and constraint hint is evidence and
enters as `(user)` — never re-ask what the ask already settled), recon what you can reach, pick
the track from `TRACKS.md`, then **fill the entire plan skeleton privately** from harvest, recon,
and defaults, tagging every slot.

Treat odd, out-of-place words as live wires — "offline", "our auditors", "the kiosk", "60
requests/min" mark a constraint that bends the design. Carry them into the rehearsal.

**Rehearse the build station by station**, as the executor will live it: goal · shape · data ·
core behavior · interfaces · integrations · edges and failures · access and secrets ·
verification · deploy and handoff. At each station ask whether the executor could proceed without
an expensive guess. Yes → record the decision. No → that is a stall, and a question candidate.

**Pre-mortem:** "this shipped and failed — why?" The top three causes name your landmine
questions. Then score each `[assumed]` by blast radius × doubt; high on both gets asked, the rest
stays tagged. Sorted, that is your question queue.

Classify every decision into one of four bins:

| Bin | Test | What you do |
|---|---|---|
| **Settled** | Evidence answers it | Record it with its source. Never ask |
| **Executor's latitude** | Any competent choice serves equally (naming, internal layout, style) | Choose now, mark "executor's choice". Never ask |
| **Default-and-tag** | A clear default exists and being wrong is cheap to fix | Adopt it, write an Assumptions Ledger row. Never ask |
| **Fork** | **Divergence** (two credible answers → visibly different builds) **and Opacity** (no source, prior answer, or cheap lookup settles it) **and Cost** (the wrong branch wastes real work and is expensive to reverse) | Spend a question |

Fail any one of the three → it belongs in one of the first three bins.

## 5. Ordering, checkpoint, close

Open with your reading of the ask in 1–3 sentences, the single most useful recon finding (cited),
and the run's shape — "recon left <n> forks I can't settle by looking" — with both ramps standing:
**"just plan it" closes now on tagged defaults; "grill me harder" digs past them.** That number is
§4's surviving queue, so it tracks the size of the actual work: a twelve-phase migration holds
more real forks than a two-phase fix, and says so up front instead of discovering it at question
nine. It is an estimate, not a promise — a landmine legitimately grows the queue, and the live
`Open forks` count is the running truth. Then the access request if you haven't placed it, then
Q1 — the fork whose answer redraws the largest part of the plan. If recon and the ask already
fill every decisive slot, skip the ceremony: the first reply may be the closing turn.

- **Highest blast radius first.** Scope and shape gate everything below them.
- **Reserve at least two questions for landmine falsifiers**, early enough that a confirmed one
  can still reshape the plan. A falsifier states your approach and asks the one fact that would
  kill it — not "any constraints?" but "I'm planning to put uploads on cloud storage — does
  customer data have to stay on infrastructure you control?"
- **Scope and success before mechanism; mechanism before polish; naming and cosmetics never.**
  Quantify vague words — fast, simple, secure, soon, scalable — into a number or an observable
  inside your recommendation ("fast enough = under two seconds for search — right number?").
- **Harvest everything.** When an answer volunteers more than asked, fill every slot it touches
  silently, then ask the most important still-open question. When the user asks *you* something,
  answer plainly first.
- **Re-rehearse after every answer.** It kills queued forks (drop them silently, record the
  inherited decision), opens new ones, or detonates a default. When an answer points at
  something unread you can reach, look now.
- **"Grill me harder" re-opens the defaulted bin.** A user volunteering turns has lowered the
  price of asking, so the fork test's cost side genuinely changed — walk the Assumptions Ledger
  from highest blast radius down, converting rows into questions under the full contract:
  recommended answer, necessity test, one per turn. Deeper means more of the queue, never
  softer questions, and never questions about naming or cosmetics.

**A landmine that detonates a default gets followed all the way down**, never patched in one
sentence. "The factory floor has no internet" doesn't edit the deployment section — it flips the
build to local-first with periodic sync, moves storage on-device, changes the stack, and adds an
offline test. Re-rehearse from the shape station. A confirmed landmine must visibly change the
plan, recorded as "constraint → what the plan does about it".

**Checkpoint when scope and shape lock** — the turn after the plan's outline stops moving, before
the mechanism questions. One question spent inviting the user to falsify you is the
counterweight to agreement bias. Open with a short digest — what's decided, plus the two or three
riskiest live assumptions — then aim at the assumption whose failure would most damage the plan:
"The claim most likely to sink this plan is X. Does it hold? Recommended: it holds — <basis>. A
bare yes confirms; if it's wrong, say what's true instead and I'll re-plan." Corrections to the
digest are free; invite them. A load-bearing assumption still unverified after the checkpoint
gets hedged: verify it, or make verifying it the first build phase with a stated fallback.

**A landmine that redraws the plan resets the checkpoint** — re-checkpoint after re-rehearsing.
The moment agreement bias is most dangerous is right after the user has watched you rebuild the
plan around their answer, and a long interview needs that counterweight more often, not less.
When the close follows immediately anyway, the Defaulted decisions recap carries the digest —
don't spend a separate turn on it.

**Coverage sweep before closing.** Walk this list once, asking only where a gap is genuinely
plan-changing and filling every other with an explicit tagged default — an uncovered category
becomes a stated decision, never a silent omission: scope and non-goals · data (entities,
identity, lifecycle, scale, migration) · users and interaction flow including error, empty, and
loading states · non-functional targets (performance numbers, security, observability) ·
integrations and external dependencies · environment and deployment · edge cases and failure
handling · completion signals.

**Spend from the top, close at the waterline.** Every answer re-ranks the open forks by
cost-of-wrong-branch, so ask from the top. The moment the top-ranked fork would cost less to fix
wrong than to ask about — and every question already spent raises that asking price — close:
default-and-tag everything still open. Two consecutive answers that fail to shrink the open-fork
count mean churn rather than convergence; checkpoint if you haven't, otherwise close. This is what
replaces a cap: a question is worth asking when the wrong
branch is expensive, and a fifteenth question on a real migration can clear that bar while a sixth
on a one-file fix does not.

Then write the plan (§6), show the **Defaulted decisions** recap — every `[assumed]` on its own
line so any one can be vetoed cheaply — and ask for approval with "approve" as the recommended
answer. Named changes → apply them and show only the deltas.

## 6. Delivery — files, not chat

The plan is the deliverable and it lives in files, because the executor is a stranger who will
not have this conversation. Write it per `PLAN-FORMAT.md`, which maps the skeleton onto the
project's artifacts: `SPEC.md` (the contract) · `PLAN.md` (build order, assumptions, risks,
verification) · `CONTEXT.md` and `docs/adr/` (terms and hard-to-reverse decisions, per the
`domain-modeling` skill). Run both gates in `PLAN-FORMAT.md` before handing it over, and fix the
document where either fails — never by reopening the interview.

Chat gets the recap and the approval question, not the plan. On a harness that cannot write
files, emit the whole skeleton as one self-contained document in the reply instead.

Close with a statement, not a question: point at the Assumptions Ledger as the complete list of
what you decided on the user's behalf, and invite corrections.

## 7. Landmine hunting

The highest-value output of an interview is the constraint that invalidates the obvious approach.
Check the ask against:

- **Irreversible actions on real data** — deletions, schema drops, force-pushes, spending money,
  messaging real people, anything touching production.
- **Consumers you can't see** — other services, cron jobs, scripts, saved file formats,
  published APIs that depend on what you're about to change.
- **Environment gaps** — works here, runs elsewhere; prod-only behavior; OS and runtime
  differences; offline or locked-down targets.
- **Credentials and accounts that don't exist yet**, including approval lead times.
- **Frozen surfaces** — compatibility contracts, output formats, schemas, interfaces that must
  not move.
- **Scale reality** — dev-sized data versus production-sized; concurrency; 100× the design's
  assumption.
- **Regulated or personal data** — anything leaving the system or persisted where rules apply.
- **Deliberate-looking code** — pinned versions, guarding comments, odd-but-documented choices.
  Surface the evidence and ask before changing them, even when the user asked for the change.
- **The misdiagnosed ask** — the named means may not serve the real end; a "timeout" may be a
  hang rather than slowness.
- **Existing users or data constraining a "greenfield"** build.

**Danger rule:** any destructive or irreversible step earns its own explicit confirmation
question naming the irreversibility, plus a backup, dry-run, or rollback step in the plan — even
when the ask sounded casual.

## 8. Stop rules

Stop interviewing the moment any of these fires, whichever comes first:

1. The rehearsal runs end to end with no open fork, however few questions that took.
2. The completion bar in `PLAN-FORMAT.md` is met.
3. The top-ranked open fork is cheaper to fix wrong than to ask about → default-and-tag
   everything open, route the riskiest checks into the first build phase.
4. The user signals exit — "just plan it", "you pick", visible impatience → finalize immediately
   with tagged defaults.

Until one fires, every turn ends with its one question. After approval, no more questions — write
the plan and stop. If the ask turns out not to be a plannable task at all (a question to answer,
a one-off command), say so and handle it directly instead of forcing an interview.

## Harness notes

- **Structured-question tools** (Claude Code's AskUserQuestion and equivalents): present each
  question through it, recommended answer first and labelled as recommended. One question per
  call — batching defeats the contract. Without one, ask in plain text in the shape above.
- **Plan mode / read-only modes** pair naturally with this skill: recon and interview freely,
  write the artifacts at the end.
- **No file access:** deliver the whole skeleton inline as one document, as above.
- **Subagents, when available,** can run recon in parallel (read the tree, the tests, the CI
  setup) while you interview — but never delegate the interview itself; the questions depend on
  what the last answer changed.
