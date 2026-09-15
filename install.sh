#!/usr/bin/env bash
# fastforward - Claude Code setup in one line (macOS / Linux).
#   curl -fsSL https://raw.githubusercontent.com/tatarco/fastforward/main/install.sh | bash -s -- [core|dev|full]
set -euo pipefail
PROFILE="${1:-dev}"
RAW="https://raw.githubusercontent.com/tatarco/fastforward/main"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
say() { printf '\033[1;36m>> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

main() {
say "prereqs"
if [ "$(uname)" = Darwin ]; then
  have brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for p in node git python3; do have "$p" || brew install "$p"; done
  [ -d "/Applications/Claude.app" ] || brew install --cask claude || true   # Claude Desktop, best effort
else
  have node || { echo "install Node 20+ first (https://nodejs.org)"; exit 1; }
fi
have claude || curl -fsSL https://claude.ai/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"

say "profile: $PROFILE"
fetch() { curl -fsSL "$RAW/$1?$(date +%s)" -o "$WORK/$(basename "$1")"; }  # ?ts busts the raw CDN cache
resolve() {  # expand 'include' lines recursively
  fetch "profiles/$1.txt"
  while read -r kind arg _; do
    case "$kind" in ''|'#'*) ;; include) resolve "$arg" ;; *) echo "$kind $arg" ;; esac
  done < "$WORK/$1.txt"
}
resolve "$PROFILE" | awk '!seen[$0]++' > "$WORK/items"

while read -r kind arg; do
  case "$kind" in
    marketplace) say "marketplace $arg"; claude plugin marketplace add "$arg" </dev/null >/dev/null 2>&1 || true ;;
    plugin)      say "plugin $arg";      out=$(claude plugin install "$arg" 2>&1 </dev/null) || true; echo "$out" | grep -qi "failed" && echo "   $out" | tail -1 ;;
    skill)       say "skill $arg";       npx -y skills add "$arg" -g -y </dev/null >/dev/null 2>&1 || echo "   (failed: $arg)" ;;
  esac
done < "$WORK/items"   # every command above gets </dev/null or it eats this loop's stdin

say "settings + CLAUDE.md"
mkdir -p "$CLAUDE_DIR"
fetch settings.json; fetch merge-settings.mjs
node "$WORK/merge-settings.mjs" "$WORK/settings.json" "$CLAUDE_DIR/settings.json"
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then fetch CLAUDE.md; cp "$WORK/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; else echo "   CLAUDE.md exists, left alone"; fi

say "setup-audit (/setup-audit grades your habits after a week of use)"
[ -d "$CLAUDE_DIR/skills/setup-audit" ] || git clone -q https://github.com/tatarco/claude-setup-audit "$CLAUDE_DIR/skills/setup-audit"

say "done - open a terminal in a project and run: claude"
echo "   browser automation: install 'Claude in Chrome' -> https://claude.ai/chrome"
}
main "$@"   # whole file parsed before anything runs, so curl|bash is safe
