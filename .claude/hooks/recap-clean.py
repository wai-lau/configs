#!/usr/bin/env python3
"""Sanitize an LLM-written recap title into a bare 3-6 word title.

haiku sometimes ignores the "title only" instruction and emits prose,
markdown, or a numbered list. Without cleanup that junk lands in the
statusline bar and gets chopped mid-word by a blind char cut, e.g.
  **Console froze OR machine hung.** Test:  1. **Clo
This strips markup, keeps the first clause, and cuts on a word boundary.
Reads raw title on stdin, writes the cleaned title on stdout."""
import sys, re

raw = sys.stdin.read()

# First non-empty line — drop any preamble/trailing lines.
line = ""
for l in raw.splitlines():
    if l.strip():
        line = l.strip()
        break

# Strip markdown emphasis/code/heading/quote markers and list bullets.
line = re.sub(r"[`*_#>~]+", " ", line)
line = re.sub(r"^\s*[-•]\s*", "", line)
line = re.sub(r"^\s*\d+[.)]\s*", "", line)        # leading "1." / "2)"
line = line.strip().strip("\"'“”‘’")

# Drop a leading "Here is the title:" / "Topic -" style preamble, keep what follows.
line = re.sub(r"^(here'?s|here is|the)?\s*(the\s+)?(title|topic|task|summary)\s*[:\-]\s*",
              "", line, flags=re.I).strip()

# If prose leaked, keep only the clause before the first sentence break.
line = re.split(r"[.!?]\s", line)[0]
line = " ".join(line.split())

# Cap at 8 words, then at 48 chars on a word boundary (statusline backstops at 49).
words = line.split()
if len(words) > 8:
    line = " ".join(words[:8])
if len(line) > 48:
    line = line[:48].rsplit(" ", 1)[0]

sys.stdout.write(line)
