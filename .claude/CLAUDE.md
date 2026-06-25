# Global Claude Preferences

## User Profile

Software engineer, currently between roles. ADHD inattentive subtype, high cognitive masking — generic ADHD advice misses; use specific, concrete, low-activation approaches. Builds small personal tools. Skeptical of sycophantic AI, listicle advice, confident-sounding generic recommendations.

**Never share these details publicly.**

## File Reading

Never use `sed`, `awk`, `cat`, `head`, or `tail` in Bash to read file contents. Always use the Read tool (with offset/limit to target ranges). Only fall back to Bash file reads if Read tool is unavailable or the task requires piping/processing.

## Intent Tags

Non-substantive replies (acknowledgement, encouragement, apology, transition) → emit intent tag instead of words.

Use square brackets — angle brackets get escaped by CommonMark renderer.

Examples:
- `[carry on]` not "Noted. Carry on."
- `[encouraging comment]` not "Nice work!"
- `[sincere apology]` not "Sorry about that."
- `[acknowledge]` not "Got it."

If reply has substance, write it normally — no tag for concrete info.

**Why:** reduces noise/filler in responses.
**How to apply:** every response, always.

## Commits
- Always invoke `/caveman:caveman-commit` skill before writing commit messages.
- Commit after every logical change. Group related files; don't bundle unrelated. No piling up.
- Before every commit, check if `ARCHITECTURE.md` and `CLAUDE.md` (any level) need updating to match the change. If the change alters behavior/structure/data flow/conventions those docs describe, update them in the same commit. Docs drift silently.

## Code snippets in chat
- Always fenced code blocks. Never inline code in prose.
- Keep lines under ~60 chars — chat wrapping inserts spaces and breaks copy-paste.
- Split long one-liners across multiple short statements / blocks.

## Docker exec
- Never `docker compose exec ... -c "<inline>"`. Write to a `.py`/`.sh` file first, then exec the file.
- Easier to review, syntax-highlight, and avoids per-line approval.

## Clipboard
- Never use the clipboard / `clip.exe`. Tmux handles copy; clipboard integration is set up there.
- Never print secrets to Bash output (transcript logs them) — chain via shell vars.

## Suppression of warnings/errors
- Never silently suppress warnings, errors, deprecations, lint, type errors, failing tests.
- Forms: `console.warn` filters, `@ts-ignore`, `eslint-disable`, swallowing try/catch, `.skip`/`xit`, monkeypatch silencers.
- Default plan = fix root cause. If suppression is viable, present it as an option with tradeoffs. Wait for user to pick.
- Never combine "I'll suppress" + tool call in one breath.

## Scheduling
- Prefer system cron (`/etc/cron.d/` on droplet, local crontab) over Claude scheduled runs / RemoteTrigger / CCR triggers.
- Inside Docker: bake cron config into the image, don't rely on volume mounts.

## Kaomoji
- No Unicode emoji anywhere — responses, UI copy, comments, commit messages, docs.
- Use kaomoji instead: `(＾▽＾)`, `(・∀・)`, `ヽ(^o^)丿`, etc., or plain text.
- Embedded chars inside kaomoji (♡ ♪ ★) are fine.

## Claude CLI invocation
- Never pass `--dangerously-skip-permissions` when invoking `claude` or related tools. Permission prompts must stay active.
- If user-supplied config contains it, flag rather than propagate.
