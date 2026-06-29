---
description: Hard refresh — kill this claude and relaunch a pristine fresh instance
allowed-tools: Bash
---
The user wants a HARD REFRESH: terminate this claude process so the shell
wrapper relaunches a brand-new instance with empty context.

Run EXACTLY this one Bash command. Do not explain it, do not add commentary,
do not run anything before or after it:

```bash
touch ~/.claude/.purge; pid=$PPID; while [ -n "$pid" ] && [ "$pid" -ne 1 ] 2>/dev/null; do [ "$(ps -o comm= -p "$pid" 2>/dev/null | tr -d ' ')" = claude ] && { kill "$pid"; break; }; pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' '); done
```

(It drops the `~/.claude/.purge` sentinel, walks up the process tree to find
the `claude` process, and SIGTERMs it. The `claude()` shell wrapper sees the
sentinel on exit and relaunches a fresh session.)
