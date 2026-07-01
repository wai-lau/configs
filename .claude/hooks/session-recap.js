#!/usr/bin/env node
// UserPromptSubmit hook: keeps a per-session rolling recap fresh for the statusline.
// Counts prompts per session_id; on the 1st and every Nth, spawns the background
// generator (detached, non-blocking) which writes cache/recap_<sid>.txt. Emits no
// output, so the prompt proceeds untouched and nothing is ever typed into the TTY.
//
// N = env CLAUDE_RECAP_EVERY (default 5). Everything is keyed by session_id, so
// concurrent panes each maintain their own recap.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawn } = require('child_process');

let input = '';
process.stdin.on('data', c => { input += c; });
process.stdin.on('end', () => {
  try {
    const d = JSON.parse(input || '{}');
    const sid = d.session_id;
    const transcript = d.transcript_path;
    if (!sid || !transcript) return;

    const every = Math.max(1, parseInt(process.env.CLAUDE_RECAP_EVERY || '5', 10) || 5);
    const claudeDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
    const cacheDir = path.join(claudeDir, 'cache');
    try { fs.mkdirSync(cacheDir, { recursive: true }); } catch (e) {}

    const countFile = path.join(cacheDir, `recap_${sid}.count`);
    let n = 0;
    try { n = parseInt(fs.readFileSync(countFile, 'utf8').trim(), 10) || 0; } catch (e) {}
    n += 1;
    try { fs.writeFileSync(countFile, String(n)); } catch (e) {}

    if (n !== 1 && n % every !== 0) return;

    const gen = path.join(__dirname, 'session-recap-gen.js');
    const child = spawn(process.execPath, [gen, transcript, sid], {
      detached: true, stdio: 'ignore',
    });
    child.unref();
  } catch (e) {
    // Silent — recap is best-effort, must never block a prompt.
  }
});
