#!/usr/bin/env bash
# /restart (~/.claude/commands/restart.md): relaunch this claude on the same
# conversation, on the latest build, keeping its background Bash tasks running.
#
# Why SIGKILL: on SIGTERM claude kills its background task shells; on SIGKILL
# they are orphaned and live on, still writing their output files. The
# transcript is written as it goes, so `claude --resume <id>` picks up intact
# (both tested 2026-11-18 on claude 2.1.327). Subagents and workflow runs do
# die, but the resumed session continues them from their saved transcripts.
#
# A mates lead (claude's parent is ~/bin/mates) is relaunched by bin/mates itself from the
# same restart file, with that lead's prompt rebuilt (today's lead.md and lessons).
# Relaunch: the claude() wrapper in ~/.zshrc exports CLAUDE_WRAPPER_PID and,
# once claude is gone, relaunches `claude --resume <id> -- <note>` from
# ~/.claude/.restart.<wrapper pid> (line 1: session id; the rest: the first
# prompt, telling the resumed session which tasks are still running).
# A shell still running an older wrapper (no CLAUDE_WRAPPER_PID) gets the same
# result inside tmux: a detached helper types `source ~/.zshrc && claude` into
# the pane once claude is gone, and the new wrapper finds the restart file.
set -u

die() { echo "restart: $*; nothing done" >&2; exit 1; }
comm() { ps -o comm= -p "$1" 2>/dev/null | tr -d ' '; }

pid=${CLAUDE_PID:-}
if [ -z "$pid" ]; then  # older claude: nearest ancestor named claude
  p=$PPID
  while [ -n "$p" ] && [ "$p" -gt 1 ]; do
    [ "$(comm "$p")" = claude ] && { pid=$p; break; }
    p=$(ps -o ppid= -p "$p" | tr -d ' ')
  done
fi
[ -n "$pid" ] && [ "$(comm "$pid")" = claude ] || die "no claude process above this shell"
sid=${CLAUDE_CODE_SESSION_ID:-}
[ -n "$sid" ] || die "CLAUDE_CODE_SESSION_ID is not set"

shell=$(ps -o ppid= -p "$pid" | tr -d ' ')
if tr '\0' '\n' < "/proc/$shell/cmdline" 2>/dev/null | grep -qE '(^|/)bin/mates$'; then
  # A mates lead: ~/bin/mates runs claude as its child and, once claude is gone, relaunches it
  # from ~/.claude/.restart.<its pid> on the same conversation with a freshly built lead prompt
  # (its run_lead loop), so nothing needs typing into the pane.
  mode=mates
elif [ "$(comm "$shell")" != zsh ]; then
  die "claude was not started from a zsh or by ~/bin/mates, so nothing can relaunch it"
elif [ "${CLAUDE_WRAPPER_PID:-}" = "$shell" ]; then
  mode=wrapper
elif [ -n "${TMUX_PANE:-}" ] && command -v tmux >/dev/null; then
  mode=tmux
else
  die "this shell runs an older claude() wrapper and is not in tmux. Exit, run 'source ~/.zshrc', then 'claude --resume $sid'"
fi

