# Graph Report - /home/wai  (2026-06-26)

## Corpus Check
- Large corpus: 7415 files · ~36,842,828 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 6 nodes · 3 edges · 3 communities (1 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `86965654`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_statusline-command.sh|statusline-command.sh]]
- [[_COMMUNITY_preview.sh script|preview.sh script]]

## God Nodes (most connected - your core abstractions)
1. `statusline-command.sh script` - 1 edges
2. `preview.sh script` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (3 total, 2 thin omitted)

## Knowledge Gaps
- **2 isolated node(s):** `statusline-command.sh script`, `preview.sh script`
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `statusline-command.sh script`, `preview.sh script` to the rest of the system?**
  _2 weakly-connected nodes found - possible documentation gaps or missing edges._