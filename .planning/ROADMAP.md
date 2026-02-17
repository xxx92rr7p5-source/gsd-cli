# ROADMAP — gsd-cli

## Phase 1: Foundation & Status Dashboard

**Goal:** A working `gsd` executable that boots, parses flags, and delivers the core `gsd status` dashboard.

**Requirements covered:** §1 (all), §2.1 (all), §3 (all), §4 (all), §5 (all), §7 (all), §9 (all), §10 (all)

**Deliverables:**
- Single-file `gsd` script with shebang, `set -euo pipefail`, Google Style Guide structure
- `main()` dispatch with global flag parsing (`-v`, `--json`, `-h`, `--help`, `--version`)
- Exit codes: 0 (success), 1 (runtime error), 2 (usage error)
- Dependency check (`jq`, `opencode`) at startup with fail-fast
- Color system: ANSI escapes, TTY detection, `NO_COLOR`, `TERM=dumb`, `--json` disabling
- Utility functions: `err()`, `die()`, `format_duration()`, `printf`-based tables, `trap cleanup EXIT`
- `gsd status`: running sessions, stuck detection, queued items, last 5 completed — compact and `--verbose` views
- Stuck detection engine (§5): PID files, `kill -0`, `ps -o etimes=`, `stat -c %Y`, log staleness
- `--json` output for status (valid JSON, ISO 8601 timestamp)
- Per-subcommand `-h`/`--help` support
- Environment variable overrides: `GSD_QUEUE_FILE`, `GSD_LOG_DIR`, `GSD_STUCK_THRESHOLD`, `NO_COLOR`

**Plans:** 2 plans

Plans:
- [x] 01-01-PLAN.md — Script skeleton with CLI framework, flags, colors, utilities, help/version
- [x] 01-02-PLAN.md — Status dashboard with data layer, stuck detection, formatting, JSON output

**Success criteria:** `gsd` (no args) prints a dashboard with running/stuck/queued/completed summary. `gsd --json` outputs valid JSON. `gsd --help` prints usage. Runs in < 2 seconds.

---

## Phase 2: Queue & Stuck Commands

**Goal:** Dedicated `gsd queue` and `gsd stuck` commands with full flag support and kill capability.

**Requirements covered:** §2.2 (all), §2.3 (all)

**Deliverables:**
- `gsd queue` / `gsd q`: parse `QUEUE.md` sections (`## In Progress`, `## Queued`, `## Done`, `## Failed`), display grouped by status, color-coded, handle missing file and malformed lines
- `gsd stuck`: list stuck processes with PID, session name, runtime, last log activity
- `gsd stuck --threshold N` / `-t N`: configurable threshold
- `gsd stuck --kill` / `-k`: kill stuck processes (SIGTERM only), confirmation prompt, `--force` / `-f` to skip
- PID liveness verification and stale PID file cleanup
- `--json` output for both commands

**Plans:** 1 plan

Plans:
- [x] 02-01-PLAN.md — Complete cmd_queue and cmd_stuck implementations

**Success criteria:** `gsd queue` displays QUEUE.md items by section. `gsd stuck` finds processes exceeding threshold with stale logs. `gsd stuck --kill --force` sends SIGTERM to stuck processes and cleans up.

---

## Phase 3: Log, Tail & Installation

**Goal:** Session inspection commands and one-step installation. Ship-ready.

**Requirements covered:** §2.4 (all), §2.5 (all), §8 (all)

**Deliverables:**
- `gsd log <session>`: invoke `opencode export`, strip JSON, present assistant messages and tool results readably, error on missing session/name
- `gsd tail <session>`: live-follow `/tmp/gsd-<session>.log` via polling (with `inotifywait` if available), clean `Ctrl-C` exit via `trap`, error on missing session/log
- `install.sh`: create `~/.local/bin/` if needed, symlink `gsd`, verify symlink works, warn if not in `PATH`
- `chmod +x gsd` enforced
- Final pass: edge cases, error message polish, help text completeness
- `--json` output for `gsd log`

**Plans:** 1 plan

Plans:
- [ ] 03-01-PLAN.md — Fix get_sessions() bug, implement cmd_log, cmd_tail, create install.sh, final polish

**Success criteria:** `gsd log my-session` prints readable session transcript. `gsd tail my-session` streams live output and exits cleanly on Ctrl-C. `./install.sh` produces a working `gsd` command from any terminal. All requirements in §1–§10 are met.
