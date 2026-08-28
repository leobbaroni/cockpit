---
name: using-worktrees
description: Ensure feature work happens in an isolated workspace before it starts. Detect existing isolation first, prefer the harness's native worktree tool, fall back to git worktree, verify the directory is ignored, install dependencies, and confirm a clean test baseline. Use before executing an implementation plan, starting a multi-file feature, or any batch that would otherwise run on the user's current branch.
---

# Using Worktrees

Work that will touch many files does not start on whatever branch the user happens to have checked out. Get an isolated workspace first, confirm it starts green, and only then begin.

**Order of preference, and it matters:** detect isolation you already have → use the harness's native tool → fall back to `git worktree`. Never fight the harness.

## Step 0 — are you already isolated?

Check before creating anything. Harness-created isolation is invisible to eyeballing, and a second worktree stacked on the first is confusing state nobody asked for.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
git rev-parse --show-superproject-working-tree 2>/dev/null   # non-empty = submodule
```

`GIT_DIR != GIT_COMMON` means a linked worktree — **skip to Step 2, create nothing.** But that same inequality is true inside a **git submodule**, so run the superproject check before concluding it: if it prints a path you are in a submodule, which is a normal checkout for this purpose.

Report what you found, including the branch, because "already isolated" on an unexpected branch is worth the user's attention. On a detached HEAD, say so — a branch will have to be created at finish time.

**If you are in a normal checkout, ask before creating one**, unless the user has already stated a preference in their instructions — in which case honor it silently:

> "Want me to set up an isolated worktree? It keeps your current branch untouched."

If they decline, work in place and skip to Step 2. That is a legitimate choice, not a problem to route around.

## Step 1 — create the workspace

### Native tool first

If the harness offers one — a tool named like `EnterWorktree`, a `/worktree` command, a `--worktree` flag — **use it.** It owns directory placement, branch creation, and cleanup, and it can see what it made.

Reaching for `git worktree add` when a native tool exists is the characteristic mistake here: it creates state the harness doesn't know about, so nothing cleans it up and the user finds a stray directory later. Only continue to the fallback when there genuinely is no native tool.

### Git fallback

**Directory, in priority order:** an explicit preference in your instructions beats an existing project-local directory, which beats the default. Look for `.worktrees/` then `worktrees/`; if both exist, `.worktrees/` wins. With no other guidance, default to `.worktrees/` at the project root.

**Then verify it is ignored before creating anything in it:**

```bash
git check-ignore -q .worktrees || git check-ignore -q worktrees
```

If it is not ignored, add it to `.gitignore` and commit that first. Skipping this check commits the entire worktree — a full second copy of the repo — into the repo.

```bash
git worktree add ".worktrees/$BRANCH" -b "$BRANCH"
```

**If creation fails on a permission error**, the sandbox blocked it. Say so plainly, then work in the current directory and run setup and baseline there — don't retry the same command hoping for a different result.

## Step 2 — set up and get a clean baseline

Install what the project declares — `package.json` → `npm install`, `Cargo.toml` → `cargo build`, `requirements.txt` / `pyproject.toml` → the Python install, `go.mod` → `go mod download`. Skip silently when none is present.

Then **run the test suite before writing any code.**

This is the step people skip and the one that pays. A baseline you never took makes every later failure ambiguous: you cannot tell your regression from the one that was already there, and you will spend real time debugging someone else's. Thirty seconds now removes that whole category of confusion.

**If the baseline fails, report the failures and ask** whether to proceed or investigate first. Proceeding onto a red baseline is the user's call, and it is a reasonable one when the failures are known and unrelated — but it is theirs to make, and it should be recorded so the end-of-task suite run is read against the right starting point.

Report concretely:

```
Worktree ready at <full path>, branch <name>
Baseline: 148 tests, 0 failures
Ready to implement <feature>
```

## Quick reference

| Situation | Do |
|---|---|
| `GIT_DIR != GIT_COMMON`, not a submodule | Already isolated — skip creation |
| In a submodule | Normal checkout; the inequality is a false positive |
| Native worktree tool exists | Use it, always |
| No native tool | `git worktree add`, after the ignore check |
| Both `.worktrees/` and `worktrees/` exist | `.worktrees/` wins |
| Directory not ignored | Add to `.gitignore` and commit **first** |
| Creation fails on permissions | Sandbox — say so, work in place |
| Baseline red | Report and ask; don't decide alone |
| User declines a worktree | Work in place; still take the baseline |

## Why not just branch?

A branch shares one working directory, so switching means stashing, and a long-running task that switches away mid-flight loses its build state and its running dev server. A worktree gives the task its own directory on its own branch — the user's checkout keeps its state, `orchestrate`'s parallel agents can hold separate trees without colliding, and abandoning the work is deleting a directory rather than unpicking a merge.

The cost is disk and one setup run. For a single-file edit that is not worth it; for anything `pilot` would route through PLAN or a batch, it is.
