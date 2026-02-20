# Migrate GSD CLI from Bash to TypeScript

## Problem

The gsd CLI is 1400+ lines of bash with heavy jq usage for JSON parsing, string manipulation hacks, and fragile process detection. It works but is:
- Nearly impossible to maintain or extend
- No type safety, no tests, no IDE support
- Error handling is brittle (set -euo pipefail + prayer)
- Adding features (like TUI) means bolting Node onto bash anyway

## Goal

Rewrite `gsd` as a TypeScript CLI that's functionally identical to the current bash version. Same commands, same output, same flags. Users shouldn't notice the change except things work better.

## Current Commands to Port

1. **`gsd status`** — Dashboard: running/stuck/queued/completed counts + details. Flags: `--json`, `--verbose`
2. **`gsd queue`** / **`gsd q`** — Pretty-print QUEUE.md with status markers
3. **`gsd stuck`** — Find hung opencode processes. Flags: `--kill`, `--threshold N`
4. **`gsd log <session>`** — Readable transcript of an opencode session (parses messages.jsonl)
5. **`gsd tail <session>`** — Live-follow a session's log
6. **`gsd projects`** / **`gsd p`** — List projects with git status
7. **Global flags**: `--verbose`/`-v`, `--json`, `--help`/`-h`, `--version`

## Requirements

### Must Have

- [ ] **TypeScript project in `gsd-cli/`** — `package.json`, `tsconfig.json`, compile to ESM. Entry point: `src/cli.ts`
- [ ] **Hashbang binary** — `bin/gsd` that's a thin shell script: `#!/usr/bin/env bash` + `exec node "$(dirname "$0")/../dist/cli.js" "$@"`. Symlink to `~/.local/bin/gsd` (same as current).
- [ ] **All 6 commands** ported with identical output format and flags
- [ ] **Process detection** — find running opencode sessions via `ps aux` parsing (same logic as bash version). Use `child_process.execSync` or similar.
- [ ] **Queue parsing** — read QUEUE.md directly, parse the `## project | mode | args` format, understand status markers (`✅ DONE:`, `❌ FAIL:`, `🔨`)
- [ ] **Session log reading** — scan `~/.local/share/opencode/sessions/` for session dirs, read `messages.jsonl`, format into readable transcript (same as current `cmd_log`)
- [ ] **Tail mode** — `fs.watch` on the session's messages.jsonl for live updates (replace bash `tail -f` + awk)
- [ ] **Stuck detection** — check process CPU time / activity duration, same threshold logic
- [ ] **Kill functionality** — `process.kill()` for stuck processes
- [ ] **Color output** — use `chalk` or similar. Respect `NO_COLOR` env var and `--json` flag
- [ ] **Argument parsing** — use a lightweight CLI parser. `commander`, `cac`, or even manual parsing is fine. Match current flag behavior exactly.
- [ ] **Project scanning** — scan `~/dev/punchlab/*/` for git repos, show branch + status (same as `cmd_projects`)
- [ ] **Config via env vars** — same as current: `GSD_QUEUE_FILE`, `GSD_LOG_DIR`, `GSD_STUCK_THRESHOLD`, `GSD_PROJECT_DIRS`
- [ ] **Zero-config install** — `pnpm install && pnpm build` then symlink `bin/gsd`

### Must Have (continued)

- [ ] **E2E test suite** — using `vitest` (or `node:test`). Tests must cover:
  - **`gsd status`**: mock opencode processes + session dirs + queue file → verify correct counts and output format. Test both TTY (colored) and `--json` modes.
  - **`gsd queue`**: create temp QUEUE.md with various markers (pending, `✅ DONE:`, `❌ FAIL:`, `🔨`) → verify correct parsing and display of each state.
  - **`gsd stuck`**: mock process list with varying runtimes → verify detection at threshold. Test `--threshold` flag. Test `--kill` actually sends signal (mock `process.kill`).
  - **`gsd log <session>`**: create temp session dir with real `messages.jsonl` fixtures (user/assistant/tool_call messages) → verify formatted output matches expected transcript.
  - **`gsd tail <session>`**: start tail, append lines to fixture jsonl, verify they appear in output. Test graceful exit.
  - **`gsd projects`**: create temp project dirs with git repos → verify branch/status detection.
  - **Edge cases**: empty queue, no running sessions, missing session dir, corrupted jsonl lines, very long session names, unicode in messages.
  - **Flag combinations**: `--verbose`, `--json`, `--help`, `--version` on each command.
  - **Regression**: capture current bash CLI output for each command as golden fixtures. The TS version must produce identical output (modulo whitespace normalization). Run `bash gsd status --json` etc. to generate fixtures before migration.
- [ ] **CI-friendly**: tests runnable via `pnpm test` with no manual setup. Use temp dirs for all fixtures, clean up after.

### Nice to Have

- [ ] **Fuzzy session matching** — `gsd log baby` matches `baby-predictor-quickemail-kv-...` (current bash version does partial matching, make it smarter)
- [ ] **Structured error messages** with exit codes matching current behavior
- [ ] **Tab completion** script generation (`gsd --completions bash/zsh/fish`)

## Technical Notes

- Keep deps minimal: `chalk` for colors, `commander` or `cac` for arg parsing. No heavy frameworks.
- The session log parser is the most complex part — messages.jsonl contains JSON lines with role/content/tool_calls. Current bash version uses jq to extract and format these. Port the exact same formatting logic.
- For `gsd tail`, use `fs.watch` + `readline` on the jsonl file. Much cleaner than the bash approach.
- Queue file path default: `~/dev/punchlab/QUEUE.md`
- Session dirs: `~/.local/share/opencode/sessions/*/` — each has `session.json` + `messages.jsonl`
- Project dirs default: `~/dev/punchlab/*/` (scan for dirs containing `.git`)
- Build with `tsc` to `dist/`. Keep it simple — no bundler needed.

## Known Bugs to Fix During Migration

- **Running count off-by-one**: `gsd status` shows "6 running" but only lists 5 sessions. The bash version likely double-counts a process (stale PID, grep matching itself, or the fallback `ps aux | grep opencode` count disagrees with the session-matching count). The TS version must ensure the displayed count EXACTLY matches the number of listed items. Single source of truth: count the array, don't compute separately.

## Do NOT

- Do NOT change the CLI interface — same commands, same flags, same output format
- Do NOT add a build-watch mode or dev server — this is a CLI tool, not a web app
- Do NOT use heavy frameworks (oclif, yargs with 50 plugins, etc.) — keep it lean
- Do NOT remove the ability to work without git (graceful degradation if git not found)
- Do NOT break the symlink at `~/.local/bin/gsd` — the new binary should work at the same path
