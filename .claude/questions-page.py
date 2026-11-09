#!/usr/bin/env python3
"""Render a repo's OPEN-QUESTIONS.md as the Artifact page Wai opens (any repo).

Usage: questions-page.py <OPEN-QUESTIONS.md> <out.html> [version] [page title]
The page title defaults to "Open Questions"; pass e.g. "Spire Open Questions".
Handles the subset the doc uses: # / ## / ### headings, pipe tables,
paragraphs, - and 1. lists, **bold**, `code`. Then publish <out.html>
with the Artifact tool (same url every time).
"""
import html
import re
import sys

src, out = sys.argv[1], sys.argv[2]
version = sys.argv[3] if len(sys.argv) > 3 else ""
page_title = sys.argv[4] if len(sys.argv) > 4 else "Open Questions"
lines = open(src, encoding="utf-8").read().splitlines()


def inline(t):
    t = html.escape(t, quote=False)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"(https?://[^\s<]+)", r'<a href="\1">\1</a>', t)
    return t


def cells(row):
    row = row.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|"):
        row = row[:-1]
    return [c.strip() for c in row.split("|")]


body, title, sections = [], "Open questions", []
i, n = 0, len(lines)
open_count = None
cur = None
while i < n:
    ln = lines[i]
    s = ln.strip()
    if not s:
        i += 1
        continue
    m = re.match(r"^(#{1,3})\s+(.*)$", s)
    if m:
        lvl, text = len(m.group(1)), m.group(2)
        if lvl == 1:
            title = text
        else:
            if cur is not None:
                body.append("</section>")
            slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
            cls = "sec"
            if text.lower().startswith("open"):
                cls += " sec-open"
            body.append(f'<section class="{cls}" id="{slug}"><h2>{inline(text)}</h2>')
            cur = text
        i += 1
        continue
    if s.startswith("|"):
        rows = []
        while i < n and lines[i].strip().startswith("|"):
            rows.append(lines[i])
            i += 1
        head = cells(rows[0])
        data = [cells(r) for r in rows[2:]] if len(rows) > 1 and re.match(r"^\|?\s*:?-", rows[1].strip()) else [cells(r) for r in rows[1:]]
        t = ['<div class="tbl"><table><thead><tr>']
        t += [f"<th>{inline(h)}</th>" for h in head]
        t.append("</tr></thead><tbody>")
        for r in data:
            t.append("<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>")
        t.append("</tbody></table></div>")
        body.append("".join(t))
        continue
    lm = re.match(r"^(\d+\.|[-*])\s+(.*)$", s)
    if lm:
        ordered = lm.group(1)[0].isdigit()
        tag = "ol" if ordered else "ul"
        items = []
        while i < n:
            mm = re.match(r"^\s*(\d+\.|[-*])\s+(.*)$", lines[i])
            if not mm:
                break
            items.append(mm.group(2))
            i += 1
        body.append(f"<{tag}>" + "".join(f"<li>{inline(x)}</li>" for x in items) + f"</{tag}>")
        continue
    para = []
    while i < n and lines[i].strip() and not re.match(r"^(#{1,3}\s|\||\d+\.\s|[-*]\s)", lines[i].strip()):
        para.append(lines[i].strip())
        i += 1
    body.append(f"<p>{inline(' '.join(para))}</p>")
if cur is not None:
    body.append("</section>")

stamp = ""
for ln in lines:
    m = re.search(r"Updated (\d{4}-\d{2}-\d{2} \d{2}:\d{2})", ln)
    if m:
        stamp = m.group(1)
        break
# open questions = the bold-numbered paragraphs ("**1. ...") in the Open section
sec = re.search(r"^## Open\s*$(.*?)(?=^## )", "\n".join(lines) + "\n## ", re.M | re.S)
oc = len(re.findall(r"^\*\*\d+\.", sec.group(1), re.M)) if sec else 0
chip = f'<span class="chip chip-hot">{oc} open</span>' if oc else '<span class="chip">none open</span>'
ver = f'<span class="meta-item">live build {html.escape(version)}</span>' if version else ""

