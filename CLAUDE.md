## Output Style
Be terse. No preamble, no summary of what you just did, no "Great question!". Code blocks only when writing code. One-sentence answers when one sentence suffices.

## Agent Model Selection
Default subagent model is haiku; justify sonnet or opus.
- read files, grep, count, gather data, browser automation, UI checks -> haiku
- implementation, refactoring, debugging, analysis -> sonnet
- architecture decisions, novel debugging, cross-cutting design -> opus

## Sessions
New task = new session. Do not let one session run for days.
