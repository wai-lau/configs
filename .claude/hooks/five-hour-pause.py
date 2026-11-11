#!/usr/bin/env python3
"""PreToolUse: pause work when the 5-hour Claude usage window hits 95%.

At five_hour.utilization >= 95 every tool call is denied except the ones a
session needs to pause cleanly: write resume notes (Read/Write/Edit), load
and schedule a one-shot resume (ToolSearch, CronCreate/List/Delete,
ScheduleWakeup), stop background work (TaskStop) and tell peers
(SendMessage). The deny reason tells the model what to do (Wai, 2026-11-10:
"do this globally when claude 5h usage is up to 95%").

Applies to everything on the WSL desktop, headless `claude -p` runs too,
and ignores `pace-snooze` (Wai, 2026-11-11: "Five hour pause should ignore
the pace snooze, it should always kick in for anything on the desktop at
95% of 5h"). Allow (never brick): the droplet (no /mnt/c); cache missing or
stale (>10 min); reset time already past. Data: ~/.claude/cache/statusline_usage.json (statusline, every 60s).
"""
import json, os, sys, time
from datetime import datetime

CACHE = os.path.expanduser('~/.claude/cache/statusline_usage.json')
LINE = 95.0
PAUSE_TOOLS = {'Read', 'Write', 'Edit', 'ToolSearch', 'CronCreate', 'CronList',
               'CronDelete', 'ScheduleWakeup', 'TaskStop', 'SendMessage'}


def main():
    try:
        tool = json.load(sys.stdin).get('tool_name', '')
    except Exception:
        return
    if tool in PAUSE_TOOLS or not os.path.isdir('/mnt/c'):
        return
    try:
        if time.time() - os.stat(CACHE).st_mtime > 600:
            return
        fh = json.load(open(CACHE))['usage']['five_hour']
        used = float(fh['utilization'])
        reset = datetime.fromisoformat(fh['resets_at']).timestamp()
    except Exception:
        return
    now = time.time()
    if used < LINE or now >= reset:
        return
    at = time.localtime(reset + 60)
    msg = ('5h pause: Claude 5-hour usage %.0f%% >= %.0f%%; resets %s (in %dh%02dm). '
           'Pause now: 1) start no new work and dispatch nothing; 2) write resume notes '
           '(what is done, what is next, exact commands) to the task ledger or a notes '
           'file; 3) unless one is already scheduled (CronList), CronCreate ONE one-shot '
           '(recurring false) for %02d:%02d local (cron "%d %d %d %d *") whose prompt '
           'says to resume from those notes; 4) tell the user in one line and end the '
           'turn. Allowed now: %s.'
           % (used, LINE, time.strftime('%H:%M', time.localtime(reset)),
              (reset - now) // 3600, (reset - now) % 3600 // 60,
              at.tm_hour, at.tm_min, at.tm_min, at.tm_hour, at.tm_mday, at.tm_mon,
              ', '.join(sorted(PAUSE_TOOLS))))
    print(json.dumps({'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',
        'permissionDecision': 'deny',
        'permissionDecisionReason': msg}}))


if __name__ == '__main__':
    main()
