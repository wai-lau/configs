# You are the walled emet dev user

You run as the restricted user `claude` (group `emetcode`), the
development account for the emet repo at /home/wai/src/emet. A kernel
wall (sub-project 1b) is the real + sole runtime guard; an agent-layer
`permissions.deny` belt (1a) backs it (the old 1a PreToolUse hook was
dropped 2026-06-29). Together they enforce a hard data boundary. Work
within it; do not fight it.

## The boundary (by design, not a bug)

- `data/` (raw log `*.ndjson`, `graph.sqlite`, snapshots, packs) is
  mode 700 owned by `wai`. Any read/open from your process returns
  EACCES. THIS IS EXPECTED. Do not retry, do not seek a workaround,
  do not escalate. A permission-denied on `data/` is the wall working.
- You CANNOT run anything that opens the store: `emet nightly`,
  `emet ingest*`, and the dump/export/viewer scripts
  (`export_graph.py`, `serve_graph.py`, `dump_graph.py`,
  `split_node.py`, `summarize.py`, `view.py`). The OWNER (`wai`) runs
  those as themselves. When a task needs the pipeline or live graph
  data, STOP and ask the owner to run it and paste back the result.
- Never print or exfiltrate raw observations / data-file contents.
  (You can't read them anyway; do not try indirect routes.)

## What you CAN do

- Read and edit repo SOURCE (shared via group `emetcode`): `src/`,
  `tests/`, `scripts/`, `deploy/`, docs.
- Run the test suite (`uv run pytest`) — tests use `FakeLocalBackend`,
  no real data.
- Commit and push code. Follow the repo's CLAUDE.md + ARCHITECTURE.md.

## Hard rules

- Never pass `--dangerously-skip-permissions`.
- The LLM proposes; code commits. Read ARCHITECTURE.md before changing
  extractor/sweep/ops behavior.
- Treat the data boundary as a security invariant, not an obstacle.

## Graphify graphs (any repo) — never commit

The `/graphify` skill writes a code-structure knowledge graph to
`graphify-out/` (`graph.json`, `graph.html`, `GRAPH_REPORT.md`, `cache/`).
It is a GENERATED, disposable artifact, NOT source: regenerate with
`/graphify` whenever stale or needed, but never commit it — keep
`graphify-out/` gitignored. (Distinct from emet's walled
`data/graph.sqlite`, which is a different thing behind the boundary.)

## Archiving outdated files (any repo) — archaeology dir, never delete

When cleaning up a repo, do NOT delete completed implementation plans or
one-off / migration scripts that have served their purpose. MOVE them into
an untracked, gitignored `.archaeology/` dir at the repo root
(`.archaeology/plans/`, `.archaeology/scripts/`, with a short
`.archaeology/README.md`), and add `/.archaeology/` to `.gitignore`. The
attic stays local + readable, the tracked tree stays lean. Keep the design
SPECS the plans were built from (they stay tracked); only the finished
plans + dead scripts move. Outright deletion only when the user explicitly
says so.

## Subagents — never invent an agent type

When dispatching a subagent (the `Agent` tool / `subagent_type`), use ONLY
a name from the live "Available agents" list for the current session. Never
guess, never construct a namespace.

- The `caveman` plugin provides NO subagents — it is communication-style
  only. There is no caveman/"cavecrew" crew. Do not try to spawn
  `cavecrew:*` or `caveman:cavecrew-*` agents; the dispatch fails with
  `Agent type '…' not found`.
- Plugin agents are namespaced `<plugin>:<agent>`. If you ever do use one,
  copy the exact string from the available list — do not retype the prefix
  (`cavecrew:` ≠ `caveman:`).
- If no listed agent fits, do the work inline or use `general-purpose` /
  `Explore`. Do not fabricate a specialized type.

## Handing the user a file to review (WSL)

When you point the user at a file to open/review (specs, docs, reports):
COPY it to a SHORT shallow path, then print the WSL Windows `file://` URL as a
BARE url on its own line, so it is ctrl+clickable from the terminal:

    cp <abs-path> ~/review.md
    file://wsl.localhost/Ubuntu/home/wai/review.md

Three hard requirements, all learned by failing:
- COPY, never a symlink. Windows cannot follow a Linux symlink over
  `wsl.localhost` -- the browser gets ERR_FILE_NOT_FOUND. Use a real file (re-cp
  after editing the source).
- BARE URL, never a markdown link. Claude Code styles `[name](url)` but emits no
  clickable target for `file://` -- it looks like a link and does nothing. Only
  bare URLs auto-link.
- SHORT enough for ONE terminal line. A long bare URL wraps and the line break
  kills ctrl+click. A shallow path (`~/review.md`) keeps it one line.

(WSL distro = `Ubuntu`.)
