#!/bin/bash
# Stop hook: maintain a per-session rolling recap title that the statusline
# reads from ~/.claude/cache/recap_<sid>.txt. An LLM (haiku) writes the title,
# but only on the first turn and then every N turns — in between, the cached
# title persists. Runs the LLM in the BACKGROUND so the prompt never stalls;
# the statusline only ever reads the file (display-only, no race).

# Recursion guard: the background `claude -p` below would itself fire this Stop
# hook. Bail immediately when invoked inside our own summarizer.
[ -n "$CLAUDE_RECAP_GUARD" ] && exit 0

input=$(cat)
HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE="$HOME/.claude/cache"
N=5
MODEL="claude-haiku-4-5"

read -r sid tpath < <(printf '%s' "$input" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('session_id', ''), d.get('transcript_path', ''))
" 2>/dev/null)

[ -z "$sid" ] && exit 0
mkdir -p "$CACHE"

cnt_f="$CACHE/recap_count_$sid"
recap_f="$CACHE/recap_$sid.txt"

cnt=$(cat "$cnt_f" 2>/dev/null || echo 0)
cnt=$((cnt + 1))
printf '%s' "$cnt" > "$cnt_f"

# Refresh on the first turn (no title yet) or every Nth turn.
if [ -s "$recap_f" ] && [ $((cnt % N)) -ne 0 ]; then
    exit 0
fi
[ -z "$tpath" ] && exit 0

# Background summarizer — detached so Stop returns instantly.
(
    convo=$(python3 "$HOOKS_DIR/recap-extract.py" "$tpath" 2>/dev/null)
    [ -z "$convo" ] && exit 0
    prompt="You name coding sessions. Read the transcript and name the CURRENT task/topic as a 3-6 word noun phrase, like a git branch description. Abstract the topic — do NOT copy, quote, or echo any sentence from the transcript. No questions, no first person, no commentary.

Examples of good titles:
  Fix auth token expiry check
  Add statusline recap sanitizer
  Debug nightly ingest EACCES
Examples of BAD output (never do this):
  \"Approve delete? Files gone after.\"   (echoed a transcript line)
  Here is the title: ...                  (preamble)
  **Fix the bug**                          (markdown)

Output ONLY the title on a single line: plain words, no markdown, no numbering, no quotes, no punctuation, no preamble.

Transcript:
$convo"
    title=$(CLAUDE_RECAP_GUARD=1 claude -p --model "$MODEL" "$prompt" 2>/dev/null \
        | python3 "$HOOKS_DIR/recap-clean.py")
    [ -n "$title" ] && printf '%s' "$title" > "$recap_f"
) >/dev/null 2>&1 &

exit 0
