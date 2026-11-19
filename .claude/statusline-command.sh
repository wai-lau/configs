#!/bin/bash
input=$(cat)

# Usage credits: stdin carries no balance, so poll the OAuth usage endpoint.
# Cache 60s; refresh detached so render never blocks on the network.
uf=~/.claude/cache/statusline_usage.json
if [ ! -f "$uf" ] || [ $(( $(date +%s) - $(stat -c %Y "$uf") )) -gt 60 ]; then
  touch "$uf"
  (
    tok=$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.claude/.credentials.json')))['claudeAiOauth']['accessToken'])" 2>/dev/null) || exit
    org=$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.claude.json')))['oauthAccount']['organizationUuid'])" 2>/dev/null) || exit
    get() { curl -sf -m 10 "https://api.anthropic.com/api/oauth/$1" \
      -H "Authorization: Bearer $tok" -H 'anthropic-beta: oauth-2025-04-20'; }
    # Prepaid balance lives apart from /usage (which has spend, no balance).
    u=$(get usage) && p=$(get "organizations/$org/prepaid/credits") &&
      printf '{"usage":%s,"prepaid":%s}' "$u" "$p" > "$uf.tmp" && mv "$uf.tmp" "$uf"
  ) >/dev/null 2>&1 </dev/null &
  disown
fi

