# fastforward - Claude Code setup in one line (Windows).
#   irm https://raw.githubusercontent.com/tatarco/fastforward/main/install.ps1 | iex
#   $env:FF_PROFILE="full"; irm ... | iex        # core | dev (default) | full
$ErrorActionPreference = "Continue"
$Profile_ = if ($env:FF_PROFILE) { $env:FF_PROFILE } else { "dev" }
$Raw = "https://raw.githubusercontent.com/tatarco/fastforward/main"
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
$Work = Join-Path ([IO.Path]::GetTempPath()) ("ff-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Work -Force | Out-Null
function Say($m) { Write-Host ">> $m" -ForegroundColor Cyan }
function Have($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }
function RefreshPath { $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") }

Say "prereqs"
if ($IsWindows -or $env:OS -eq "Windows_NT") {
  if (-not (Have winget)) { Write-Host "winget missing - install 'App Installer' from the Microsoft Store, then re-run"; return }
  if (-not (Have node))   { winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent }
  if (-not (Have git))    { winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements --silent }
  if (-not (Have python)) { winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent }
  if (-not (Test-Path "$env:LOCALAPPDATA\Programs\Claude")) { winget install -e --id Anthropic.Claude --accept-source-agreements --accept-package-agreements --silent }  # Claude Desktop, best effort
  RefreshPath
}
if (-not (Have claude)) { irm https://claude.ai/install.ps1 | iex; RefreshPath }

Say "profile: $Profile_"
function Fetch($rel) { $out = Join-Path $Work (Split-Path $rel -Leaf); irm "$Raw/$rel?$([DateTimeOffset]::Now.ToUnixTimeSeconds())" -OutFile $out; $out }  # ?ts busts the raw CDN cache
function Resolve-Profile($name) {
  $file = Fetch "profiles/$name.txt"
  foreach ($line in Get-Content $file) {
    $line = $line.Trim(); if (-not $line -or $line.StartsWith("#")) { continue }
    $kind, $arg = $line -split '\s+', 2
    if ($kind -eq "include") { Resolve-Profile $arg } else { "$kind $arg" }
  }
}
$Items = Resolve-Profile $Profile_ | Select-Object -Unique

foreach ($item in $Items) {
  $kind, $arg = $item -split ' ', 2
  switch ($kind) {
    "marketplace" { Say "marketplace $arg"; claude plugin marketplace add $arg *> $null }
    "plugin"      { Say "plugin $arg";      $out = (claude plugin install $arg 2>&1 | Out-String); if ($out -match "Failed") { Write-Host "   $($out.Trim())" } }
    "skill"       { Say "skill $arg";       npx -y skills add $arg -g -y *> $null; if ($LASTEXITCODE) { Write-Host "   (failed: $arg)" } }
  }
}

Say "settings + CLAUDE.md"
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
$kit = Fetch "settings.json"; $merge = Fetch "merge-settings.mjs"
node $merge $kit (Join-Path $ClaudeDir "settings.json")
$cm = Join-Path $ClaudeDir "CLAUDE.md"
if (-not (Test-Path $cm)) { Copy-Item (Fetch "CLAUDE.md") $cm } else { Write-Host "   CLAUDE.md exists, left alone" }

Say "setup-audit (/setup-audit grades your habits after a week of use)"
$audit = Join-Path $ClaudeDir "skills\setup-audit"
if (-not (Test-Path $audit)) { git clone -q https://github.com/tatarco/claude-setup-audit $audit }

Remove-Item $Work -Recurse -Force -ErrorAction SilentlyContinue
Say "done - open Windows Terminal in a project folder and run: claude"
Write-Host "   browser automation: install 'Claude in Chrome' -> https://claude.ai/chrome"
Write-Host "   parallel agents:    Windows Terminal split panes (Alt+Shift+D) - each pane its own claude"
