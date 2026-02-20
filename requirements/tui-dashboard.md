# GSD TUI Dashboard (`gsd tui`)

## Problem

Monitoring the GSD pipeline requires repeatedly running `gsd status`, `gsd queue`, `gsd tail <session>` etc. A live-updating terminal dashboard would make pipeline monitoring effortless — one command, all info at a glance, auto-refreshing.

## Goal

`gsd tui` launches a full-screen terminal UI that shows pipeline status, queue, running sessions with live logs, and completed sessions — all auto-refreshing. Think `htop` but for the GSD build pipeline.

## Requirements

### Must Have

- [ ] **New `cmd_tui` function** in the existing `gsd` bash script that invokes a Node-based TUI: `node "$SCRIPT_DIR/tui/dist/index.js"`. The TUI is built with **OpenTUI** (`@opentui/core` + `@opentui/react`) — the same framework behind OpenCode. Install deps in `gsd-cli/tui/` with a `package.json`. Use the React reconciler for component-based UI. See https://opentui.com/docs/getting-started and https://github.com/anomalyco/opentui for API docs. Install the opentui skill for the AI agent: `npx skills add msmps/opentui-skill` (or read the skill manually from the repo).
- [ ] **Layout** — full-screen with these panels:
  ```
  ┌─────────────────────────────────────────────────┐
  │  GSD Pipeline Dashboard          ▲ 2 running    │
  │                                  ⟳ 6 queued     │
  │                                  ✓ 3 done       │
  ├──────────────────────┬──────────────────────────┤
  │  RUNNING             │  QUEUE                   │
  │  ● project-a (12m)  │  1. router | quick fix   │
  │    └ last line...    │  2. hub | build-full     │
  │  ● project-b (5m)   │  3. resume-roast | quick │
  │    └ last line...    │  ...                     │
  ├──────────────────────┴──────────────────────────┤
  │  LOG: project-a                                  │
  │  > Planning task: fix asset routing...           │
  │  > Reading requirements/fix-asset...             │
  │  > Created .planning/quick/...                   │
  │                                                  │
  ├──────────────────────────────────────────────────┤
  │  COMPLETED (last 5)                              │
  │  ✓ baby-predictor email-kv (3m ago)             │
  │  ✓ pet-portraits email-kv (5m ago)              │
  └──────────────────────────────────────────────────┘
  │  [q]uit  [↑↓]select  [enter]view log  [k]ill   │
  ```
- [ ] **Auto-refresh** every 3 seconds (configurable via `--interval N`)
- [ ] **Running panel** — shows each running session with project name, duration, and last log line (truncated to fit)
- [ ] **Queue panel** — shows pending QUEUE.md items with project + command summary
- [ ] **Log panel** — shows the tail of the currently selected running session's log (bottom 10-15 lines). Use the same log-reading logic as `cmd_tail`/`cmd_log`.
- [ ] **Completed panel** — last 5 completed sessions with relative timestamps ("3m ago", "1h ago")
- [ ] **Keyboard navigation:**
  - `q` or `Ctrl-C` — quit, restore terminal
  - `↑`/`↓` or `j`/`k` — select running session (highlights in log panel)
  - `Enter` — toggle full-screen log view for selected session
  - `K` (shift-k) — kill selected session (with confirmation)
  - `r` — force refresh
- [ ] **Summary bar** at top — running count, stuck count, queued count, completed count (like the existing `gsd status` header)
- [ ] **Terminal cleanup** — properly restore terminal state on exit (trap SIGINT/SIGTERM, reset cursor, clear alternate screen buffer)
- [ ] **Alternate screen buffer** — use `tput smcup`/`tput rmcup` so the TUI doesn't pollute scrollback
- [ ] **Responsive** — adapt layout to terminal width/height. If terminal is too narrow, stack panels vertically instead of side-by-side.
- [ ] **Color scheme** — reuse existing gsd-cli color variables (GREEN for running, YELLOW for queued, CYAN for completed, RED for stuck/errors)

### Nice to Have

- [ ] **Stuck detection indicator** — if a running session has low CPU activity for >threshold, show it in red with ⚠️
- [ ] **Queue progress bar** — show `[3/10 ████░░░░░░]` style progress of total queue
- [ ] **Notification on completion** — flash/highlight when a session completes during the TUI session
- [ ] **`--compact` mode** — minimal view without the log panel, just status + queue + running in a small footprint

## Technical Notes

- **Stack**: Node.js + `@opentui/core` + `@opentui/react` in `gsd-cli/tui/` directory. OpenTUI requires Zig for native builds — install via `curl -fsSL https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz | tar -xJ -C /tmp && export PATH="/tmp/zig-linux-x86_64-0.13.0:$PATH"` if not present. Use TypeScript + tsx for dev, compile to JS for distribution.
- **Data source**: shell out to `gsd status --json`, `gsd queue`, and read opencode session log files directly (same paths as `cmd_log` — search `~/.local/share/opencode/sessions/` for session dirs)
- **Queue file**: read `$GSD_QUEUE_FILE` (default `~/dev/punchlab/QUEUE.md`) directly — parse `## project | mode | args` format, skip `✅ DONE:` / `❌ FAIL:` lines
- **Log tailing**: use `fs.watch` or poll the session's `messages.jsonl` file for live updates
- **Process detection**: parse `ps aux | grep opencode` or use `gsd status --json` output
- The bash `gsd` script just needs a small `cmd_tui()` that does `exec node "$SCRIPT_DIR/tui/index.mjs" "$@"`
- Add `tui` to the subcommand dispatch in `main()` and to help text
- Run `cd gsd-cli/tui && pnpm install` after scaffolding

## Do NOT

- Do NOT modify existing bash commands — tui is additive, bash CLI stays as-is
- Do NOT use hardcoded terminal dimensions — blessed handles this automatically
- Do NOT leave terminal in raw mode on exit — blessed handles cleanup but add process.on('exit') safety
- Do NOT add the `tui/node_modules` to git — add to `.gitignore`
- Do NOT use blessed/neo-blessed — use OpenTUI (`@opentui/core` + `@opentui/react`)
- If OpenTUI's React reconciler causes issues (it's pre-1.0), fall back to `@opentui/core` imperative API
