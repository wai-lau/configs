---
description: Restart Claude Code on this same conversation; background Bash tasks keep running
allowed-tools: Bash
---
The user wants a RESTART: relaunch Claude Code (latest build; settings, hooks,
plugins and CLAUDE.md re-read) and resume this same conversation. Background
Bash tasks survive it, and the relaunched session's first prompt lists them so
it can pick them back up.

Subagents and workflows run inside this process and die with it. If any are
still running, name them and ask the user before going on, unless the user's
arguments say to go ahead anyway. Arguments: $ARGUMENTS

Otherwise run EXACTLY this one Bash command, with no commentary before or after:

```bash
bash ~/.claude/restart.sh
```

If it prints a line starting with "restart:", show the user that line and stop.
