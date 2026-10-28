#!/bin/bash
# PostToolUse guard (Bash|Edit|Write): in a repo with web/*.js (exec-fn, spire, ...), lint every web/*.js file changed since HEAD
# for code swallowed by a mid-line // comment (exec-fn scripts/lint-swallowed.py) and syntax-check it (node --check).
# On a hit: exit 2, the report on stderr goes back to Claude at once - not at commit (Wai, 2026-10-26: "can you add something that
# stops you from button // comments midline? seems like it's happening a lot").
cat >/dev/null # (the hook's JSON on stdin: not needed)
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
lint=/home/wai/src/exec-fn/scripts/lint-swallowed.py
[ -f "$lint" ] || exit 0
cd "$root" || exit 0
mapfile -t files < <(git diff --name-only HEAD -- 'web/*.js' 2>/dev/null)
[ ${#files[@]} -eq 0 ] && exit 0
live=(); for f in "${files[@]}"; do [ -f "$f" ] && live+=("$f"); done
[ ${#live[@]} -eq 0 ] && exit 0
out=$(python3 "$lint" "${live[@]}" 2>&1); rc=$?
syn=""
for f in "${live[@]}"; do e=$(node --check "$f" 2>&1) || syn+=$'\n'"$f: $(printf '%s' "$e" | head -4)"; done
if [ $rc -ne 0 ] || [ -n "$syn" ]; then
  { echo "JS GUARD: fix before anything else (a mid-line // swallowed code, or a syntax error):"; [ $rc -ne 0 ] && echo "$out"; [ -n "$syn" ] && echo "$syn"; } >&2
  exit 2
fi
exit 0
