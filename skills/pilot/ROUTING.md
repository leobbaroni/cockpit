# Specialist routing


Route to the named skill **when it's installed**; when it isn't, do the work directly to the same standard and say so — never silently improvise what a specialist owns, and never fail a task just because an optional specialist is absent.

| Work | Specialist |
|---|---|
| Design, UI, motion, 3D, video authoring or critique | `maestro` |
| Rendering/authoring a video end-to-end | `hyperframes` (its router picks the workflow) |
| Music, SFX, images, icons, logos, voiceover | `media-use` |
| Brief-locking interview | `grilling` (+ `domain-modeling` = `grill-with-docs`) |
| Task batches (3+), multi-agent builds, review waves | `orchestrate` |
| Hard bugs, perf regressions | `diagnosing-bugs` |
| Implementing any feature, fix, refactor, or behavior change | `test-driven-development` — the failing test comes first |
| Isolating a workspace before a feature or a batch | `using-worktrees` — native tool first, `git worktree` only as fallback |
| Glossary terms, ADRs | `domain-modeling` |
| Logs, guides, manuals, delivery cleanup | `handoff` |
| Repo/corpus knowledge-graph questions | `graphify` |
| Community/social sentiment research | `agent-reach` |
| **Business-domain work the pack doesn't cover** — security posture, finance, legal, hiring, GTM, support, program governance | `headcount`, **one department at a time** (see below) |
| Deep multi-source cited research | `deep-research` |

### Reaching outside the pack — headcount, one department at a time

Some requests are real work this pack has no opinion on: a threat model, a pricing structure, a
hiring loop, a contract review. [headcount](https://github.com/cbrock84/headcount) covers them —
16 departments, 172 skills, MIT, each department independently installable.

**Install the department the requirement names, never the whole marketplace.** Always-on cost
scales with the *number* of skills installed, so all 172 would cost roughly 17× this entire pack
and slow every unrelated session. One department is 6–19 skills. Match the requirement, propose
the single install, and let the user approve it:

| The request is really about | Department |
|---|---|
| Threat modeling, security review, compliance posture | `security` |
| Architecture strategy, AI/agent workflow design, technical direction | `technology` |
| Pricing, forecasting, unit economics, budgets | `finance` |
| Contracts, privacy, risk register | `legal-risk` |
| Hiring, onboarding, performance, compensation | `people` |
| Positioning, content, brand campaigns | `marketing` |
| Lead gen, funnels, paid acquisition | `demand-generation` |
| Pipeline, quotas, deal desk | `revenue` |
| Roadmap, discovery, PRDs, prioritisation | `product` |
| Metrics, dashboards, experiment design | `data-analytics` |
| Support, churn, CSAT | `customer-experience` |
| Runbooks, incidents, vendors, internal tooling | `it-operations` / `operations` |
| Programs, dependencies, delivery governance | `pmo` |
| Board reporting, org design, strategy | `executive` / `corporate-strategy` |

**Claude Code** — a plugin marketplace, so two commands then `/reload-plugins`:

```
/plugin marketplace add cbrock84/headcount
/plugin install <department>@headcount
```

Skills then autocomplete namespaced as `department:skill` — `security:threat-modeling`.

**Codex and other AGENTS.md harnesses** — there is no plugin system, and the skills are plain
Markdown, so clone once and read the one department you need:

```
git clone --depth 1 https://github.com/cbrock84/headcount
```

Then read `plugins/<department>/skills/<skill>/SKILL.md` directly when a request matches it. The
same one-department discipline applies for the same reason — reading all 172 into context is the
bloat the per-department split exists to avoid.

Treat it exactly like every other outside specialist: **when it isn't installed, do the work
directly to the same standard and say the specialist was absent** — never fail a task because an
optional pack is missing, and never install one without asking.
