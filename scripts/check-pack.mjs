#!/usr/bin/env node
// Cross-harness integrity check for the cockpit pack.
//
//   node scripts/check-pack.mjs                 check cockpit
//   node scripts/check-pack.mjs ../maestro      also check maestro's router and counts
//
// Exits non-zero on any failure, so CI can gate on it.
//
// What it exists to catch: a skill that cites a sibling that isn't shipped, an
// AGENTS.md index that has drifted from skills/ (which silently breaks every
// non-Claude harness), Claude-only machinery written without a fallback, and a
// stated count that no longer matches what is on disk.

import { readFileSync, existsSync, readdirSync, statSync } from "node:fs";
import { join, basename } from "node:path";

const root = new URL("..", import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1");
const maestro = process.argv[2] ? join(process.cwd(), process.argv[2]) : join(root, "..", "maestro");
const fails = [];
// Normalise line endings: a repo checked out on Windows mixes CRLF and LF, and a
// checker that fails on CRLF is reporting its own brittleness as a pack defect.
const read = (p) => readFileSync(p, "utf8").replace(/\r\n/g, "\n");
const dirs = (p) => (existsSync(p) ? readdirSync(p).filter((d) => statSync(join(p, d)).isDirectory()) : []);

function check(ok, label, detail = "") {
  console.log(`  ${ok ? "PASS" : "FAIL"}  ${label}${ok || !detail ? "" : `  -> ${detail}`}`);
  if (!ok) fails.push(label);
}

const skillsDir = join(root, "skills");
const skills = dirs(skillsDir).filter((d) => existsSync(join(skillsDir, d, "SKILL.md")));

console.log(`\n== frontmatter (${skills.length} skills) ==`);
for (const s of skills) {
  const body = read(join(skillsDir, s, "SKILL.md"));
  const fm = body.match(/^---\n([\s\S]*?)\n---\n/);
  const name = fm && (fm[1].match(/^name:\s*(\S+)/m) || [])[1];
  check(Boolean(fm) && /description:/.test(fm[1]) && name === s, `${s}: name matches directory`, `declared=${name}`);
}

console.log("\n== AGENTS.md is the non-Claude router: its index must match skills/ ==");
const agents = read(join(root, "AGENTS.md"));
const indexed = [...agents.matchAll(/`skills\/([a-z-]+)\/SKILL\.md`/g)].map((m) => m[1]);
const onlyDisk = skills.filter((s) => !indexed.includes(s));
const onlyIndex = indexed.filter((s) => !skills.includes(s));
check(onlyDisk.length === 0 && onlyIndex.length === 0, "AGENTS.md index matches skills/",
  `unindexed=${JSON.stringify(onlyDisk)} phantom=${JSON.stringify(onlyIndex)}`);

console.log("\n== in-pack cross-references resolve ==");
const namePattern = new RegExp("`(" + skills.join("|") + ")`", "g");
for (const s of skills) {
  const body = read(join(skillsDir, s, "SKILL.md"));
  const cited = [...body.matchAll(namePattern)].map((m) => m[1]);
  const missing = [...new Set(cited)].filter((c) => !skills.includes(c));
  check(missing.length === 0, `${s}: cites only shipped siblings`, JSON.stringify(missing));
}

console.log("\n== harness neutrality: Claude-only machinery needs a label or a fallback ==");
const CLAUDE_ONLY = /AskUserQuestion|TaskCreate|TaskUpdate|\/reload-plugins|\/plugin install|model:\s*"(opus|sonnet|haiku)"/;
const LABELLED = /Claude Code|Codex|harness|without subagents|substitute|Tier 0/;
for (const s of skills) {
  const full = read(join(skillsDir, s, "SKILL.md"));
  const lines = full.split(/^## Harness notes/m)[0].split("\n");
  const bad = [];
  lines.forEach((ln, i) => {
    if (CLAUDE_ONLY.test(ln) && !LABELLED.test(lines.slice(Math.max(0, i - 12), i + 1).join(" "))) {
      bad.push(ln.trim().slice(0, 60));
    }
  });
  check(bad.length === 0, `${s}: no unlabelled Claude-only machinery`, JSON.stringify(bad.slice(0, 2)));
}

console.log("\n== stated counts match reality ==");
const words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
  "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty"];
const word = words[skills.length] ?? String(skills.length);
for (const f of ["README.md", "AGENTS.md", "CLAUDE.md"]) {
  const t = read(join(root, f));
  const wrong = words.filter((w, n) => n !== skills.length && n > 2 &&
    new RegExp(`${w} (process skills|interlocking process skills|skills ship)`, "i").test(t));
  check(wrong.length === 0, `${f}: no stale skill count`, `says ${JSON.stringify(wrong)}, actual ${word}`);
}

if (existsSync(join(maestro, "skills", "maestro", "SKILL.md"))) {
  console.log("\n== maestro (companion) ==");
  const mroot = join(maestro, "skills", "maestro");
  const refs = readdirSync(join(mroot, "references")).filter((f) => f.endsWith(".md"));
  const router = read(join(mroot, "SKILL.md"));
  const cited = [...new Set([...router.matchAll(/`([a-z0-9-]+\.md)`/g)].map((m) => m[1]))];
  const missing = cited.filter((c) => !refs.includes(c));
  check(missing.length === 0, "router citations resolve to reference modules", JSON.stringify(missing));

  let badLib = [];
  for (const f of refs) {
    for (const m of read(join(mroot, "references", f)).matchAll(/library\/[A-Za-z0-9_./-]+/g)) {
      const rel = m[0].replace(/[.,)]+$/, "");
      if (!existsSync(join(mroot, rel))) badLib.push(`${f}:${rel}`);
    }
  }
  check(badLib.length === 0, "every library/ pointer exists", JSON.stringify(badLib.slice(0, 3)));
  check(read(join(maestro, "README.md")).includes(`${refs.length} modules`),
    `README module count == ${refs.length}`);
  check(existsSync(join(maestro, "AGENTS.md")), "maestro AGENTS.md present (non-Claude entry point)");
} else {
  console.log("\n== maestro not found alongside — skipped (pass a path to include it) ==");
}

console.log("\n" + (fails.length ? `${fails.length} FAILURE(S)` : "ALL CHECKS PASSED"));
process.exit(fails.length ? 1 : 0);
