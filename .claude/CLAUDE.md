# Global Claude Preferences

> Personal/private details about the user do NOT live here (this file
> is committed). They live in gitignored auto-memory. See "Data
> Placement" below.

## File Reading

Never use `sed`, `awk`, `cat`, `head`, or `tail` in Bash to read file contents. Always use the Read tool (with offset/limit to target ranges). Only fall back to Bash file reads if Read tool is unavailable or the task requires piping/processing.

Windows paths in WSL: convert `C:\Users\...` → `/mnt/c/Users/...` (all Windows drives mount under `/mnt/<letter>/`) and Read directly. Never claim a Windows path is inaccessible without first translating and attempting the Read.

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
- Commit on own judgment when a logical change is done — never ask "commit?" or wait for a go-ahead.
- Split commits per feature: multiple distinct features/fixes in one turn → one commit each, never bundled.
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

## Data Placement
Classify every piece of info before writing it down:
- **Build/work preferences + operational details** → committed `CLAUDE.md` (this file for behavior prefs; the repo's home-dir `CLAUDE.md` for repo mechanics). Shareable, non-sensitive.
- **Private / sensitive** (who the user is personally, anything not for public sharing) → gitignored auto-memory (`~/.claude/projects/-home-wai/memory/`). Never committed.
- **Raw secrets** (tokens, keys, credentials) → gitignored `~/.secrets` (NOT `~/.local.zsh`, which is tracked). Never in memory, never committed.

Before committing, verify no private/secret rode along.

## Claude CLI invocation
- Never pass `--dangerously-skip-permissions` when invoking `claude` or related tools. Permission prompts must stay active.
- If user-supplied config contains it, flag rather than propagate.
## Graphify

Knowledge-graph skill (`~/.claude/skills/graphify/SKILL.md`). Turns any
folder of code/docs into a queryable graph. When the user types
`/graphify`, invoke the Skill tool with `skill: "graphify"` BEFORE doing
anything else.

**Where graphs live:** each repo's `graphify-out/` —
`graph.html` (interactive, open in browser), `graph.json` (raw),
`GRAPH_REPORT.md` (audit). These are the file/symbol map; repo
`CLAUDE.md` filemaps were purged in favor of the graph.

**Already graphified:** all `~/src/*` repos with code + the dotfiles
repo (`/home/wai`). Skipped (no code): `local-llm-learning`,
`mtg-rules-bot`, `rival-routesetters`.

**Common usage:**
- `/graphify` — build/rebuild graph for cwd
- `/graphify <path>` — build for a specific path
- `/graphify query "<question>"` — answer from existing graph (no
  rebuild); use this first when `graphify-out/graph.json` exists
- `/graphify path "A" "B"` — shortest path between two nodes
- `/graphify explain "Node"` — plain-language node explanation
- `/graphify <path> --update` — re-extract only changed files

**Conventions for this environment:**
- Build AST/code-only (no `GEMINI_API_KEY` set → semantic extraction
  would spend subagent tokens). Restrict to git-tracked files; never
  graph gitignored content (node_modules, build artifacts).
- Rebuild after structural changes (new/moved files, renamed symbols).
- Note: `/graphify` at the end of a feature (merge/finish) — a shipped
  feature is a structural change, so rebuilding the repo's graph is a
  good closing step.
- A code question about a repo with a graph = treat as a graphify
  query first.