read -r cwd remaining five_hour seven_day seven_cap reset_in base_pct effort_lvl credits < <(echo "$input" | python3 -c "
import sys,json,time,os,math
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
effort_lvl=((d.get('effort') or {}).get('level')) or '-'
_m=d.get('model') or {}
_mstr=((_m.get('id') or '')+' '+(_m.get('display_name') or '')).lower()
_short=next((f for f in ('opus','sonnet','haiku','fable') if f in _mstr),'')
if _short:
    effort_lvl=(effort_lvl+'-'+_short) if effort_lvl!='-' else _short
remaining=ctx.get('used_percentage')
resets=fh.get('resets_at')
if resets:
    s=max(0,int(resets-time.time()))
    countdown='%dh%02dm' % (s//3600,(s%3600)//60)
else:
    countdown='-'

# 7d pace cap, same formula as hooks/pace-cap.py: ceil(days into the 7d
# window) * 95/7 (the last 5% is a snooze-only reserve). Window start =
# resets_at - 7d (stdin epoch, else the usage cache's ISO string).
cap='-'
try:
    sr=sd.get('resets_at')
    if sr is None:
        from datetime import datetime
        uj=json.load(open(os.path.expanduser('~/.claude/cache/statusline_usage.json')))
        sr=datetime.fromisoformat(uj['usage']['seven_day']['resets_at']).timestamp()
    day=max(1,math.ceil(max(0.0,time.time()-(sr-7*86400))/86400))
    capf=day*95.0/7
    cap='%.0f' % capf
except: pass

# Base = context taken before the conversation: system prompt, tools, CLAUDE.md
# files, memory, hook context. Read off the session's first API call (its
# input, less the first prompt at ~4 chars/token), cached per session. A
# resumed session keeps the base it started with.
base='-'
tp=d.get('transcript_path') or ''
if tp and sid!='unknown':
    bf=os.path.expanduser('~/.claude/cache/base_%s'%sid)
    bt=None
    try: bt=int(open(bf).read())
    except: pass
    if bt is None:
        try:
            fu=None
            for line in open(tp,encoding='utf-8'):
                try: m=json.loads(line)
                except: continue
                if m.get('isSidechain'): continue
                msg=m.get('message') or {}
                if m.get('type')=='user' and fu is None:
                    c=msg.get('content')
                    fu=len(c) if isinstance(c,str) else sum(len(b.get('text') or '') for b in c if isinstance(b,dict)) if isinstance(c,list) else 0
                u=msg.get('usage') if m.get('type')=='assistant' else None
                if u:
                    t=(u.get('input_tokens') or 0)+(u.get('cache_read_input_tokens') or 0)+(u.get('cache_creation_input_tokens') or 0)
                    bt=max(0,t-(fu or 0)//4)
                    break
        except: pass
        if bt is not None:
            try: open(bf,'w').write(str(bt))
            except: pass
    if bt is not None: base='%.0f' % (bt*100.0/size)

# Credits left = prepaid balance, else monthly limit - used, else month used.
# "!" prefix = a window is at 100%, so credits are being spent now.
credits='-'
try:
    uj=json.load(open(os.path.expanduser('~/.claude/cache/statusline_usage.json')))
    sp=uj['usage'].get('spend') or {}
    bal=(uj['prepaid'].get('balance') or {}).get('money')
    def amt(m): return m['amount_minor']/10.0**m.get('exponent',2)
    if sp.get('enabled'):
        used=amt(sp['used']) if sp.get('used') else 0
        if bal: credits='%.2f' % amt(bal)
        elif sp.get('limit'): credits='%.2f' % max(0,amt(sp['limit'])-used)
        else: credits='%.2fused' % used
except: pass
if credits!='-' and any((w.get('used_percentage') or 0)>=100 for w in (fh,sd)):
    credits='!'+credits

print(cwd, pct(remaining), pct(fh.get('used_percentage')), pct(sd.get('used_percentage')), cap, countdown, base, effort_lvl, credits)
" 2>/dev/null)

short_cwd="${cwd/#$HOME/~}"
two_parts=$(echo "$short_cwd" | awk -F/ '{if(NF<=2) print $0; else print $(NF-1)"/"$NF}')

# Session title (display-only → no keystroke race). Prefer the session name Claude
# tracks (/rename or auto-name), title-cased; else our per-session rolling recap
# (cache/recap_<sid>.txt, regenerated by the session-recap hook, keyed by
# session_id so every pane is independent).
# Bg hue: random for the first live session, then steps of 36 deg one way
# from it; text is black for contrast.
recap=$(echo "$input" | python3 -c "
import sys,json,os,hashlib,colorsys,random
d=json.load(sys.stdin)
sid=d.get('session_id') or ''
def titlecase(t):
    # slug (no spaces) → words; small words lower unless first/last; keep caps (acronyms).
    if not any(c.isspace() for c in t): t=t.replace('-',' ').replace('_',' ')
    w=t.split(); small={'a','an','and','as','at','but','by','for','in','nor','of','on','or','per','the','to','vs','via','with'}
    out=[]
    for i,x in enumerate(w):
        if any(c.isupper() for c in x): out.append(x)
        elif 0<i<len(w)-1 and x in small: out.append(x)
        else: out.append(x[:1].upper()+x[1:])
    return ' '.join(out)
title=(d.get('session_name') or '').strip()
if title: title=titlecase(title)
else:
    cf=os.path.expanduser('~/.claude/cache/recap_%s.txt'%sid) if sid else ''
    if cf and os.path.exists(cf):
        try: title=open(cf,encoding='utf-8').read().strip()
        except: pass
title=' '.join(title.split())
if len(title)>50: title=title[:49]+'…'
bg='';shim=''
if title:
    hue=int(hashlib.md5(title.encode('utf-8')).hexdigest(),16)%360
    # Hue steps (Wai, 2026-11-19: 'after the first one, instead of going 90deg
    # either way, just divide the 180deg one way into 5, each subsequent title gets
    # the next color (24 deg away)', then '36'). cache/hues/<claude pid> holds 'hue<TAB>title';
    # cache/hues/anchor holds the first title's hue. A session keeps its stored hue
    # while its title holds. A new title on a lone session gets a random hue and
    # becomes the anchor; with other live sessions it takes anchor+36k for the
    # first k in 5,2,4,1,3 no live session holds: the complement first, then the
    # slots between, so a few sessions already span the 180 deg (Wai: 'the colors
    # look too similar / shouldn't 180deg span two complimentary colors').
    try:
        hd=os.path.expanduser('~/.claude/cache/hues'); os.makedirs(hd,exist_ok=True)
        af=os.path.join(hd,'anchor')
        def comm(p):
            try: return open('/proc/%d/comm'%p).read().strip()
            except Exception: return ''
        me=os.getppid()
        while me>1 and comm(me)!='claude':
            me=int(open('/proc/%d/stat'%me).read().rsplit(')',1)[1].split()[1])
        if me>1:
            others=[]; mine=None
            for f in os.listdir(hd):
                if not f.isdigit(): continue
                try: h,t=open(os.path.join(hd,f),encoding='utf-8').read().split('\t',1)
                except Exception: continue
                if int(f)==me: mine=(int(h),t)
                elif comm(int(f))=='claude': others.append(int(h))
                else:
                    try: os.remove(os.path.join(hd,f))
                    except Exception: pass
            if mine and mine[1]==title: hue=mine[0]
            elif not others: hue=random.randrange(360)
            else:
                try: anchor=int(open(af).read().strip())%360
                except Exception:
                    anchor=others[0]; open(af,'w').write('%d'%anchor)
                slots=[(anchor+36*k)%360 for k in (5,2,4,1,3)]  # farthest first: the complement, then between
                held=set(others)
                hue=next((h for h in slots if h not in held), slots[len(others)%len(slots)])
            if not (mine and mine[1]==title):
                open(os.path.join(hd,str(me)),'w',encoding='utf-8').write('%d\t%s'%(hue,title))
            if not others: open(af,'w').write('%d'%hue)   # alone = first: anchor follows
    except Exception: pass
    c=colorsys.hls_to_rgb(hue/360.0,0.60,0.95)   # bright + high saturation
    # Blues and violets come out dark at the same HLS lightness: mix in white
    # until relative luminance reaches 0.40 (Spire's orange, 0.415, reads fine;
    # Human Music's violet, 0.13, did not). Brighter hues stay as they are.
    def lin(v): return v/12.92 if v<=0.04045 else ((v+0.055)/1.055)**2.4
    def lum(c): return 0.2126*lin(c[0])+0.7152*lin(c[1])+0.0722*lin(c[2])
    def whiten(c,t): return tuple(v+(1-v)*t for v in c)
    lo,hi=0.0,1.0
    if lum(c)<0.40:
        for _ in range(20):
            mid=(lo+hi)/2
            if lum(whiten(c,mid))<0.40: lo=mid
            else: hi=mid
        c=whiten(c,hi)
    bg='%d;%d;%d'%tuple(round(v*255) for v in c)
    shim='%d,%d,%d'%tuple(round(v*255) for v in whiten(c,0.45))   # lighter: prompt bar shimmer
sys.stdout.write('%s\x1f%s\x1f%s'%(title,bg,shim))
" 2>/dev/null)
IFS=$'\x1f' read -r title bgc shim <<<"$recap"

# tmux tab = this title, in this color: pane options @cc_title / @cc_color
# (#rrggbb) for the window-status formats in ~/.tmux.conf. No title = unset,
# and the tab falls back to the window name.
if [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
  if [ -n "$title" ] && [ -n "$bgc" ]; then
    IFS=';' read -r cr cg cb <<<"$bgc"
    tmux set -p -t "$TMUX_PANE" @cc_title "$title" \; \
      set -p -t "$TMUX_PANE" @cc_color "$(printf '#%02x%02x%02x' "$cr" "$cg" "$cb")" >/dev/null 2>&1
  else
    tmux set -pu -t "$TMUX_PANE" @cc_title \; set -pu -t "$TMUX_PANE" @cc_color >/dev/null 2>&1
  fi
fi

# No 16-color palette anywhere (SGR 30-37/90-97/40-47/100-107, 256 indices
# 0-15): Windows Terminal draws bold on them as bright, and schemes remap them.
# Inverted items are pills: text (black, or SGR $3) on color $1, an SGR color
# tail ("5;117" for 256 colors, "2;r;g;b" for truecolor), with half-block caps
# drawn in that color on the plain background: U+2590 / U+258C, half a cell
# each, so a pill sits flush against its neighbours. (Nerd Font round caps:
# U+E0B6 / U+E0B4; arrows: U+E0B2 / U+E0B0.) Sets REPLY; the escapes stay
# literal for the final printf, so a % in $2 must come as %%.
CAP_L=$'\xe2\x96\x90' CAP_R=$'\xe2\x96\x8c'
pill() { REPLY="\033[38;${1}m${CAP_L}\033[${3:-38;2;0;0;0};48;${1}m${2}\033[0m\033[38;${1}m${CAP_R}\033[0m"; }

# Order: 7d+snooze, 5h+reset, (credits), ctx+base, alts. Each timer (and base)
# is a pill glued to its field.
suffix=""
# 7d: used/allowed (allowed = pace cap for today, see hooks/pace-cap.py).
sd_seg=""
if [ -n "$seven_day" ] && [ "$seven_day" != "-" ]; then
  sd_seg="7d:\033[1m${seven_day}\033[22m"   # used part bold
  [ -n "$seven_cap" ] && [ "$seven_cap" != "-" ] && sd_seg="${sd_seg}/${seven_cap}"
  sd_seg="\033[38;2;86;182;194m${sd_seg}%%\033[0m"   # truecolor cyan: WT draws bold on ANSI colors as bright, not bold
fi

# Pace-cap snooze left (~/bin/pace-snooze writes the expiry epoch): black on
# light blue, while the snooze runs.
snz_seg=""
snz_until=$(cat ~/.claude/cache/pace-snooze 2>/dev/null)
snz_until=${snz_until%%.*}
if [[ "$snz_until" =~ ^[0-9]+$ ]]; then
  snz_left=$(( (snz_until - $(date +%s) + 59) / 60 ))   # minutes, rounded up
  if [ "$snz_left" -gt 0 ]; then
    if [ "$snz_left" -ge 60 ]; then snz_left=$(printf '%dh%02dm' $((snz_left / 60)) $((snz_left % 60)))
    else snz_left="${snz_left}m"; fi
    pill "5;117" "$snz_left"; snz_seg=$REPLY
  fi
fi
# No snooze: a plain space (terminal background) keeps 7d apart from 5h (Wai, 2026-11-18:
# "when pace snooze is off, put a plain bg colored space").
[ -z "$snz_seg" ] && [ -n "$sd_seg" ] && snz_seg=" "
[ -n "${sd_seg}${snz_seg}" ] && suffix="${suffix}${sd_seg}${snz_seg}"

# 5h used, then time to its reset: black on light green.
fh_seg="" rst_seg=""
[ -n "$five_hour" ] && [ "$five_hour" != "-" ] && fh_seg="\033[38;5;217m5h:${five_hour}%%\033[0m"
[ -n "$reset_in" ] && [ "$reset_in" != "-" ] && { pill "5;157" "$reset_in"; rst_seg=$REPLY; }
[ -n "${fh_seg}${rst_seg}" ] && suffix="${suffix}${fh_seg}${rst_seg}"

# Credits only while spending them ("!" = a window at 100%): white on red.
[ "${credits#!}" != "$credits" ] && { pill "2;224;108;117" "c:\$${credits#!}" "1;38;2;220;223;228"; suffix="${suffix}${REPLY}"; }

ctx_seg="" base_seg=""
[ -n "$remaining" ] && [ "$remaining" != "-" ] && ctx_seg="\033[38;2;220;223;228mctx:${remaining}%%\033[0m"
[ -n "$base_pct" ] && [ "$base_pct" != "-" ] && { pill "5;245" "${base_pct}%%"; base_seg=$REPLY; }
[ -n "${ctx_seg}${base_seg}" ] && suffix="${suffix}${ctx_seg}${base_seg}"

claude_total=$(pgrep -xc claude 2>/dev/null || echo 0)
others=$((claude_total - 1))
[ "$others" -gt 0 ] && suffix="${suffix}\033[38;5;208malts:\033[1m${others}\033[0m"

# Current user, right after the cwd. wai/wai-root/root = privileged owner →
# black-on-white warning pill. walled claude (or any other) = orange text.
me=$(whoami)
if [ "$me" = wai ] || [ "$me" = wai-root ] || [ "$me" = root ]; then
  pill "5;255" "$me"; user_seg=$REPLY
else
  user_seg="\033[38;5;208m${me}\033[0m"
fi

# Line 1: pid + the recap as a hash-colored pill + effort. Line 2: cwd + user
# + metrics. No spaces between items: colors and pills separate them.
title_line=""
# Effort level to the right of the title bar, fg = the title bar's
# hash-derived bg color.
effort_seg=""
# The model name (the part after the last "-", when it is one) is bold.
if [ -n "$effort_lvl" ] && [ "$effort_lvl" != "-" ] && [ -n "$bgc" ]; then
  case "${effort_lvl##*-}" in
    opus|sonnet|haiku|fable) eff_txt="${effort_lvl%${effort_lvl##*-}}\033[1m${effort_lvl##*-}" ;;
    *) eff_txt="$effort_lvl" ;;
  esac
  effort_seg="\033[38;2;${bgc}m${eff_txt}\033[0m"
fi
# Claude PID (= cc-socks/<pid>.sock) left of the title, same fg as effort.
# Walk ancestors to the claude process (statusline may run under sh -c).
pid_seg=""
p=$PPID
while [ -n "$p" ] && [ "$p" -gt 1 ] && [ "$(cat /proc/$p/comm 2>/dev/null)" != claude ]; do
  p=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)
done
[ -n "$p" ] && [ "$p" -gt 1 ] && [ -n "$bgc" ] && pid_seg="\033[1;38;2;${bgc}m${p}\033[0m"

# Prompt bar = title color. The claude() wrapper in ~/.zshrc runs each pane on
# its own theme, ~/.claude/themes/pane-<shell pid>.json, which claude reloads
# on change; rewrite it whenever the title color moves. No file = a claude
# not started by that wrapper: leave it be.
if [ -n "$p" ] && [ "$p" -gt 1 ] && [ -n "$bgc" ] && [ -n "$shim" ]; then
  sh_pid=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)
  tf=~/.claude/themes/pane-$sh_pid.json
  if [ -f "$tf" ]; then
    want="{\"name\":\"pane-$sh_pid\",\"base\":\"dark\",\"overrides\":{\"promptBorder\":\"rgb(${bgc//;/,})\",\"promptBorderShimmer\":\"rgb($shim)\"}}"
    [ "$(cat "$tf" 2>/dev/null)" = "$want" ] || { printf '%s\n' "$want" > "$tf.tmp" && mv "$tf.tmp" "$tf"; }
  fi
fi
[ -n "$title" ] && { pill "2;${bgc}" "${title//%/%%}"; title_line="${pid_seg}${REPLY}${effort_seg}\n"; }

printf "${title_line}\033[38;2;245;237;216m%s\033[0m${user_seg}${suffix}" "$two_parts"