page = f"""<title>{html.escape(page_title)}</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:ital,wght@0,400;0,700;1,400&family=Chakra+Petch:wght@500;600&display=swap">
<style>
/* Layout: one reading column; the Open section is the one lit block, everything else is quiet ledger. */
:root {{
  --bg: #f3f4f7; --surface: #ffffff; --ink: #1b2233; --muted: #5d6680;
  --rule: #d9dde7; --accent: #9a6a08; --accent-soft: #fbf1db; --hot: #b4361f;
  --f-display: "Chakra Petch", "Segoe UI", system-ui, sans-serif;
  --f-body: "Atkinson Hyperlegible", "Segoe UI", system-ui, sans-serif;
  --f-mono: ui-monospace, "SF Mono", Menlo, Consolas, monospace;
}}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{
  --bg: #11141c; --surface: #181c27; --ink: #e5e8f0; --muted: #98a0b6;
  --rule: #2b3142; --accent: #e2b54a; --accent-soft: #2a2414; --hot: #ff7a5c; color-scheme: dark;
}} }}
:root[data-theme="dark"] {{
  --bg: #11141c; --surface: #181c27; --ink: #e5e8f0; --muted: #98a0b6;
  --rule: #2b3142; --accent: #e2b54a; --accent-soft: #2a2414; --hot: #ff7a5c; color-scheme: dark;
}}
body {{ background: var(--bg); color: var(--ink); font: 16px/1.55 var(--f-body);
  padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px)); padding-block: 28px 56px; }}
main {{ max-width: 760px; margin: 0 auto; display: flex; flex-direction: column; gap: 22px; }}
header {{ display: flex; flex-direction: column; gap: 6px; }}
h1 {{ font: 600 1.75rem/1.15 var(--f-display); letter-spacing: .01em; margin: 0; text-wrap: balance; }}
.meta {{ display: flex; flex-wrap: wrap; gap: 6px 14px; align-items: center; color: var(--muted); font-size: .85rem; font-variant-numeric: tabular-nums; }}
.chip {{ font: 600 .72rem/1 var(--f-display); letter-spacing: .08em; text-transform: uppercase; padding: 5px 8px; border: 1px solid var(--rule); border-radius: 4px; color: var(--muted); }}
.chip-hot {{ color: var(--hot); border-color: var(--hot); }}
.sec {{ display: flex; flex-direction: column; gap: 10px; min-width: 0; padding-top: 14px; border-top: 1px solid var(--rule); }}
.sec-open {{ background: var(--accent-soft); border: 1px solid var(--accent); border-radius: 6px; padding: 14px 16px; }}
h2 {{ font: 600 .8rem/1.2 var(--f-display); letter-spacing: .12em; text-transform: uppercase; color: var(--accent); margin: 0; text-wrap: balance; }}
p, ul, ol {{ margin: 0; max-width: 68ch; }}
ul, ol {{ padding-left: 1.3em; display: flex; flex-direction: column; gap: 4px; }}
strong {{ font-weight: 700; }}
code {{ font: .88em var(--f-mono); }}
a {{ color: var(--accent); }}
.tbl {{ overflow-x: auto; min-width: 0; }}
table {{ border-collapse: collapse; width: 100%; font-size: .9rem; font-variant-numeric: tabular-nums; background: var(--surface); }}
th, td {{ text-align: left; vertical-align: top; padding: 7px 10px; border-bottom: 1px solid var(--rule); }}
th {{ font: 600 .72rem/1.2 var(--f-display); letter-spacing: .08em; text-transform: uppercase; color: var(--muted); }}
tr:last-child td {{ border-bottom: 0; }}
</style>
<main>
<header>
<h1>{inline(title)}</h1>
<div class="meta">{chip}<span class="meta-item">updated {html.escape(stamp)}</span>{ver}</div>
</header>
{''.join(body)}
</main>
"""
open(out, "w", encoding="utf-8").write(page)
print(f"wrote {out}: {oc} open, stamp {stamp}")
