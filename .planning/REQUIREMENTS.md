# REQUIREMENTS — gsd-cli

## 1. CLI Framework

1.1. The tool SHALL be a single executable file named `gsd` (no extension).
1.2. The shebang line SHALL be `#!/usr/bin/env bash`.
1.3. The script SHALL set `set -euo pipefail` at the top.
1.4. The default command (no arguments) SHALL be `gsd status`.
1.5. Global flags SHALL be parsed before the subcommand: `-v`/`--verbose`, `--json`, `-h`/`--help`, `--version`.
1.6. Unknown global flags SHALL cause a fatal error with a reference to `gsd --help`.
1.7. Unknown subcommands SHALL cause a fatal error with a reference to `gsd --help`.
1.8. Each subcommand SHALL parse its own flags independently via `while`/`case` loops (not `getopts`).
1.9. `--` SHALL be accepted to terminate flag parsing (to support session names starting with `-`).
1.10. The tool SHALL work from any working directory (not tied to a specific project).
1.11. `gsd --version` SHALL print the version string in the format `gsd X.Y.Z` and exit 0.
1.12. `gsd --help` SHALL print a usage summary listing all commands, global options, and examples.
1.13. Each subcommand SHALL support `-h`/`--help` for subcommand-specific usage.

## 2. Commands

### 2.1. `gsd status` (Dashboard)

2.1.1. SHALL display currently running sessions with: session name, duration, and phase.
2.1.2. SHALL indicate whether each running session appears stuck (see §5 Stuck Detection).
2.1.3. SHALL display queued items from QUEUE.md.
2.1.4. SHALL display the last 5 completed sessions with pass/fail status.
2.1.5. SHALL complete in under 2 seconds.
2.1.6. Default (compact) view SHALL show a summary line with counts (N running, N stuck, N queued).
2.1.7. `--verbose` SHALL show the full table with all columns (PID, full paths, timestamps).
2.1.8. `--json` SHALL output the entire status as a single valid JSON object.
2.1.9. SHALL call `opencode session list` (once, cached) to obtain session data.
2.1.10. SHALL gracefully handle the case where opencode returns no sessions (empty state message).

### 2.2. `gsd queue`

2.2.1. SHALL read and parse `~/dev/punchlab/QUEUE.md`.
2.2.2. The queue file path SHALL be overridable via `GSD_QUEUE_FILE` environment variable.
2.2.3. SHALL parse markdown task lines: `- [ ] name: description` (unchecked) and `- [x] name: description` (checked).
2.2.4. SHALL detect section headers (`## In Progress`, `## Queued`, `## Done`, `## Failed`) to assign status.
2.2.5. SHALL display items grouped or color-coded by status.
2.2.6. SHALL print a helpful error if `QUEUE.md` is not found.
2.2.7. SHALL handle malformed lines gracefully (skip or display raw, never crash).
2.2.8. `q` SHALL be accepted as an alias for `queue`.

### 2.3. `gsd stuck`

2.3.1. SHALL find any opencode run that has been running longer than N minutes (default: 30).
2.3.2. The threshold SHALL be configurable via `--threshold N` / `-t N` flag.
2.3.3. The default threshold SHALL be overridable via `GSD_STUCK_THRESHOLD` environment variable.
2.3.4. SHALL display for each stuck process: PID, session name, runtime duration, and last log activity time.
2.3.5. `--kill` / `-k` SHALL kill all detected stuck processes.
2.3.6. Before killing, SHALL print what will be killed and require confirmation (unless `--force` / `-f` is also passed).
2.3.7. SHALL verify a PID is still alive before attempting to kill it.
2.3.8. SHALL handle stale PID files (process already exited) gracefully.
2.3.9. SHALL print a message when no stuck processes are found.

### 2.4. `gsd log <session>`

2.4.1. SHALL require a session name as a positional argument.
2.4.2. SHALL invoke `opencode export` under the hood to retrieve session data.
2.4.3. SHALL strip raw JSON and present assistant messages and tool results readably.
2.4.4. SHALL print a fatal error if no session name is provided.
2.4.5. SHALL print a helpful error if the session is not found.

### 2.5. `gsd tail <session>`

2.5.1. SHALL require a session name as a positional argument.
2.5.2. SHALL live-follow a running session's output (analogous to `tail -f`).
2.5.3. SHALL use file polling or `inotifywait` (if available) to watch `/tmp/gsd-<session>.log`.
2.5.4. SHALL exit cleanly on `Ctrl-C` (SIGINT) with trap cleanup.
2.5.5. SHALL print an error if the session is not running or the log file does not exist.

## 3. Output Formatting

### 3.1. Colors

