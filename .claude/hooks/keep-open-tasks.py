#!/usr/bin/env python3
"""UserPromptSubmit: a new message adds a task; it never cancels an open one.

Tasks got dropped when Wai interrupted mid-task to raise a different issue
(Wai, 2026-11-18: "Don't drop a task unless I contradict myself or
explicitly say so"). Every prompt gets a short reminder in context, so the
rule is in view at the moment of the interrupt, deep into a long session too.
The full rule lives in ~/.claude/CLAUDE.md ("Working with Wai").
"""
import json

REMINDER = (
    'Open-task rule: this message ADDS to any unfinished task; it does not '
    'cancel one, even if it interrupted you or raises a different issue. '
    'Handle it, then resume every earlier open task without being asked. '
    'Drop a task only when Wai says to (drop / stop / forget it / nvm) or this '
    'message contradicts it. End the turn naming each task still open.'
)

print(json.dumps({'hookSpecificOutput': {
    'hookEventName': 'UserPromptSubmit',
    'additionalContext': REMINDER}}))
