<#
  cockpit - one-command install (Windows PowerShell)
    irm https://raw.githubusercontent.com/leobbaroni/cockpit/main/scripts/install.ps1 | iex
    .\install.ps1 -Yes      skip prompts
    .\install.ps1 -Check    detect only, change nothing
#>
param([switch]$Yes, [switch]$Check)

function Ok   ($m) { Write-Host "  [ok] $m"   -ForegroundColor Green }
function Bad  ($m) { Write-Host "  [--] $m"   -ForegroundColor Red }
function Warn ($m) { Write-Host "  [!!] $m"   -ForegroundColor Yellow }
function Section ($m) { Write-Host ""; Write-Host $m -ForegroundColor White }
function Have ($c) { $null -ne (Get-Command $c -ErrorAction SilentlyContinue) }

function Ask ($m) {
  if ($Check) { return $false }
  if ($Yes)   { return $true }
  if (-not [Environment]::UserInteractive) { Warn "non-interactive - skipping (re-run with -Yes)"; return $false }
  $r = Read-Host "    $m [y/N]"
  return ($r -match '^[Yy]')
}

$Failed = 0

Section "1. Runtime prerequisites"
if (Have node) {
  $nv = [int](((node --version) -replace 'v','') -split '\.')[0]
  if ($nv -ge 22) { Ok "node $(node --version)" }
  else { Bad "node $(node --version) - the video toolchain needs >= 22"; $Failed = 1 }
} else { Bad "node - install from https://nodejs.org (>= 22)"; $Failed = 1 }

if (Have ffmpeg) {
  Ok "ffmpeg $((ffmpeg -version 2>$null | Select-Object -First 1) -split ' ' | Select-Object -Index 2)"
} else {
  Warn "ffmpeg absent - HyperFrames can compose and check a video but cannot encode one"
  if (Ask "install ffmpeg with: winget install Gyan.FFmpeg ?") {
    winget install --id Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
    Warn "open a NEW terminal before re-checking - PATH changes do not reach a running shell"
  } else { Warn "skipped - run: winget install Gyan.FFmpeg" }
}

Section "2. The pack (cockpit + maestro)"
if (Have claude) {
  if (-not $Check) {
    claude plugin marketplace add leobbaroni/cockpit *> $null
    claude plugin install cockpit@cockpit *> $null
    claude plugin enable  maestro@cockpit *> $null   # upgrade path from <= 1.5.0
  }
  $list = (claude plugin list 2>$null) -join "`n"
  if ($list -match 'cockpit@cockpit') { Ok "cockpit" } else { Bad "cockpit not installed"; $Failed = 1 }
  if ($list -match 'maestro@cockpit') { Ok "maestro (dependency)" } else { Bad "maestro missing"; $Failed = 1 }
} else { Bad "claude CLI not found - install Claude Code first, or use the AGENTS.md path in INSTALL.md"; $Failed = 1 }

Section "3. impeccable - the design roll"
# maestro's direction round hands off to impeccable's dice-dealt roll when present.
$imp = Join-Path $HOME ".claude\skills\impeccable\scripts\concept-seed.mjs"
if (Test-Path $imp) {
  $v = (Select-String -Path (Join-Path $HOME ".claude\skills\impeccable\SKILL.md") -Pattern '^version:' | Select-Object -First 1)
  Ok "impeccable $($v -replace '.*version:\s*','') - roll scripts present"
} else {
  Warn "impeccable absent or stale - the direction round falls back to maestro's prose"
  if (Ask "install from github.com/pbakaus/impeccable (npx impeccable install)?") {
    npx --yes impeccable install --providers=claude --scope=global
    if (Test-Path $imp) { Ok "impeccable installed" } else { Bad "impeccable install failed" }
  } else { Warn "skipped - run: npx impeccable install --providers=claude --scope=global" }
}

Section "4. Video stack (optional)"
$list = if (Have claude) { (claude plugin list 2>$null) -join "`n" } else { "" }
if ($list -match 'hyperframes') {
  Ok "hyperframes suite (19 skills, incl. media-use + figma)"
} else {
  Warn "hyperframes absent - no HTML-to-video authoring, no media-use asset resolution"
  if (Ask "install hyperframes@claude-plugins-official? (~2,540 always-on tokens)") {
    claude plugin marketplace add anthropics/claude-plugins-official *> $null
    claude plugin install hyperframes@claude-plugins-official *> $null
    Ok "hyperframes installed"
  } else { Warn "skipped - only needed if you render video" }
}

Section "Result"
if ($Check)          { Write-Host "  (check only - nothing was changed)" }
elseif ($Failed -eq 0) { Ok "stack ready" }
else                 { Bad "some items need attention - see above" }

Write-Host @"

  Next, in Claude Code:
    /reload-plugins        plugin installs are invisible to the skill watcher until you do
    /cockpit:setup         verifies what this machine can actually do
    /cockpit:pilot         the entry point for any project work
"@
exit $Failed
