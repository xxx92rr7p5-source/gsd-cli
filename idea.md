# gsd-cli — Pipeline Monitoring Tool

## What
A CLI tool that gives instant visibility into opencode GSD pipeline runs. Think `htop` for our build pipeline.

## Why
Right now, monitoring the GSD pipeline requires 3-4 manual commands, parsing raw PIDs, and guessing whether a session is stuck or working. We lost 4 hours to a hung plan-phase because there was no easy way to detect it.

## Core Commands

### `gsd status` (dashboard)
Show at a glance:
- What's currently running (session name, duration, phase)
- Whether it's stuck (running > 30min with no log growth)
- What's queued in QUEUE.md
- What recently finished (last 5 completions with pass/fail)

### `gsd log <session>` 
Show the actual conversation/output from an opencode session. Uses `opencode export` under the hood but presents it readably — strip JSON, show assistant messages and tool results.

### `gsd tail <session>`
Live-follow a running session's output. Like `tail -f` but for opencode sessions.

### `gsd stuck`
Find any opencode run that's been going > N minutes (default 30). Show PID, session name, how long it's been running, last log activity. Optionally kill with `gsd stuck --kill`.

### `gsd queue`
Pretty-print QUEUE.md status. Show what's queued, in progress, done, failed.

## Technical Notes
- Should work from anywhere (not tied to a specific project dir)
- Uses `opencode session list`, `opencode export`, `opencode stats` under the hood
- Bash or Node.js — whatever makes sense for parsing JSON
- Should be installable globally or at least callable from PATH
- QUEUE.md lives at ~/dev/punchlab/QUEUE.md
- Pipeline logs live at /tmp/gsd-*.log
- PIDs stored at /tmp/gsd-*-pid

## Design
- Clean terminal output with colors
- Compact by default, verbose with flags
- Fast — status command should complete in < 2 seconds

## Do NOT
- Don't build a TUI (no curses/blessed) — simple CLI output is fine
- Don't require config files — convention over configuration
- Don't duplicate opencode functionality — wrap it
