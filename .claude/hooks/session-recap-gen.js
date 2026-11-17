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

  // What "title shaped" means. ONE definition, quoted to both the writer and
  // the judge, so the thing asked for and the thing checked cannot drift apart.
  // (exec-fn's claude-box/title-gen.mjs carries its own copy for the /cc status
  // bar -- it runs as cc-agent inside a tmpfs root and cannot read this file.
  // Change one, change the other.)
  const SHAPE = [
    'A title is SHAPED like this:',
    '1. Three to six words.',
    '2. A noun phrase naming the subject. Not a sentence, not a command, not a question.',
    "3. No trailing punctuation, no surrounding quotes, no preamble ('Title:', 'Here is').",
    "4. Not first person and not addressed to the reader ('Let me help you with').",
    '5. Not a verbatim or near-verbatim echo of a message. A title NAMES the topic; it does not quote the prompt.',
    "6. Not generic filler ('Chat Session', 'General Discussion', 'Coding Help', 'Untitled').",
    '   It has to be specific enough to pick this session out of a list of forty.',
    '7. About what the session is CURRENTLY on, weighting the latest messages most.',
  ].join('\n');

  const body = 'MESSAGES:\n' + recent.map(m => `- ${m}`).join('\n');

  const haiku = (p) => execFileSync('claude', ['-p', '--model', 'claude-haiku-4-5', p], {
    encoding: 'utf8', timeout: 60000, maxBuffer: 1 << 20,
  });
  const tidy = (s) => (s || '').replace(/\s+/g, ' ').trim()
    .replace(/^["'`]+|["'`]+$/g, '')                 // strip wrapping quotes
    .replace(/[.\s]+$/, '');                          // strip trailing dot/space

  // The deterministic floor, checked BEFORE spending a call on the judge. Most
  // of "title shaped" is countable, and code checks those perfectly while a
  // model is merely likely to: measured on this very path, a haiku judge PASSED
  // both "Chat Session" and "Sourdough" by quietly writing its own title and
  // grading that instead. Every bad title in that test is caught here for free.
  const GENERIC = new Set(['chat session', 'chat', 'conversation', 'general discussion',
    'general chat', 'coding help', 'technical discussion', 'various topics', 'untitled',
    'new conversation', 'help request', 'assistant conversation', 'discussion']);
  function shapeFault(t) {
    t = (t || '').trim();
    if (!t) return 'it was empty';
    const w = t.split(/\s+/);
    if (w.length < 3) return `it is only ${w.length} word${w.length === 1 ? '' : 's'}; a title is three to six words naming the subject`;
    if (w.length > 6) return `it is ${w.length} words; a title is three to six words`;
    if (/[.!?,:;]$/.test(t)) return 'it ends in punctuation; drop the trailing mark';
    if (/^["'`]|["'`]$/.test(t)) return 'it is wrapped in quotes; drop them';
    if (/^(title|here|sure|okay)\b/i.test(t)) return 'it starts with a preamble; output the title by itself';
    if (GENERIC.has(t.toLowerCase())) return 'it is generic filler that would fit any session; name what THIS one is specifically about';
    if (/^(let me|i can|i will|i'll|your |you )/i.test(t)) return 'it addresses the reader; use a noun phrase naming the subject instead';
    if (t.length > 12 && body.toLowerCase().includes(t.toLowerCase())) return 'it quotes a message verbatim; name the topic rather than echoing the prompt';
    return null;
  }

  // A SECOND, independent call judges what the floor lets through -- whether the
  // title actually names what the session is about, the part no rule can check.
  // The proposed title goes FIRST: trailing it after the transcript is what let
  // the judge lose track of which string it was grading. Unreadable verdict =
  // pass, so a chatty judge can never cost us a perfectly good title.
  function judge(title) {
    let raw;
    try {
      raw = haiku(
        'You check whether a proposed session title is title SHAPED.\n' + SHAPE +
        '\nYou are given a PROPOSED TITLE and, for context only, the messages it' +
        ' names. Judge the proposed title exactly as given. Do NOT write a title of' +
        ' your own and do not grade a better one you thought of. Be strict about' +
        ' shape but do not bikeshed word choice.\n' +
        'Reply with JSON and nothing else: {"ok":true} or {"ok":false,"feedback":' +
        '"<one sentence: what is wrong and what to do instead>"}.\n\n' +
        'PROPOSED TITLE: ' + title + '\n\nCONVERSATION (context only):\n' + body);
    } catch (e) { return { ok: true }; }
    // Not JSON.parse: measured replies came back ```json-fenced, as a one-element
    // ARRAY, and followed by a paragraph of prose. Read the fields out directly.
    const s = String(raw);
    const ok = /"ok"\s*:\s*(true|false)/i.exec(s);
    if (!ok) return { ok: true };
    const fb = /"feedback"\s*:\s*"((?:[^"\\]|\\.)*)"/i.exec(s);
    return { ok: ok[1].toLowerCase() === 'true', feedback: fb ? fb[1].replace(/\\"/g, '"').trim() : '' };
  }

  const write = (extra) => tidy(haiku(
    'You are titling a Claude Code session for a narrow status bar. From the recent ' +
    'user messages below, write the title.\n' + SHAPE +
    '\nOutput ONLY the title: no quotes, no trailing punctuation, no preamble.\n\n' +
    body + (extra || '')));

  // One retry, not three: two writes plus two judges is already four `claude -p`
  // subprocesses, and the feedback loop's whole gain lands on the first retry.
  let out = write('');
  if (out) {
    const fault = shapeFault(out);            // free check first
    const v = fault ? { ok: false, feedback: fault } : judge(out);
    if (!v.ok) {
      const better = write(
        `\n\nYour previous attempt was "${out}", which was REJECTED: ` +
        `${v.feedback || 'it was not title shaped'}\nWrite a better title that fixes exactly that.`);
      // Keep the retry even if it fails too -- it had the most feedback behind
      // it, and a mediocre title beats a blank status bar.
      if (better) out = better;
    }
  }
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