3.1.1. SHALL use ANSI escape codes via `$'\033[...]'` syntax (not `tput`, not `echo -e`).
3.1.2. SHALL disable colors when stdout is not a TTY (`[[ -t 1 ]]` is false).
3.1.3. SHALL disable colors when `NO_COLOR` environment variable is set (per https://no-color.org/).
3.1.4. SHALL disable colors when `TERM=dumb`.
3.1.5. SHALL disable colors when `--json` flag is active.
3.1.6. Color semantics SHALL be:
  - Green: running/success/done
  - Red: stuck/failed/error
  - Yellow: warning/queued
  - Blue: headers/labels
  - Cyan: metadata/timestamps
  - Dim: deemphasized/old items, separators
  - Bold: emphasis/active items
  - Bold+Red: critical (stuck + long duration, kill warnings)

### 3.2. Tables

3.2.1. SHALL use `printf` with fixed field widths for column alignment.
3.2.2. Session names longer than the column width SHALL be truncated with an ellipsis (`…`).
3.2.3. Table headers SHALL be bold.
3.2.4. Table separators SHALL use the `─` character, styled dim.

### 3.3. Durations

3.3.1. SHALL format durations as human-readable strings: `Xh Ym`, `Xm Ys`, or `Xs`.
3.3.2. SHALL NOT display raw seconds to the user (except in `--verbose` or `--json` mode).

### 3.4. Errors and Warnings

3.4.1. All errors SHALL be printed to stderr.
3.4.2. Error messages SHALL be prefixed with `Error:` and styled red.
3.4.3. Warning messages SHALL be prefixed with `Warning:` and styled yellow.
3.4.4. Debug messages SHALL only appear when `--verbose` is active, prefixed with `[debug]`, styled dim, to stderr.

### 3.5. JSON Output

3.5.1. `--json` SHALL output valid, parseable JSON to stdout.
3.5.2. JSON output SHALL include a `timestamp` field (ISO 8601).
3.5.3. JSON output SHALL include structured data matching the human-readable output.
3.5.4. Errors in `--json` mode SHALL still go to stderr (not mixed into JSON).

## 4. Exit Codes

4.1. `0` SHALL indicate success.
4.2. `1` SHALL indicate a runtime error (command failed, opencode error, etc.).
4.3. `2` SHALL indicate a usage error (unknown command, missing argument, bad flag).

## 5. Stuck Detection

5.1. A process SHALL be considered stuck when BOTH conditions are true:
  - Running longer than the threshold (default 30 minutes).
  - The corresponding log file (`/tmp/gsd-<session>.log`) has not been modified in the last 5 minutes.
5.2. Stuck detection SHALL read PID files from `/tmp/gsd-*-pid`.
5.3. SHALL verify PID is alive via `kill -0` before reporting.
5.4. SHALL compute runtime from `ps -o etimes=`.
5.5. SHALL compute log staleness from `stat -c %Y` on the log file.
5.6. SHALL handle missing log files (treat as potentially stuck if process is long-running).
5.7. `gsd status` SHALL integrate stuck detection, marking stuck sessions in the dashboard.
5.8. `gsd stuck --kill` SHALL send SIGTERM first; SHALL NOT send SIGKILL automatically.
5.9. SHALL clean up stale PID files (PID file exists but process is dead) silently on detection.

## 6. Data Sources

6.1. Session data SHALL come from `opencode session list --json`.
6.2. Session export data SHALL come from `opencode export <session>`.
6.3. Queue data SHALL come from `~/dev/punchlab/QUEUE.md` (overridable via `GSD_QUEUE_FILE`).
6.4. Process data SHALL come from PID files at `/tmp/gsd-*-pid`.
6.5. Log files SHALL be at `/tmp/gsd-*.log`.
6.6. All external command output SHALL be validated (valid JSON, file exists) before parsing.

## 7. Dependencies

7.1. SHALL require bash 5.0 or later.
7.2. SHALL require `jq` (1.6+) as the only non-standard external dependency.
7.3. SHALL require `opencode` to be installed and in PATH.
7.4. SHALL use only standard Unix utilities beyond jq: `ps`, `stat`, `date`, `kill`, `column` (optional).
7.5. SHALL check for `jq` and `opencode` at startup and fail fast with install instructions if missing.

## 8. Installation

8.1. SHALL provide an `install.sh` script that symlinks `gsd` into `~/.local/bin/`.
8.2. `install.sh` SHALL create `~/.local/bin/` if it does not exist.
8.3. `install.sh` SHALL warn if `~/.local/bin` is not in `PATH`, with instructions to add it.
8.4. `install.sh` SHALL verify the symlink works after creation.
8.5. The tool SHALL also be usable without installation by running `./gsd` directly from the repo.
8.6. The tool SHALL also be installable by adding the repo directory to `PATH`.
8.7. The executable SHALL have no file extension (named `gsd`, not `gsd.sh`).
8.8. The executable SHALL be `chmod +x`.

## 9. Configuration

9.1. SHALL NOT require any configuration files.
9.2. All overrides SHALL be via environment variables:
  - `GSD_QUEUE_FILE` — path to QUEUE.md (default: `~/dev/punchlab/QUEUE.md`)
  - `GSD_LOG_DIR` — directory for log files (default: `/tmp`)
  - `GSD_STUCK_THRESHOLD` — stuck threshold in minutes (default: `30`)
  - `NO_COLOR` — disable colors (standard convention)

## 10. Code Quality

10.1. SHALL follow Google Shell Style Guide conventions (constants at top, `main()` at bottom, `main "$@"` as last line).
10.2. ALL variable expansions SHALL be quoted (`"${var}"`).
10.3. SHALL use `[[ ]]` over `[ ]` for conditionals.
10.4. SHALL use process substitution (`< <(cmd)`) instead of pipe-to-while (`cmd | while`).
10.5. SHALL separate `local` declarations from command substitutions (`local var; var=$(cmd)`).
10.6. SHALL use `printf` for all formatted output (never `echo -e`).
10.7. SHALL use a `trap cleanup EXIT` handler for any temp files.
10.8. SHALL use `readonly` for constants.
10.9. JSON parsing SHALL handle malformed input gracefully with fallback messages.
10.10. SHALL minimize external process invocations — cache `opencode` output, use bash builtins over external commands where possible.
