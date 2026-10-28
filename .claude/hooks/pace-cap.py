#!/usr/bin/env python3
"""UserPromptSubmit: cap weekly Max usage to 1/7 per day of the window.

Allowed 7d% = ceil(days elapsed in the current 7d window) * 100/7, so an
unused day's share carries forward. Over pace -> block the prompt.

Exempt: the wai-lau.net droplet (its UI runs interactive convos), detected
positively by its resolved IP being bound to a local interface. Anything
not provably the droplet is capped. Headless (`claude -p`) runs are
exempt too.

Data: ~/.claude/cache/statusline_usage.json, refreshed every 60s by the
statusline. Missing/stale (>10 min) data -> allow (never brick on outage).
"""
import json, math, os, socket, subprocess, sys, time
from datetime import datetime

CACHE = os.path.expanduser('~/.claude/cache/statusline_usage.json')
WEEK = 7 * 86400


def on_droplet():
    try:
        ip = socket.gethostbyname('wai-lau.net')
        addrs = subprocess.run(['hostname', '-I'], capture_output=True,
                               text=True, timeout=2).stdout.split()
        return ip in addrs
    except Exception:
        return False


def headless():
    # Walk ancestors to the claude process; -p/--print = headless run.
    pid = os.getppid()
    while pid > 1:
        try:
            comm = open('/proc/%d/comm' % pid).read().strip()
            if comm == 'claude':
                args = open('/proc/%d/cmdline' % pid).read().split('\0')
                return '-p' in args or '--print' in args
            pid = int(open('/proc/%d/stat' % pid).read().rsplit(')', 1)[1].split()[1])
        except Exception:
            return False
    return False


def main():
    json.load(sys.stdin)
    if on_droplet() or headless():
        return
    try:
        if time.time() - os.stat(CACHE).st_mtime > 600:
            return
        sd = json.load(open(CACHE))['usage']['seven_day']
        used = float(sd['utilization'])
        reset = datetime.fromisoformat(sd['resets_at']).timestamp()
    except Exception:
        return
    now = time.time()
    elapsed = max(0.0, now - (reset - WEEK))
    day = max(1, math.ceil(elapsed / 86400))
    allowed = min(100.0, day * 100.0 / 7)
    if used < allowed:
        return
    unlock = reset - WEEK + day * 86400 - now
    msg = ('Pace cap: 7d usage %.0f%% >= %.0f%% allowed (day %d/7). '
           'Next day unlocks in %dh%02dm.'
           % (used, allowed, day, unlock // 3600, unlock % 3600 // 60))
    print(json.dumps({'decision': 'block', 'reason': msg}))


if __name__ == '__main__':
    main()
