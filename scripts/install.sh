#!/usr/bin/env bash
# cockpit — one-command install (macOS / Linux / Git Bash)
#   curl -fsSL https://raw.githubusercontent.com/leobbaroni/cockpit/main/scripts/install.sh | bash
#   ./install.sh --yes            skip prompts
#   ./install.sh --check          detect only, change nothing
set -uo pipefail

YES=0; CHECK=0
for a in "$@"; do
  case "$a" in
    --yes|-y) YES=1 ;;
    --check|-n) CHECK=1 ;;
    --help|-h) sed -n '2,6p' "$0"; exit 0 ;;
  esac
done

ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

ask() {  # ask "prompt"  -> 0 yes, 1 no
  [ "$CHECK" = 1 ] && return 1
  [ "$YES" = 1 ] && return 0
  [ -t 0 ] || { warn "not a TTY — skipping (re-run with --yes to accept)"; return 1; }
  read -r -p "    $1 [y/N] " r < /dev/tty
  [[ "$r" =~ ^[Yy] ]]
}

have() { command -v "$1" >/dev/null 2>&1; }

FAILED=0

head_ "1. Runtime prerequisites"
if have node; then
  NV=$(node --version | sed 's/v//;s/\..*//')
  [ "$NV" -ge 22 ] && ok "node $(node --version)" || { bad "node $(node --version) — the video toolchain needs >= 22"; FAILED=1; }
else
  bad "node — install from https://nodejs.org (>= 22)"; FAILED=1
fi
have ffmpeg && ok "ffmpeg $(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')" || {
  warn "ffmpeg absent — HyperFrames can compose and check a video but cannot encode one"
  case "$(uname -s)" in
    Darwin) C="brew install ffmpeg" ;;
    *) C="sudo apt install ffmpeg" ;;
  esac
  if ask "install ffmpeg with: $C ?"; then $C && ok "ffmpeg installed" || bad "ffmpeg install failed"; else warn "skipped — run: $C"; fi
}

head_ "2. The pack (cockpit + maestro)"
if have claude; then
  if [ "$CHECK" = 0 ]; then
    claude plugin marketplace add leobbaroni/cockpit >/dev/null 2>&1
    claude plugin install cockpit@cockpit  >/dev/null 2>&1
    claude plugin enable  maestro@cockpit  >/dev/null 2>&1   # upgrade path from <= 1.5.0
  fi
  claude plugin list 2>/dev/null | grep -q "cockpit@cockpit" && ok "cockpit" || { bad "cockpit not installed"; FAILED=1; }
  claude plugin list 2>/dev/null | grep -q "maestro@cockpit" && ok "maestro (dependency)" || { bad "maestro missing"; FAILED=1; }
else
  bad "claude CLI not found — install Claude Code first, or use the AGENTS.md path in INSTALL.md"; FAILED=1
fi

head_ "3. impeccable — the design roll"
# maestro's direction round hands off to impeccable's dice-dealt roll when present.
if [ -f "$HOME/.claude/skills/impeccable/scripts/concept-seed.mjs" ]; then
  ok "impeccable v$(grep -m1 '^version:' "$HOME/.claude/skills/impeccable/SKILL.md" 2>/dev/null | awk '{print $2}') — roll scripts present"
else
  warn "impeccable absent or stale — the direction round falls back to maestro's prose"
  if ask "install from github.com/pbakaus/impeccable (npx impeccable install)?"; then
    npx --yes impeccable install --providers=claude --scope=global && ok "impeccable installed" || bad "impeccable install failed"
  else
    warn "skipped — run: npx impeccable install --providers=claude --scope=global"
  fi
fi

head_ "4. Video stack (optional)"
if have claude && claude plugin list 2>/dev/null | grep -q "hyperframes"; then
  ok "hyperframes suite (19 skills, incl. media-use + figma)"
else
  warn "hyperframes absent — no HTML-to-video authoring, no media-use asset resolution"
  if ask "install hyperframes@claude-plugins-official? (~2,540 always-on tokens)"; then
    claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1
    claude plugin install hyperframes@claude-plugins-official >/dev/null 2>&1 && ok "hyperframes installed" || bad "hyperframes install failed"
  else
    warn "skipped — only needed if you render video"
  fi
fi

head_ "Result"
if [ "$CHECK" = 1 ]; then
  echo "  (check only — nothing was changed)"
elif [ "$FAILED" = 0 ]; then
  ok "stack ready"
else
  bad "some items need attention — see above"
fi
cat <<'NEXT'

  Next, in Claude Code:
    /reload-plugins        plugin installs are invisible to the skill watcher until you do
    /cockpit:setup         verifies what this machine can actually do
    /cockpit:pilot         the entry point for any project work

NEXT
exit $FAILED
