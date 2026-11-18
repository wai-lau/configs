#!/usr/bin/env python3
"""PreToolUse: pause work when the 5-hour Claude usage window hits its line.

The line climbs as the window's reset nears: 95% with more than 4 h left,
96% with <=4 h, 97% <=3 h, 98% <=2 h, 99% <=1 h (Wai, 2026-11-18: "95% if
<=5 hours left, 96%<=4, 97@<=3 98@<=2 99@<=1"). At or over the line every
tool call is denied except the ones a
session needs to pause cleanly: write resume notes (Read/Write/Edit), load
and schedule a one-shot resume (ToolSearch, CronCreate/List/Delete,
ScheduleWakeup), stop background work (TaskStop) and tell peers
(SendMessage). The deny reason tells the model what to do (Wai, 2026-11-10:
"do this globally when claude 5h usage is up to 95%").

Applies to everything on the WSL desktop, headless `claude -p` runs too,
and ignores `pace-snooze` (Wai, 2026-11-11: "Five hour pause should ignore
the pace snooze, it should always kick in for anything on the desktop at
95% of 5h"; still holds under the sliding line). Terminal chats on the droplet pause too; only its Exec web UI
(user `cc-agent`) is exempt (Wai, 2026-11-16: "pace hooks are only for chats
like this"). Allow (never brick): cache missing or
stale (>10 min); reset time already past. Data: ~/.claude/cache/statusline_usage.json (statusline, every 60s).
"""
import json, math, os, pwd, sys, time
from datetime import datetime

CACHE = os.path.expanduser('~/.claude/cache/statusline_usage.json')
PAUSE_TOOLS = {'Read', 'Write', 'Edit', 'ToolSearch', 'CronCreate', 'CronList',
               'CronDelete', 'ScheduleWakeup', 'TaskStop', 'SendMessage'}


def line(left):
    """Pause line in % with `left` seconds to the reset: 100 - whole hours left (rounded up), 95..99."""
    return float(min(99, max(95, 100 - math.ceil(left / 3600))))


def resume_at(reset):
    """When the resume one-shot should fire: 3 min after the reset, on a minute that is not :00 or
    :30. The scheduler runs a one-shot landing on :00/:30 up to 90 s early, and a job that fires
    before the reset hits the 5-hour limit and is used up with nothing re-arming it (Human Music,
    2026-11-18: scheduled for 14:30, fired 14:28, limit hit, never resumed)."""
    t = math.ceil((reset + 180) / 60) * 60
    while time.localtime(t).tm_min in (0, 30):
        t += 60
    return time.localtime(t)


def main():
    try:
        tool = json.load(sys.stdin).get('tool_name', '')
    except Exception:
        return
    if tool in PAUSE_TOOLS or pwd.getpwuid(os.getuid()).pw_name == 'cc-agent':
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
    if now >= reset:
        return
    limit = line(reset - now)
    if used < limit:
        return
    at = resume_at(reset)
    msg = ('5h pause: Claude 5-hour usage %.0f%% >= %.0f%%; resets %s (in %dh%02dm). '
           'Pause now: 1) start no new work and dispatch nothing; 2) write resume notes '
           '(what is done, what is next, exact commands) to the task ledger or a notes '
           'file; 3) unless one is already scheduled (CronList), CronCreate ONE one-shot '
           '(recurring false) for %02d:%02d local (cron "%d %d %d %d *"; keep that exact '
           'minute: it is after the reset and off :00/:30, which can fire early) whose '
           'prompt says to resume from those notes; 4) tell the user in one line and end the '
           'turn. Allowed now: %s.'
           % (used, limit, time.strftime('%H:%M', time.localtime(reset)),
              (reset - now) // 3600, (reset - now) % 3600 // 60,
              at.tm_hour, at.tm_min, at.tm_min, at.tm_hour, at.tm_mday, at.tm_mon,
              ', '.join(sorted(PAUSE_TOOLS))))
    print(json.dumps({'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',
        'permissionDecision': 'deny',
        'permissionDecisionReason': msg}}))


if __name__ == '__main__':
    main()
