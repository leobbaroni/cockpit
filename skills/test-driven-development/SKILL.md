---
name: test-driven-development
description: Write the failing test first, watch it fail, then write the minimal code that passes. Use when implementing any feature, bugfix, refactor, or behavior change — before writing implementation code. Also use when the user says "TDD", "test first", "red-green-refactor", or asks why a passing test proves nothing.
---

# Test-Driven Development

Write the test first. **Watch it fail.** Write the minimal code that makes it pass. Then clean up while it stays green.

**The reason the failure matters:** a test you never saw fail is a test you never saw *work*. It might assert nothing, target the wrong function, sit in a file the runner skips, or pass on a typo. Watching it go red is the only evidence that it can detect the absence of the thing you are about to build — and detecting absence is the entire job.

## The iron law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote the code before the test? **Delete it and start over from the test.** Not "keep it open as reference", not "adapt it while writing the test", not "glance at it to remember the shape". Delete means delete, and implement fresh from what the test demands.

That looks wasteful and isn't. Code written before its test encodes the shape you already imagined; the test then gets written to fit *it*, which is how a suite ends up asserting what the code does rather than what the feature needs. The rewrite is short — you still remember the problem — and what you lose is only the bias.

**Applies to:** new features · bug fixes · refactors · any behavior change.
**Ask before skipping for:** throwaway prototypes · generated code · pure configuration.

"Just this once" is the rationalization this law exists to catch. So are "the test is obvious", "I'll add tests right after", and "it's too small to test" — the last one being how most untested code enters a repo.

## Red → Green → Refactor

### Red — one failing test

One behavior per test, named so the failure output alone tells you what broke. `retries failed operations three times` beats `retry works`.

Test **real code**. A test built on mocks asserts that your mocks were called, which is a fact about the test rather than about the system. Reach for a mock only when the real thing is genuinely unavailable — a network the CI can't reach, a clock you must control, a paid API — and never for code you own and could just call.

### Verify red — mandatory, never skipped

Run the test. Read the output. Then ask the question that makes this step worth anything:

**Did it fail for the right reason?** A test that errors on a typo, an unresolved import, a missing fixture, or a syntax error has told you nothing about your feature. The correct red is an assertion failure, or a "function is not defined" for the function you are about to write. Anything else means fix the test and run it again — you are not yet at red.

### Green — the minimal code that passes

Write the least code that turns it green. Not the general version, not the configurable version, not the version handling the case the next test will cover. Minimal is a discipline, not a shortcut: it keeps every line traceable to a test that demanded it.

Then run the **whole** suite, not just the new test. A local green with three regressions elsewhere is a red.

### Refactor — while green

Clean up with the tests passing, running them after each change. If they go red, the refactor changed behavior — revert and do it in smaller steps. Refactoring is the step where the suite pays you back, so skipping it while telling yourself you'll tidy later is how the payment never arrives.

## Bug fixes invert the order, and that's the point

A bug fix starts with a test that **reproduces the bug and fails because the bug exists**. That test is the proof the bug was real, the proof the fix works, and the guard that stops it coming back — three jobs from one artifact.

Fixing first and adding the test afterwards forfeits all three: you never saw the test fail, so you never confirmed it detects the bug at all. `diagnosing-bugs` owns the harder case where the cause is unknown; this skill takes over once you can make it fail on demand.

## What a passing test does not prove

| Claim | What actually proves it |
|---|---|
| "The tests pass" | You ran the full suite **this message** and read the count |
| "The build is fine" | The build command exited 0 — a green linter is not a build |
| "This is done" | The behavior was driven, not just typechecked |
| "The fix works" | A test that failed before the fix and passes after |
| "Nothing else broke" | The full suite, not the file you touched |

**No completion claim without fresh evidence in the same message.** A run from before your last edit is not evidence about the code as it stands now. Paste the command and its output rather than characterizing them — "all green" is a summary, and summaries are where the failures hide.

## Harness notes

**Claude Code:** run the suite with Bash and read real output; long suites go in the background and get waited on once, never polled in a sleep loop. When `orchestrate` fans work out, every subagent is bound by the iron law — an implementer that returns code without a test it watched fail has not finished, and its claim is unverified until the lead runs the suite.

**Codex and other AGENTS.md harnesses:** identical discipline, no subagents — write the test, run it, read it, then implement. The temptation to batch several tests before running any is stronger without a fan-out to structure the work; resist it, because a batch of unrun tests is a batch of unverified assumptions.
