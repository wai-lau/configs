---
description: Restart Claude Code on this same conversation; background tasks, subagents and workflows carry on
allowed-tools: Bash
---
The user wants a RESTART: relaunch Claude Code (latest build; settings, hooks,
plugins and CLAUDE.md re-read) and resume this same conversation.

Background Bash tasks keep running through it. Subagents and workflow runs die
with this process, but their transcripts are on disk: the relaunched session's
first prompt lists every one that was in flight, and it continues them
(SendMessage to an agent id, Workflow resumeFromRunId).

Run EXACTLY this one Bash command, with no commentary before or after:

```bash
bash ~/.claude/restart.sh
```

If it prints a line starting with "restart:", show the user that line and stop.
