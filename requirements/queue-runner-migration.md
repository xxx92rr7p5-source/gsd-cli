# Migrate Queue Runner into GSD CLI (TypeScript)

## Problem

The GSD pipeline has two separate pieces:
1. **gsd-cli** — a 1400-line bash script for monitoring (`gsd status`, `gsd queue`, `gsd stuck`, `gsd log`, `gsd tail`)
2. **gsd-queue-v5.sh** — a 670-line bash script that actually runs the build pipeline

Both are bash, both are fragile, and they should be one unified TypeScript CLI. The current bash queue runner has recurring bugs: path resolution issues (requirements files not found), integer expression errors, race conditions with multiple instances, and no proper error handling.

**Vision:** This CLI becomes a public GitHub showcase of how an AI-controlled autonomous developer team works — fully open source, well-typed, well-tested, well-documented. The kind of thing developers star because it's genuinely useful AND demonstrates the future of software development.

## Goal

Merge the gsd-cli (monitoring) and gsd-queue-v5.sh (execution) into a single TypeScript CLI. Same commands the monitoring CLI has today, plus a new `gsd run` command that replaces the bash queue runner. Everything typed, tested, documented.

## Architecture

```
gsd-cli/
├── src/
│   ├── cli.ts                  # Entry point, arg parsing (commander/cac)
│   ├── commands/
│   │   ├── status.ts           # gsd status — dashboard
│   │   ├── queue.ts            # gsd queue — display queue
│   │   ├── run.ts              # gsd run — the queue runner (NEW)
│   │   ├── stuck.ts            # gsd stuck — find/kill hung processes
│   │   ├── log.ts              # gsd log <session> — transcript
│   │   ├── tail.ts             # gsd tail <session> — live follow
│   │   └── projects.ts         # gsd projects — list repos
│   ├── core/
│   │   ├── queue-parser.ts     # Parse QUEUE.md format
│   │   ├── queue-writer.ts     # Atomic QUEUE.md updates (lock + write)
│   │   ├── process-manager.ts  # Spawn/track/kill opencode processes
│   │   ├── session-scanner.ts  # Find/read opencode session dirs
│   │   ├── project-scanner.ts  # Scan project dirs, git status
│   │   ├── state-reader.ts     # Parse STATE.md + ROADMAP.md
│   │   └── config.ts           # Env vars, defaults, paths
│   ├── lifecycles/
│   │   ├── build-full.ts       # new-project → all phases
│   │   ├── build-to-phase.ts   # continue to specific phase
│   │   ├── add-and-build.ts    # add-phase → plan → execute → verify
│   │   ├── continue.ts         # one phase cycle
│   │   ├── continue-all.ts     # all remaining phases
│   │   └── run-command.ts      # escape hatch: raw GSD command
│   ├── utils/
│   │   ├── colors.ts           # Chalk wrapper, NO_COLOR support
│   │   ├── logger.ts           # Timestamped logging to file + stdout
│   │   ├── paths.ts            # Path resolution (local → global fallback)
│   │   └── format.ts           # Duration, tables, etc.
│   └── types.ts                # All interfaces/types
├── tests/
│   ├── queue-parser.test.ts
│   ├── process-manager.test.ts
│   ├── state-reader.test.ts
│   ├── lifecycles.test.ts
│   └── fixtures/
│       ├── queue-samples.md
│       ├── state-samples.md
│       └── session-samples/
├── bin/gsd                     # Shell shim → node dist/cli.js
├── package.json
├── tsconfig.json
└── README.md                   # Public-facing docs
```

## Requirements

### Must Have — Monitoring Commands (Port from Bash)

- [ ] **`gsd status`** — Dashboard showing running/stuck/queued/completed. Flags: `--json`, `--verbose`. Output format identical to current bash version.
- [ ] **`gsd queue`** / **`gsd q`** — Pretty-print QUEUE.md with status grouping (pending, running, done, failed). Parse v5 format: `## project | mode [| args]` with status markers (`✅ DONE:`, `❌ FAIL:`, `🔨`).
- [ ] **`gsd stuck`** — Find hung opencode processes by runtime + log staleness. Flags: `--kill`, `--force`, `--threshold N`. Kill sends SIGTERM, cleans PID files.
- [ ] **`gsd log <session>`** — Readable transcript from session's messages.jsonl. Fuzzy session name matching.
- [ ] **`gsd tail <session>`** — Live-follow session log via `fs.watch` + readline.
- [ ] **`gsd projects`** / **`gsd p`** — List projects with git branch + status.
- [ ] **Global flags**: `--verbose`/`-v`, `--json`, `--help`/`-h`, `--version`

### Must Have — Queue Runner (`gsd run`) — Port from gsd-queue-v5.sh

- [ ] **`gsd run`** — Start the queue runner. Reads QUEUE.md, launches opencode processes, manages lifecycle. Replaces `gsd-queue-v5.sh` entirely.
  - Writes PID to `/tmp/gsd-queue-pid`
  - Logs to `/tmp/gsd-queue.log` (timestamped)
  - `--max-parallel N` flag (default: 5)
  - `--max-retries N` flag (default: 3)
  - `--dry-run` flag — parse queue, show what would run, don't launch anything

- [ ] **Queue parsing** — Parse v5 format entries. Each entry: `## [status] project | mode [| args]`. Status markers: `✅ DONE:`, `❌ FAIL:`, `🔨` (running). Entries without markers are pending.