# Background tasks: claude's children whose stdout is a tasks/<id>.output file.
# Foreground commands write one too, so skip the shell running this script.
self=" $$ "; p=$$
while [ "$p" -gt 1 ] && [ "$p" != "$pid" ]; do p=$(ps -o ppid= -p "$p" | tr -d ' '); self+="$p "; done
tasks=""
for c in $(ps -o pid= --ppid "$pid"); do
  case "$self" in *" $c "*) continue ;; esac
  out=$(readlink "/proc/$c/fd/1" 2>/dev/null) || continue
  case "$out" in */tasks/*.output) ;; *) continue ;; esac
  tasks+="- task $(basename "$out" .output): pid $c, output $out"$'\n'
done

# Subagents and workflow runs in flight. They run inside claude and die with
# it, but their transcripts are on disk, so the resumed session continues them:
# SendMessage to an agent id, Workflow resumeFromRunId (tested 2026-11-18).
# In flight = agent meta without "finished":true; a run dir with no
# workflows/<run>.json (written when the run ends). Only ones touched since
# this claude started: older leftovers belong to some earlier process.
agents="" runs=""
sdir=$(ls -d "$HOME"/.claude/projects/*/"$sid" 2>/dev/null | head -1)
if [ -n "$sdir" ]; then
  since=$(( $(date +%s) - $(ps -o etimes= -p "$pid" | tr -d ' ') ))
  for m in "$sdir"/subagents/agent-*.meta.json; do
    [ -f "$m" ] || continue
    grep -q '"finished":true' "$m" && continue
    grep -q '"spawnDepth":[2-9]' "$m" && continue  # its parent agent handles it
    [ "$(stat -c %Y "${m%.meta.json}.jsonl" 2>/dev/null || echo 0)" -ge "$since" ] || continue
    id=$(basename "$m" .meta.json)
    desc=$(sed -n 's/.*"description":"\([^"]*\)".*/\1/p' "$m")
    agents+="- agent ${id#agent-}${desc:+ ($desc)}"$'\n'
  done
  for w in "$sdir"/subagents/workflows/wf_*/; do
    [ -d "$w" ] || continue
    run=$(basename "$w")
    [ -f "$sdir/workflows/$run.json" ] && continue
    [ "$(stat -c %Y "$w/journal.jsonl" 2>/dev/null || echo 0)" -ge "$since" ] || continue
    script=$(ls "$sdir"/workflows/scripts/*-"$run".js 2>/dev/null | head -1)
    runs+="- workflow run $run${script:+, scriptPath $script}"$'\n'
  done
fi

note="[/restart] Claude Code restarted: new process, same conversation, settings and CLAUDE.md re-read."
if [ -n "$tasks" ]; then
  note+="
These background Bash tasks were running and survived, but this process does not track them, so no completion notice will come:
${tasks}Do this first, for every task above, even if nothing else was in progress: if \`ps -p <pid>\` finds nothing, the task has ended, so read its output file. Otherwise re-attach: run \`while ps -p <pid> >/dev/null; do sleep 5; done\` with run_in_background, and read the output file when that finishes. The exit code is lost; judge by the output."
fi
if [ -n "$agents" ]; then
  note+="
These subagents were mid-task. Their process died, but their transcripts are saved, so continue each one now (skip any that was stopped on purpose): SendMessage to its agent id, saying: 'A restart interrupted you. Your last tool call may or may not have taken effect: check before redoing it, then continue your task.'
${agents}"
fi
if [ -n "$runs" ]; then
  note+="
These workflow runs were mid-run. Resume each now (skip any that was stopped on purpose): Workflow tool with resumeFromRunId set to the run id and the same script, scriptPath as given or the one its Workflow call used. Finished agent steps replay from cache; the step that was running starts over, so one of its actions may happen twice.
${runs}"
fi
note+="
If any other subagent or workflow from before /restart never reported back, continue it the same way.
Then carry on with whatever was in progress before /restart. If nothing was and nothing is listed above, reply with one line: Restarted."

restart_file="$HOME/.claude/.restart.$shell"
printf '%s\n%s\n' "$sid" "$note" > "$restart_file" || die "cannot write $restart_file"

if [ "$mode" = tmux ]; then
  tty=/dev/$(ps -o tty= -p "$pid" | tr -d ' ')
  # Detached: outlives claude. Waits for it to go, undoes the terminal modes the
  # killed TUI left on (alt screen, hidden cursor, paste/focus/mouse, kitty and
  # modifyOtherKeys keys), then types the relaunch into the pane's shell.
  setsid bash -c '
    while ps -p "$1" >/dev/null 2>&1; do sleep 0.1; done
    sleep 0.3
    printf "\033[?1049l\033[?25h\033[0m\033[?2004l\033[?1004l\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[<u\033[>4m" > "$2" 2>/dev/null
    tmux send-keys -t "$3" -l " source ~/.zshrc && claude" && tmux send-keys -t "$3" Enter
  ' _ "$pid" "$tty" "$TMUX_PANE" </dev/null >/dev/null 2>&1 &
fi

# Nothing may print after this: stdout is a pipe into the claude being killed.
kill -KILL "$pid" || { rm -f "$restart_file"; die "cannot kill claude $pid"; }
