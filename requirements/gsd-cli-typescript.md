# GSD CLI — Complete TypeScript Rewrite

## Vision

GSD (Get Shit Done) is an autonomous AI development pipeline. It queues work, spawns AI coding agents, manages lifecycles (plan → execute → verify), and monitors everything from a terminal dashboard.

Today it's split across two fragile bash scripts (1400-line monitoring CLI + 670-line queue runner). This rewrite unifies everything into a single, well-typed TypeScript CLI — the kind of project developers star on GitHub because it's genuinely useful AND demonstrates the future of AI-controlled software development.

**This is a NEW project.** We're not patching bash. We're building `gsd` from scratch in TypeScript, referencing the old code as a spec.

## Source Code to Reference

The agent MUST read these files to understand exactly what the CLI does today:

- **`~/dev/punchlab/gsd-cli/gsd`** — The 1415-line bash monitoring CLI. Every command, every flag, every output format. This is the ground truth for `status`, `queue`, `stuck`, `log`, `tail`, `projects`.
- **`~/dev/punchlab/gsd-queue-v5.sh`** — The 667-line bash queue runner. Every lifecycle mode, every state transition, every process management pattern. This is the ground truth for `gsd run`.
- **`~/dev/punchlab/gsd-cli/requirements/post-mortem-phantom-builds.md`** — Critical bugs to fix in the rewrite (phantom completions, `build-full` ignoring requirements).

## Project Setup

```
gsd-cli/                         # ~/dev/punchlab/gsd-cli/
├── src/
│   ├── index.ts                  # Entry point, arg parsing
│   ├── commands/
│   │   ├── status.ts             # gsd status
│   │   ├── queue.ts              # gsd queue / gsd q  
│   │   ├── stuck.ts              # gsd stuck
│   │   ├── log.ts                # gsd log <session>
│   │   ├── tail.ts               # gsd tail <session>
│   │   ├── projects.ts           # gsd projects / gsd p
│   │   ├── run.ts                # gsd run (queue runner)
│   │   └── add.ts                # gsd add <project> <mode> [args]
│   ├── core/
│   │   ├── config.ts             # Paths, env vars, defaults
│   │   ├── queue-parser.ts       # Parse QUEUE.md format
│   │   ├── queue-writer.ts       # Atomic QUEUE.md updates
│   │   ├── session-scanner.ts    # Find/read opencode sessions
│   │   ├── process-manager.ts    # Spawn/track/kill opencode processes
│   │   ├── project-scanner.ts    # Scan project dirs, git info
│   │   ├── state-reader.ts       # Parse STATE.md + ROADMAP.md
│   │   └── lifecycle-engine.ts   # Lifecycle state machine
│   ├── lifecycles/
│   │   ├── index.ts              # Registry + dispatch
│   │   ├── build-full.ts         # New project → all phases
│   │   ├── add-and-build.ts      # Add phase → build it
│   │   ├── continue.ts           # One phase cycle
│   │   ├── continue-all.ts       # All remaining phases
│   │   ├── build-to-phase.ts     # Stop after phase N
│   │   └── run-command.ts        # Raw GSD command passthrough
│   ├── utils/
│   │   ├── colors.ts             # Chalk, NO_COLOR, TTY detection
│   │   ├── logger.ts             # Timestamped file + stdout logging
│   │   ├── format.ts             # Durations, tables, truncation
│   │   └── paths.ts              # Requirement path resolution
│   └── types.ts                  # All interfaces
├── tests/
│   ├── queue-parser.test.ts
│   ├── queue-writer.test.ts
│   ├── session-scanner.test.ts
│   ├── state-reader.test.ts
│   ├── lifecycle-engine.test.ts
│   ├── process-manager.test.ts
│   ├── commands/
│   │   ├── status.test.ts
│   │   ├── queue.test.ts
│   │   └── stuck.test.ts
│   └── fixtures/
│       ├── queue-samples.md
│       ├── state-samples/
│       └── session-samples/
├── bin/gsd                       # #!/usr/bin/env node shim
├── package.json
├── tsconfig.json
├── vitest.config.ts
├── .gitignore
├── LICENSE                       # MIT
└── README.md
```

### Tech Stack

