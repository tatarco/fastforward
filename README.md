# fastforward

Claude Code, set up the way I use it, in one line. Mac and Windows.

**macOS / Linux**
```sh
curl -fsSL https://raw.githubusercontent.com/tatarco/fastforward/main/install.sh | bash
```

**Windows** (PowerShell)
```powershell
irm https://raw.githubusercontent.com/tatarco/fastforward/main/install.ps1 | iex
```

Then open a terminal in a project folder and run `claude`.

## What you get

| profile | contents |
|---|---|
| `core` | Claude Code + Claude Desktop, superpowers (brainstorm → plan → TDD → review), commit commands, find-skills |
| `dev` (default) | core + planning (all of Matt Pocock's skills, feature-dev) + frontend design (impeccable, taste-skill, Emil Kowalski, fe-gal, fe-ux-patterns, repair-engine) + telegram-notify |
| `full` | dev + ui-ux-pro-max, last30days, the whole impeccable / Emil / taste catalogs |

Pick one: `... | bash -s -- full` on mac, `$env:FF_PROFILE="full"; irm ... | iex` on Windows.

Also written: a short `~/.claude/CLAUDE.md` (terse output, cheap subagent models, one task per
session) and a `settings.json` fragment (read-deny for `.env`/keys/`node_modules`, output caps).
Existing files are merged, never overwritten; a `.bak-<timestamp>` is left next to `settings.json`.

Re-run any time. Everything is idempotent.

## After a week

```
/setup-audit
```

grades your habits from your own local logs (nothing leaves the machine). It's installed for you.

## Mac tool → Windows equivalent

| on my mac | on Windows |
|---|---|
| ego-lite (agent browser) | [Claude in Chrome](https://claude.ai/chrome) extension |
| cmux (multi-agent terminal) | Windows Terminal split panes, one `claude` per pane; `EnterWorktree` for isolation |
| `say` voice hook | not installed (add `System.Speech` yourself if you want it) |

## Layout

```
install.sh / install.ps1   the whole installer, one file per OS
profiles/*.txt             one item per line: plugin | skill | marketplace | include
settings.json              merged into ~/.claude/settings.json (yours wins)
CLAUDE.md                  copied only if you have none
merge-settings.mjs         the merge, run with node on both OSes
```
