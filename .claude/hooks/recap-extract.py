#!/usr/bin/env python3
"""Read a Claude Code transcript JSONL, emit the recent conversation as
plain text for the recap summarizer. Tool calls/results stripped to keep
the prompt small. Usage: recap-extract.py <transcript_path>"""
import sys, json

MAX_MSGS = 14      # last N user/assistant turns
MAX_CHARS = 3500   # hard cap on emitted text

def text_of(msg):
    c = msg.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        out = []
        for b in c:
            if isinstance(b, dict) and b.get("type") == "text":
                out.append(b.get("text", ""))
        return " ".join(out)
    return ""

path = sys.argv[1] if len(sys.argv) > 1 else ""
rows = []
try:
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            m = d.get("message") or {}
            role = m.get("role") or d.get("type")
            if role not in ("user", "assistant"):
                continue
            t = text_of(m).strip()
            if not t:
                continue
            rows.append((role, " ".join(t.split())))
except Exception:
    sys.exit(0)

rows = rows[-MAX_MSGS:]
buf = "\n".join(f"{r}: {t}" for r, t in rows)
sys.stdout.write(buf[-MAX_CHARS:])