- **TypeScript 5.x** — strict mode, ESM, target ES2022
- **Build**: `tsc` → `dist/`. No bundler.
- **CLI parsing**: `commander` (mature, lightweight)
- **Colors**: `chalk` (standard, respects NO_COLOR)
- **Testing**: `vitest`
- **NO heavy frameworks** — no oclif, no yargs-with-plugins, no nest

### Installation

```bash
pnpm install && pnpm build
# bin/gsd is the entry point — symlink it:
ln -sf $(pwd)/bin/gsd ~/.local/bin/gsd
```

---

## Phase 1: Core CLI — Monitoring Commands

Port all 6 monitoring commands from the bash `gsd` script. Output format must be **identical** to the current bash version (same colors, same layout, same truncation). Run the bash version, capture its output, and match it exactly.

### Commands

#### `gsd status` (default command)
- Dashboard: running count, stuck count, queued count, completed count
- **Compact view** (default): summary line + running sessions table
- **`--verbose`**: full details — PIDs, full paths, timestamps
- **`--json`**: valid JSON object with ISO 8601 timestamp
- Data source: `opencode session list --format json` (cached, called once)
- Stuck detection integrated (see `gsd stuck` logic below)
- Must complete in < 2 seconds

#### `gsd queue` / `gsd q`
- Read and display `QUEUE.md` (path from `$GSD_QUEUE_FILE` or `~/dev/punchlab/QUEUE.md`)
- Parse v5 format: `## [marker] project | mode [| args]`
- Status markers: `✅ DONE:` (done), `❌ FAIL:` (failed), `🔨` (running), unmarked (pending)
- Group by status: In Progress → Queued → Done → Failed
- Color-coded per status
- Handle missing file, malformed lines, empty queue gracefully

#### `gsd stuck`
- Find opencode processes running longer than threshold (default: 90 min)
- Check BOTH: runtime > threshold AND log file stale > 5 minutes
- Display: PID, session name, runtime, last log activity
- **`--threshold N` / `-t N`**: custom threshold in minutes
- **`--kill` / `-k`**: send SIGTERM to stuck processes
- **`--force` / `-f`**: skip confirmation prompt
- Clean up stale PID files (PID file exists but process dead)
- `--json` output supported

#### `gsd log <session>`
- Positional arg: session name (required)
- Read session's `messages.jsonl` from `~/.local/share/opencode/sessions/`
- **Fuzzy matching**: `gsd log baby` matches `baby-predictor-quickfix-...`
- Format: strip JSON, show assistant messages and tool results readably
- Same formatting as current bash `cmd_log` — match it exactly
- Error on missing session with helpful message

#### `gsd tail <session>`
- Live-follow a session's messages.jsonl using `fs.watch` + readline
- Clean exit on Ctrl-C with trap cleanup
- Error if session not running or log missing

#### `gsd projects` / `gsd p`
- Scan `$GSD_PROJECT_DIRS` (default: `~/dev/punchlab/*/`)
- For each dir with `.git`: show project name, current branch, dirty/clean status
- Color-coded: green = clean, yellow = dirty, red = detached HEAD

### Global Flags
- `--verbose` / `-v`: detailed output
- `--json`: machine-readable JSON output
- `--help` / `-h`: usage for command or global
- `--version`: print version string

