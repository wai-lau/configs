#!/bin/bash
input=$(cat)

read cwd remaining five_hour seven_day reset_in overhead_pct session_pct < <(echo "$input" | python3 -c "
import sys,json,time,os
d=json.load(sys.stdin)
ctx=d.get('context_window') or {}
rl=d.get('rate_limits') or {}
fh=rl.get('five_hour') or {}
sd=rl.get('seven_day') or {}
cu=ctx.get('current_usage') or {}
size=ctx.get('context_window_size') or 200000
sid=d.get('session_id') or 'unknown'

def pct(v): return '-' if v is None else '%.0f' % v

cwd=d.get('cwd','') or '-'
remaining=ctx.get('used_percentage')
resets=fh.get('resets_at')
if resets:
    s=max(0,int(resets-time.time()))
    countdown='%dh%02dm' % (s//3600,(s%3600)//60)
else:
    countdown='-'

total=None
if cu:
    total=(cu.get('input_tokens') or 0)+(cu.get('cache_read_input_tokens') or 0)+(cu.get('cache_creation_input_tokens') or 0)

overhead='-'; sess='-'
if total is not None and total>0:
    bdir=os.path.expanduser('~/.claude/cache')
    os.makedirs(bdir,exist_ok=True)
    bf=os.path.join(bdir,'statusline_baseline_global')
    base=None
    try:
        base=int(open(bf).read().strip())
    except: pass
    if base is None or total<base:
        base=total
        try: open(bf,'w').write(str(base))
        except: pass
    overhead='%.0f' % (base*100.0/size)
    sess='%.0f' % (max(0,total-base)*100.0/size)

print(cwd, pct(remaining), pct(fh.get('used_percentage')), pct(sd.get('used_percentage')), countdown, overhead, sess)
" 2>/dev/null)

short_cwd="${cwd/#$HOME/~}"
two_parts=$(echo "$short_cwd" | awk -F/ '{if(NF<=2) print $0; else print $(NF-1)"/"$NF}')

suffix=""
[ -n "$remaining" ] && [ "$remaining" != "-" ] && suffix="${suffix} \033[97mctx:${remaining}%%\033[0m"
[ -n "$overhead_pct" ] && [ "$overhead_pct" != "-" ] && suffix="${suffix} \033[38;5;245m(base:${overhead_pct}%%)\033[0m"
[ -n "$five_hour" ] && [ "$five_hour" != "-" ] && suffix="${suffix} \033[38;5;217m5h:${five_hour}%%\033[0m"
[ -n "$reset_in" ] && [ "$reset_in" != "-" ] && suffix="${suffix} \033[38;5;157m(${reset_in})\033[0m"
[ -n "$seven_day" ] && [ "$seven_day" != "-" ] && suffix="${suffix} \033[36m7d:${seven_day}%%\033[0m"

claude_total=$(pgrep -xc claude 2>/dev/null || echo 0)
others=$((claude_total - 1))
[ "$others" -gt 0 ] && suffix="${suffix} \033[38;5;208malts:${others}\033[0m"

printf "\033[38;2;255;181;200m[$(date +%H:%M)]\033[0m \033[38;2;245;237;216m%s\033[0m${suffix}" "$two_parts"
