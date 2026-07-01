#!/usr/bin/env node
// Detects which SSH key authenticated this session via PID → auth.log lookup.
// If Junni (beginner), emits instructions that override caveman mode.

const fs = require('fs');
const { execSync } = require('child_process');

const JUNNI_FP = 'SHA256:opqp1nkHcARcSBbXRZawFvfAg/rHyDoFUQJWOvi6E80';

const JUNNI_INSTRUCTIONS = `
[SessionStart hook: user-detect.js]
Connected user: Junni (junnizhong@Junnis-MacBook-Air.local) — beginner programmer, beginner AI user.

Communication style for this session:
- Full sentences, plain English. No jargon without explanation.
- Explain WHY, not just WHAT. Give context.
- Before running any command that modifies files or system state, explain what it will do in plain terms.
- Extra clear warnings before any destructive or irreversible operation.
- Define technical terms the first time they appear.
- Offer next steps and context after completing each action.
- Be patient — if something seems obvious, still explain it.
- Never assume prior knowledge. Check understanding when appropriate.
- Caveman mode does not apply this session.
`.trim();

// Walk up /proc process tree from current PID until we find an sshd process.
function findSshdPid() {
  let pid = process.pid;
  for (let i = 0; i < 15; i++) {
    try {
      const cmdline = fs.readFileSync(`/proc/${pid}/cmdline`, 'utf8');
      if (cmdline.includes('sshd')) return pid;
      const status = fs.readFileSync(`/proc/${pid}/status`, 'utf8');
      const ppidMatch = status.match(/PPid:\s+(\d+)/);
      if (!ppidMatch) break;
      const ppid = parseInt(ppidMatch[1]);
      if (ppid <= 1) break;
      pid = ppid;
    } catch (e) {
      break;
    }
  }
  return null;
}

function detectFingerprint() {
  const sshdPid = findSshdPid();
  if (!sshdPid) return null;

  try {
    const result = execSync(
      `grep "sshd\\[${sshdPid}\\]" /var/log/auth.log | grep "Accepted publickey" | tail -1`,
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }
    );
    const match = result.match(/SHA256:\S+/);
    return match ? match[0] : null;
  } catch (e) {
    return null;
  }
}

const fp = detectFingerprint();

if (fp === JUNNI_FP) {
  process.stdout.write(JUNNI_INSTRUCTIONS);
}
// No output for wai-lau — caveman mode from previous hook stands.