### Config (env vars, no config files)
- `GSD_QUEUE_FILE` — path to QUEUE.md (default: `~/dev/punchlab/QUEUE.md`)
- `GSD_LOG_DIR` — log file directory (default: `/tmp`)
- `GSD_STUCK_THRESHOLD` — stuck threshold in minutes (default: `90`)
- `GSD_PROJECT_DIRS` — project root directory (default: `~/dev/punchlab`)
- `NO_COLOR` — disable colors (https://no-color.org/)

### Exit Codes
- `0` — success
- `1` — runtime error
- `2` — usage error (bad args, unknown command)

### Known Bug Fix
- **Running count off-by-one**: current bash `gsd status` shows "6 running" but lists 5. The count MUST equal the array length. Single source of truth.

### Tests (Phase 1)
- [ ] Queue parser: all marker types, malformed lines, empty file, missing file
- [ ] Session scanner: find sessions, fuzzy match, missing dir
- [ ] Process detection: running/stuck/dead processes
- [ ] Status command: mock data → verify output format
- [ ] Queue command: fixture QUEUE.md → verify grouped output
- [ ] Stuck command: mock processes with varying runtimes → verify detection

---

## Phase 2: Queue Runner — `gsd run`

Port `gsd-queue-v5.sh` into a `gsd run` command. This is the engine that reads QUEUE.md and autonomously builds software by spawning opencode agents.

### `gsd run`
- Start the queue runner as a long-running process
- Read QUEUE.md, find pending entries, launch opencode processes
- **`--max-parallel N`** (default: 5) — max concurrent cross-project builds
- **`--max-retries N`** (default: 3) — retry flaky runs
- **`--dry-run`** — parse queue, show what would run, exit
- **`--once`** — process queue once and exit (don't loop)
- Writes PID to `/tmp/gsd-queue-pid`
- Logs to `/tmp/gsd-queue.log` (timestamped)

### `gsd add <project> <mode> [args]`
- Add a new entry to QUEUE.md without manual editing
- Validates project dir exists, mode is valid
- Appends formatted entry to queue file

### Lifecycle Modes (port from gsd-queue-v5.sh)

| Mode | Behavior |
|------|----------|
| `build-full` | For NEW projects only (no `.planning/`). Creates project via `new-project`, then builds all phases. **If `.planning/` exists, FAIL with error** — use `add-and-build` instead. This fixes the phantom completion bug. |
| `add-and-build` | Run `add-phase` with the description/requirements, then plan → execute → verify the new phase. Correct mode for adding features to existing projects. |
| `continue` | Run ONE phase cycle (plan → execute → verify) for the current phase |
| `continue-all` | Run ALL remaining phases to completion |
| `build-to-phase N` | Continue from current state, stop after Phase N verified |
| `run-command` | Escape hatch: pass args directly to `opencode run --command gsd-<args>` |

### Process Management
- Spawn opencode via `child_process.spawn` with stdin from `/dev/null`
- Track active processes by PID + project name
- **Same-project entries are SEQUENTIAL** — skip if project already has a running process
- **Cross-project entries PARALLELIZE** up to `--max-parallel`
- Capture stdout/stderr to per-job log files: `/tmp/gsd-{title}.log`

### State Machine (per lifecycle)
Read `.planning/STATE.md` + `.planning/ROADMAP.md` to determine:
- Current phase number and total phases
- Phase state: needs-plan, needs-execute, needs-verify, done
- Whether gap closure is needed (verify found issues → re-execute, max 3 cycles)

### Success Detection
- Compare git commit count before/after opencode run
- If new commits → success
- If same commits + few messages → "flaky" → retry
- If same commits + many messages → likely failed → mark failed after max retries

### Queue File Updates
- Atomically mark entries: pending → `🔨` (running) → `✅ DONE:` or `❌ FAIL:`
- Use file locking (flock or Node equivalent) to prevent corruption from parallel writes

### Requirement Path Resolution
1. Check project-local: `~/dev/punchlab/{project}/requirements/foo.md`
2. Fall back to global: `~/dev/punchlab/requirements/foo.md`
3. Rewrite to absolute path before passing to opencode
4. Log resolution for debugging: `📎 Resolved global requirement: ...`

### Process Lifecycle
- **Startup**: check `/tmp/gsd-queue-pid` for existing runner. Refuse if alive (unless `--force`)
- **Main loop**: scan queue → launch eligible entries → wait → rescan → repeat
- **Shutdown**: SIGTERM/SIGINT → wait for running processes (30s timeout) → kill remaining → clean PID file → mark running entries back to pending
- **Exit**: when queue is empty and all processes complete

### Opencode Invocation Format
```
opencode run --format default --title "<title>" --command "gsd-<command>" "<args>"
```
- Always `< /dev/null` for stdin
- Log stdout/stderr to `/tmp/gsd-{title}.log`
- Title format: `{project}-{command}-{sanitized-args}` (max 100 chars to avoid filename issues)

### Tests (Phase 2)
- [ ] Queue parser: pending/running/done/failed entries
- [ ] Queue writer: atomic updates, concurrent write safety
- [ ] State reader: parse STATE.md + ROADMAP.md fixtures
- [ ] Lifecycle engine: correct command sequences for each mode
- [ ] Process manager: spawn tracking, kill, PID cleanup (mocked `child_process`)
- [ ] Path resolver: local vs global requirement resolution
- [ ] build-full: MUST fail on existing projects (phantom completion fix)
- [ ] add-and-build: correct add-phase → build sequence

---

## Phase 3: TUI Dashboard — `gsd tui`

A full-screen terminal UI for monitoring the pipeline in real-time. Think `htop` for AI development.

### Layout
```
┌─────────────────────────────────────────────────────────┐
│  GSD Pipeline Dashboard              ▲ 2 running        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━         ⟳ 6 queued         │
│                                      ✓ 12 done          │
├──────────────────────────┬──────────────────────────────┤
│  RUNNING                 │  QUEUE                       │
│  ● project-a (12m)      │  1. router | quick fix       │
│    └ Planning task...    │  2. hub | add-and-build      │
│  ● project-b (5m)       │  3. resume-roast | quick     │
│    └ Reading req...      │  ...                         │
├──────────────────────────┴──────────────────────────────┤
│  LOG: project-a                                 [live]  │
│  > Planning task: fix asset routing...                  │
│  > Reading requirements/fix-asset...                    │
│  > Created .planning/quick/...                          │
├─────────────────────────────────────────────────────────┤
│  COMPLETED (last 5)                                     │
│  ✓ baby-predictor email-kv (3m ago)                    │
│  ✓ pet-portraits email-kv (5m ago)                     │
└─────────────────────────────────────────────────────────┘
  [q]uit  [↑↓]select  [enter]expand  [k]ill  [r]efresh
```

### Features
- **Auto-refresh** every 3 seconds (configurable: `--interval N`)
- **Running panel**: sessions with name, duration, last log line
- **Queue panel**: pending QUEUE.md entries
- **Log panel**: live tail of selected running session
- **Completed panel**: last 5 finished sessions with relative timestamps
- **Summary bar**: running/stuck/queued/done counts

### Keyboard
- `q` / `Ctrl-C` — quit, restore terminal
- `↑`/`↓` or `j`/`k` — select running session
- `Enter` — toggle full-screen log view
- `K` (shift) — kill selected session (with confirmation)
- `r` — force refresh
- `Tab` — cycle focus between panels

### Technical
- Use **Ink** (`ink` npm package) — React for CLIs, battle-tested, used by Vercel/Gatsby/Prisma. Much more stable than OpenTUI (which is pre-1.0 and requires Zig).
- React components for each panel, `useEffect` for refresh intervals
- `fs.watch` for live log updates
- Data from same core modules as other commands (session-scanner, queue-parser, etc.)
- Alternate screen buffer (`\x1b[?1049h/l`) to not pollute scrollback
- Responsive: adapt panels to terminal width/height

### Nice to Have
- **Queue progress bar**: `[3/10 ████░░░░░░]`
- **Completion flash**: highlight when a session finishes
- **`--compact` mode**: minimal view without log panel

### Tests (Phase 3)
- [ ] Component render tests with ink-testing-library
- [ ] Panel layout at different terminal sizes
- [ ] Keyboard interaction tests

---

## Public Repo Quality

### README.md
A README that makes developers want to use this:

1. **Hero section**: What GSD is, why it exists (one paragraph)
2. **Demo GIF/screenshot**: Show the TUI dashboard in action
3. **Quick start**: install, configure, run
4. **Commands reference**: every command with examples
5. **Architecture**: how the queue runner works, lifecycle modes explained
6. **How it works with opencode**: the relationship between GSD and the AI coding agent
7. **Contributing**: how to add commands, add lifecycle modes

### Code Quality
- JSDoc on all exported functions
- Interfaces/types are self-documenting (no `any`)
- Clean separation: commands → core → utils
- Each file < 300 lines (split if bigger)
- Conventional commit messages

### Git
- `.gitignore`: dist/, node_modules/, *.log
- `LICENSE`: MIT
- Clean history from the start

---

## Do NOT

- Do NOT keep the bash scripts as fallback — this is a full replacement
- Do NOT use OpenTUI (pre-1.0, needs Zig toolchain) — use Ink for TUI
- Do NOT use oclif, yargs, or heavy CLI frameworks
- Do NOT add a web UI, API server, or daemon mode beyond `gsd run`
- Do NOT change the QUEUE.md format — backward compatible
- Do NOT change the `opencode run` command interface
- Do NOT publish to npm yet — local install only
- Do NOT use `wrangler deploy` or any deployment commands
- Do NOT use `build-full` for existing projects — it must fail if `.planning/` exists (fixes phantom completion bug)
- Do NOT use `blessed` or `neo-blessed` for TUI — use Ink
- Do NOT create files with names longer than 100 characters
