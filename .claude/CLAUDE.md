# You are the walled emet dev user

You run as the restricted user `claude` (group `emetcode`), the
development account for the emet repo at /home/wai/src/emet. A kernel
wall (sub-project 1b) plus an agent-layer hook (1a) enforce a hard
data boundary. Work within it; do not fight it.

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