- [ ] **Lifecycle modes** — All 6 modes from v5:
  - `build-full` — new-project → all phases to completion (plan → execute → verify per phase)
  - `build-to-phase N` — continue from current state, stop after Phase N
  - `add-and-build` — add-phase then plan → execute → verify the new phase
  - `continue` — run ONE phase cycle
  - `continue-all` — run ALL remaining phases
  - `run-command` — escape hatch: run exactly the GSD command specified in args

- [ ] **Process management** — Spawn opencode processes via `child_process.spawn`. Track PIDs. Same-project items are SEQUENTIAL (skip if project already running). Cross-project items PARALLELIZE up to MAX_PARALLEL.

- [ ] **Success detection** — After each opencode run, check for new git commits (same logic as bash: compare commit count before/after). Retry on failure up to MAX_RETRIES. Detect "flaky" runs (few messages = likely errored out).

- [ ] **State machine** — For lifecycle modes, read STATE.md + ROADMAP.md to determine:
  - Current phase number
  - Whether plan exists for current phase
  - Whether execution is needed
  - Whether verification is needed
  - What the next phase is

- [ ] **Gap closure** — After execute-phase, if verify finds issues, re-run execute (up to MAX_GAP_CYCLES per phase).

- [ ] **Queue file updates** — Atomically mark entries as running (`🔨`), done (`✅ DONE:`), or failed (`❌ FAIL:`) in QUEUE.md. Use file locking (flock or equivalent) to prevent corruption.

- [ ] **Requirement path resolution** — When args reference `requirements/foo.md`:
  1. Check project-local path first (`~/dev/punchlab/{project}/requirements/foo.md`)
  2. Fall back to global path (`~/dev/punchlab/requirements/foo.md`)
  3. Rewrite to absolute path before passing to opencode
  4. Log the resolution for debugging

- [ ] **Graceful shutdown** — Handle SIGTERM/SIGINT: wait for running opencode processes to finish (or kill them after timeout), clean up PID file, mark running entries back to pending.

- [ ] **Single instance** — Check `/tmp/gsd-queue-pid` on start. If another runner is alive, refuse to start (with `--force` to override).

### Must Have — Testing

- [ ] **Unit tests** for queue parser, state reader, path resolver, success detection
- [ ] **Integration tests** with fixture QUEUE.md + STATE.md + ROADMAP.md files
- [ ] **Process manager tests** with mocked `child_process.spawn`
- [ ] **Lifecycle tests** verifying correct command sequences for each mode
- [ ] All tests via `pnpm test` (vitest)

### Must Have — Project Setup

- [ ] **TypeScript** with strict mode, ESM output
- [ ] **Dependencies**: minimal — `chalk` (colors), `commander` or `cac` (args), `vitest` (tests). No heavy frameworks.
- [ ] **Build**: `tsc` → `dist/`. No bundler.
- [ ] **bin/gsd**: Shell shim that runs `node dist/cli.js`. Symlink to `~/.local/bin/gsd`.
- [ ] **install.sh**: Build + symlink in one step

### Must Have — Public Repo Quality

- [ ] **README.md** — Clear explanation of what GSD is, how the queue runner works, architecture diagram, usage examples. Written for developers who want to understand autonomous AI development pipelines.
- [ ] **Inline documentation** — JSDoc on all public functions. Types are self-documenting.
- [ ] **Clean git history** — Conventional commits, no junk.

### Nice to Have

- [ ] **`gsd add <project> <mode> [args]`** — Add entry to QUEUE.md without editing manually
- [ ] **`gsd pause` / `gsd resume`** — Pause/resume the queue runner gracefully
- [ ] **Webhook/callback** on build completion (for notifications)
- [ ] **Metrics** — track build times, success rates, retry counts over time (JSON log)

## Technical Notes

- The queue runner is the most complex part. Port `gsd-queue-v5.sh` faithfully but improve:
  - Proper TypeScript types for queue entries, lifecycle state, process tracking
  - Real error handling instead of `|| true` everywhere
  - Structured logging (JSON for `--json`, human-readable default)
  - Clean separation of concerns (parser, process manager, lifecycle engine)
- `opencode run` invocation: `opencode run --format default --title "<title>" --command "gsd-<command>" "<args>"`
  - Use `--` separator only when args contain `--` flags
  - Always pipe stdin from `/dev/null`
  - Capture stdout/stderr to log file
- The `run_gsd()` function in bash is ~80 lines. In TypeScript it should be a clean async function with proper error types.
- Session dirs: `~/.local/share/opencode/sessions/*/` — each has `session.json` + `messages.jsonl`
- Queue file: `~/dev/punchlab/QUEUE.md` (configurable via `GSD_QUEUE_FILE`)
- Project dirs: `~/dev/punchlab/*/` (configurable via `GSD_PROJECT_DIRS`)

## Do NOT

- Do NOT keep the bash version as fallback — this is a full replacement
- Do NOT add a web UI or API server — this is a CLI tool
- Do NOT use heavy frameworks (oclif, nest, etc.)
- Do NOT change the QUEUE.md format — maintain backward compatibility
- Do NOT change the opencode command interface — same `opencode run` invocations
- Do NOT use `wrangler deploy` or any deployment commands
- Do NOT add package to npm yet — local install only for now
