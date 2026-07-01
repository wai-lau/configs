#!/usr/bin/env node
// Background recap generator. Spawned detached by session-recap.js every N prompts.
// Reads the recent user messages from a session transcript, asks haiku for a tiny
// rolling title, and writes it to cache/recap_<sid>.txt (atomic, lock-guarded).
// Keyed entirely by session_id so panes never collide.
//
//   node session-recap-gen.js <transcript_path> <session_id>
//
// Display lives in statusline-command.sh, which just reads the cache file — so this
// never touches the TTY (no keystroke race) and a slow/failed call only leaves the
// previous good recap in place.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

const [transcript, sid] = process.argv.slice(2);
if (!transcript || !sid) process.exit(0);

const cacheDir = path.join(process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude'), 'cache');
const outFile = path.join(cacheDir, `recap_${sid}.txt`);
const lockFile = path.join(cacheDir, `recap_${sid}.lock`);
const LOCK_TTL = 120 * 1000;   // a stuck lock self-clears after 2 min

try { fs.mkdirSync(cacheDir, { recursive: true }); } catch (e) {}

// Single-flight: bail if another generation is in progress (and still fresh).
try {
  const st = fs.statSync(lockFile);
  if (Date.now() - st.mtimeMs < LOCK_TTL) process.exit(0);
  fs.unlinkSync(lockFile);   // stale lock — reclaim
} catch (e) { /* no lock — proceed */ }

let locked = false;
try {
  fs.writeFileSync(lockFile, String(process.pid), { flag: 'wx' });
  locked = true;
} catch (e) {
  process.exit(0);   // lost the race
}

function release() { if (locked) { try { fs.unlinkSync(lockFile); } catch (e) {} } }

try {
  // Pull the human text out of the last ~14 user turns. Tool-result user records
  // carry no plain text, so they fall away naturally; bracket-only event markers
  // (e.g. "[opened ...]") are skipped so they don't dominate the summary.
  const lines = fs.readFileSync(transcript, 'utf8').split('\n').filter(Boolean);
  const msgs = [];
  for (const ln of lines) {
    let o;
    try { o = JSON.parse(ln); } catch (e) { continue; }
    if (o.type !== 'user' || !o.message) continue;
    const c = o.message.content;
    let text = '';
    if (typeof c === 'string') text = c;
    else if (Array.isArray(c)) text = c.filter(b => b && b.type === 'text').map(b => b.text).join(' ');
    text = (text || '').replace(/\s+/g, ' ').trim();
    if (!text) continue;
    if (/^\[.*\]$/.test(text)) continue;             // pure event marker
    if (text.startsWith('<')) continue;              // injected reminder/meta
    msgs.push(text.length > 200 ? text.slice(0, 200) : text);
  }
  const recent = msgs.slice(-14);
  if (!recent.length) { release(); process.exit(0); }

  const prompt =
    'You are titling a Claude Code session for a narrow status bar. From the recent ' +
    'user messages below, write a 3-6 word title for what the session is CURRENTLY ' +
    'about (weight the latest messages most). Output ONLY the title: no quotes, no ' +
    'trailing punctuation, no preamble.\n\nMESSAGES:\n' +
    recent.map(m => `- ${m}`).join('\n');

  let out = execFileSync('claude', ['-p', '--model', 'claude-haiku-4-5', prompt], {
    encoding: 'utf8', timeout: 60000, maxBuffer: 1 << 20,
  });
  out = (out || '').replace(/\s+/g, ' ').trim()
    .replace(/^["'`]+|["'`]+$/g, '')                 // strip wrapping quotes
    .replace(/[.\s]+$/, '');                          // strip trailing dot/space
  if (out.length > 50) out = out.slice(0, 49) + '…';
  if (!out) { release(); process.exit(0); }

  // Atomic publish so the statusline never reads a half-written file.
  const tmp = `${outFile}.${process.pid}.tmp`;
  fs.writeFileSync(tmp, out);
  fs.renameSync(tmp, outFile);
} catch (e) {
  // Leave the previous good recap untouched.
} finally {
  release();
}
