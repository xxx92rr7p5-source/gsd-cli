# GSD CLI

## What This Is

A unified TypeScript CLI that monitors and drives an autonomous AI development pipeline. It replaces two fragile bash scripts (1400-line monitoring CLI + 670-line queue runner) with a single, well-typed tool: `gsd status` shows what's running, `gsd run` processes a build queue by spawning AI coding agents, and `gsd tui` provides a live terminal dashboard. Built for developers running opencode-based AI pipelines.

## Core Value

Instant pipeline visibility and reliable autonomous execution — one command to see everything, one command to run everything, zero manual babysitting.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Port all 6 monitoring commands (status, queue, stuck, log, tail, projects) with identical output
- [ ] Build queue runner (`gsd run`) that reads QUEUE.md and autonomously spawns opencode agents
- [ ] Implement all 6 lifecycle modes (build-full, add-and-build, continue, continue-all, build-to-phase, run-command)
- [ ] Process management: spawn/track/kill opencode processes, same-project sequential, cross-project parallel
- [ ] State machine: read STATE.md + ROADMAP.md to determine phase state and next actions
- [ ] Queue file atomic updates with file locking
- [ ] Success detection via git commit count comparison
- [ ] Graceful shutdown with signal handling
- [ ] Fix phantom completion bug: `build-full` must fail if `.planning/` exists
- [ ] Fix running count off-by-one bug
- [ ] TUI dashboard (`gsd tui`) with live-updating panels using Ink
- [ ] `gsd add` command for queue entry creation
- [ ] Comprehensive test suite (vitest) covering parsers, lifecycle engine, process manager
- [ ] Public repo quality: README, JSDoc, clean git history, MIT license

### Out of Scope

- Web UI or API server — this is a CLI tool
- npm publish — local install only for now
- OpenTUI for TUI — use Ink instead (OpenTUI is pre-1.0, requires Zig)
- oclif/yargs/heavy frameworks — keep it lean (commander + chalk)
- Keeping bash scripts as fallback — this is a full replacement
- Daemon mode beyond `gsd run`
- Changing QUEUE.md format or opencode command interface

## Context

GSD (Get Shit Done) is an autonomous AI development pipeline. It queues work, spawns AI coding agents (via opencode), manages lifecycles (plan → execute → verify), and monitors everything from a terminal. Today it's split across two bash scripts that are fragile, untestable, and hard to extend.

The existing bash `gsd` script at `~/dev/punchlab/gsd-cli/gsd` (1415 lines) handles monitoring. The queue runner at `~/dev/punchlab/gsd-queue-v5.sh` (667 lines) handles execution. Both have recurring bugs: path resolution issues, integer expression errors, race conditions, phantom build completions (see post-mortem), and an off-by-one running count bug.

Key data paths:
- Queue file: `~/dev/punchlab/QUEUE.md` (configurable via `$GSD_QUEUE_FILE`)
- Session dirs: `~/.local/share/opencode/sessions/*/`
- Pipeline logs: `/tmp/gsd-*.log`
- PID files: `/tmp/gsd-*-pid`
- Project dirs: `~/dev/punchlab/*/` (configurable via `$GSD_PROJECT_DIRS`)

The vision is a public GitHub showcase of how an AI-controlled autonomous developer team works — well-typed, well-tested, well-documented. The kind of thing developers star because it's genuinely useful AND demonstrates the future of software development.

## Constraints

- **Tech stack**: TypeScript 5.x (strict, ESM, ES2022), commander, chalk, vitest, Ink for TUI. No heavy frameworks.
- **Build**: `tsc` → `dist/`. No bundler.
- **Compatibility**: Same CLI interface as current bash version — same commands, same flags, same output format. Users shouldn't notice the change.
- **Backward compatible**: QUEUE.md format unchanged, opencode command interface unchanged.
- **Performance**: `gsd status` must complete in < 2 seconds.
- **Installation**: `pnpm install && pnpm build`, then `ln -sf $(pwd)/bin/gsd ~/.local/bin/gsd`.
- **File size**: Each source file < 300 lines.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| TypeScript over continued bash | Type safety, testability, IDE support, extensibility for TUI | — Pending |
| Ink for TUI (not OpenTUI) | OpenTUI is pre-1.0 and requires Zig; Ink is battle-tested (Vercel, Gatsby, Prisma) | — Pending |
| commander for CLI parsing | Mature, lightweight, well-documented — avoids heavy frameworks | — Pending |
| Single CLI replacing both scripts | Unified codebase, shared core modules, one install | — Pending |
| `build-full` must fail on existing projects | Fixes phantom completion bug — forces correct mode selection | — Pending |
| ESM output with tsc (no bundler) | Simplicity — no webpack/esbuild complexity for a CLI tool | — Pending |

---
*Last updated: 2026-02-20 after initialization*
