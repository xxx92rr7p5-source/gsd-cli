# Architecture Patterns

**Domain:** Bash CLI tool
**Researched:** 2026-02-17

## Recommended Architecture

Single-file bash script with internal organization following Google's Shell Style Guide: constants at top, then helper functions, then subcommand functions, then `main()` at bottom, with `main "$@"` as the last line.

### File Structure

```
gsd                          # Single executable, no extension (Google style: "no extension for PATH executables")
```

### Internal Organization

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── Constants ──────────────────────────────────────────
readonly VERSION="0.1.0"
readonly QUEUE_FILE="$HOME/dev/punchlab/QUEUE.md"
readonly GSD_LOG_DIR="/tmp"
readonly STUCK_THRESHOLD_MIN=30

# ── Color Constants ────────────────────────────────────
# (defined based on TTY detection)

# ── Utility Functions ──────────────────────────────────
# err(), die(), check_deps(), setup_colors()

# ── Formatting Functions ──────────────────────────────
# format_duration(), print_header(), print_table_row()

# ── Data Functions ─────────────────────────────────────
# get_running_sessions(), get_queue_status(), check_stuck()

# ── Subcommand Functions ──────────────────────────────
# cmd_status(), cmd_queue(), cmd_stuck(), cmd_log(), cmd_tail()

# ── Main Dispatch ─────────────────────────────────────
# main() with case dispatch

main "$@"
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| Main dispatch | Parse global flags, route to subcommand | All subcommands |
| Color system | TTY detection, color constants, styled output | All output functions |
| Data layer | Call opencode/ps/stat, parse JSON, return data | Subcommand functions |
| Format layer | printf tables, duration formatting, headers | Subcommand functions |
| Error handling | stderr output, exit codes, trap cleanup | Everything |

### Data Flow

```
User input: gsd status --verbose
    │
    ▼
main() ──► parse global flags (--verbose, --json, --help)
    │
    ▼
case dispatch ──► cmd_status()
    │
    ├──► get_running_sessions()  ──► opencode session list | jq
    ├──► check_stuck()           ──► stat /tmp/gsd-*.log + ps
    ├──► get_queue_status()      ──► parse QUEUE.md
    │
    ▼
format output ──► printf with colors to stdout
```

## Patterns to Follow

### Pattern 1: Git-Style Subcommand Dispatch

**What:** Top-level `case` on `$1` to route to subcommand functions, with `shift` to pass remaining args.
**When:** Always. This is the standard pattern for multi-command CLIs.
**Why:** Used by git, docker, kubectl. Users already understand it. Simple, zero-dependency.

```bash
main() {
  # Parse global flags first
  local verbose=false
  local json_output=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose|-v)  verbose=true; shift ;;
      --json)        json_output=true; shift ;;
      --version)     printf '%s\n' "gsd ${VERSION}"; return 0 ;;
      --help|-h)     usage; return 0 ;;
      -*)            die "Unknown option: $1" ;;
      *)             break ;;  # First non-flag is the subcommand
    esac
  done

  local cmd="${1:-status}"  # Default to status
  shift || true

  case "${cmd}" in
    status)  cmd_status "$@" ;;
    queue)   cmd_queue "$@" ;;
    stuck)   cmd_stuck "$@" ;;
    log)     cmd_log "$@" ;;
    tail)    cmd_tail "$@" ;;
    help)    usage ;;
    *)       die "Unknown command: ${cmd}. Run 'gsd help' for usage." ;;
  esac
}
```

### Pattern 2: Per-Subcommand Flag Parsing with Manual Loop

**What:** Each subcommand parses its own flags with a `while/case` loop.
**When:** When subcommands have different flags. Preferred over `getopts` for long options.
**Why:** `getopts` doesn't support long options (`--kill`). Manual parsing is clearer for small flag sets.

```bash
cmd_stuck() {
  local kill_stuck=false
  local threshold="${STUCK_THRESHOLD_MIN}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --kill|-k)       kill_stuck=true; shift ;;
      --threshold|-t)  threshold="$2"; shift 2 ;;
      --help|-h)       stuck_usage; return 0 ;;
      -*)              die "Unknown option for 'stuck': $1" ;;
      *)               break ;;
    esac
  done

  # ... command implementation
}
```

### Pattern 3: TTY-Aware Color System

**What:** Define color constants that are empty strings when not outputting to a terminal.
**When:** Always. Respects piping, NO_COLOR, and `--json` mode.
**Why:** Avoids ANSI garbage in piped output. Follows NO_COLOR convention (https://no-color.org/).

```bash
setup_colors() {
  if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[0;33m'
    BLUE=$'\033[0;34m'
    MAGENTA=$'\033[0;35m'
    CYAN=$'\033[0;36m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    RESET=$'\033[0m'
  else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN=''
    BOLD='' DIM='' RESET=''
  fi
}
```

### Pattern 4: Structured Error Handling

**What:** `err()` for warnings, `die()` for fatal errors, `trap` for cleanup.
**When:** Always.

```bash
err() {
  printf '%s%s%s\n' "${RED}" "$*" "${RESET}" >&2
}

die() {
  err "Error: $*"
  exit 1
}

# Cleanup temp files on exit
cleanup() {
  [[ -n "${TMPFILE:-}" ]] && rm -f "${TMPFILE}"
}
trap cleanup EXIT
```

### Pattern 5: printf-Based Table Output

**What:** Use `printf` with fixed field widths for aligned column output.
**When:** Dashboard output like `gsd status`.
**Why:** No external dependency, exact control over alignment.

```bash
print_status_header() {
  printf '%s%-14s %-8s %-10s %-6s %s%s\n' \
    "${BOLD}" "SESSION" "STATUS" "DURATION" "PHASE" "NOTES" "${RESET}"
  printf '%s%s%s\n' "${DIM}" "$(printf '%.0s─' {1..60})" "${RESET}"
}

print_status_row() {
  local session="$1" status="$2" duration="$3" phase="$4" notes="$5"
  local color

  case "${status}" in
    running)  color="${GREEN}" ;;
    stuck)    color="${RED}" ;;
    queued)   color="${YELLOW}" ;;
    done)     color="${DIM}" ;;
    failed)   color="${RED}" ;;
    *)        color="${RESET}" ;;
  esac

  printf '%s%-14s %-8s %-10s %-6s %s%s\n' \
    "${color}" "${session}" "${status}" "${duration}" "${phase}" "${notes}" "${RESET}"
}
```

### Pattern 6: Safe jq with Error Handling

**What:** Always handle jq failures gracefully. Use `-e` for exit codes, `-r` for raw strings.
**When:** Every jq invocation.
**Why:** Malformed JSON shouldn't crash the tool.

```bash
# Safe JSON extraction with fallback
get_json_field() {
  local json="$1" field="$2" default="${3:-}"
  local result
  result=$(printf '%s' "${json}" | jq -r "${field}" 2>/dev/null) || result="${default}"
  [[ "${result}" == "null" ]] && result="${default}"
  printf '%s' "${result}"
}

# Parse array of sessions
parse_sessions() {
  local json
  json=$(opencode session list --json 2>/dev/null) || {
    err "Failed to get session list from opencode"
    return 1
  }

  # Validate it's valid JSON array
  if ! printf '%s' "${json}" | jq -e 'type == "array"' &>/dev/null; then
    err "Unexpected output from opencode session list"
    return 1
  fi

  printf '%s' "${json}"
}
```

### Pattern 7: Duration Formatting

**What:** Convert seconds to human-readable "2h 15m" format.
**When:** Any time display.

```bash
format_duration() {
  local seconds="$1"
  local hours=$((seconds / 3600))
  local minutes=$(( (seconds % 3600) / 60 ))

  if (( hours > 0 )); then
    printf '%dh %dm' "${hours}" "${minutes}"
  elif (( minutes > 0 )); then
    printf '%dm %ds' "${minutes}" $((seconds % 60))
  else
    printf '%ds' "${seconds}"
  fi
}
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Parsing ls Output
**What:** `for f in $(ls *.log)` or similar
**Why bad:** Breaks on spaces, globs, special characters. See BashPitfalls #1.
**Instead:** `for f in /tmp/gsd-*.log; do [[ -e "$f" ]] || continue; ...`

### Anti-Pattern 2: Unquoted Variables
**What:** `echo $foo` or `[ $var = value ]`
**Why bad:** Word splitting and glob expansion. The #1 bash bug. See BashPitfalls #2, #4, #14.
**Instead:** Always `"${var}"` in expansions, `[[ ]]` over `[ ]`.

### Anti-Pattern 3: Using echo for Formatted Output
**What:** `echo -e "\033[31mError\033[0m"`
**Why bad:** `echo -e` is not portable. echo behavior varies between shells.
**Instead:** `printf '%s%s%s\n' "${RED}" "Error" "${RESET}"` or use `$'\033[...'` syntax.

### Anti-Pattern 4: Pipes to While (Variable Scope)
**What:** `some_cmd | while read -r line; do count=$((count+1)); done`
**Why bad:** Pipe creates subshell. `count` changes don't propagate. See BashPitfalls #8.
**Instead:** `while read -r line; do ...; done < <(some_cmd)` (process substitution).

### Anti-Pattern 5: Command Substitution for Assignment + Local
**What:** `local var=$(some_cmd)` then checking `$?`
**Why bad:** `local` masks the exit code of the command substitution. See BashPitfalls #27.
**Instead:** `local var; var=$(some_cmd)` on separate lines.

### Anti-Pattern 6: cd Without Error Check
**What:** `cd /some/dir; do_stuff`
**Why bad:** If cd fails, do_stuff runs in the wrong directory. See BashPitfalls #19.
**Instead:** `cd /some/dir || die "Cannot cd to /some/dir"`

## Scalability Considerations

| Concern | Current (< 10 sessions) | Future (100+ sessions) |
|---------|------------------------|----------------------|
| Session listing | Single `opencode session list` call, fine | May need `--limit` or pagination |
| Log file scanning | Glob `/tmp/gsd-*.log`, fast | Could slow down; consider `find -maxdepth 1 -newer` |
| QUEUE.md parsing | Read entire file, fine | File won't grow huge; this is fine |
| Status output | Print all rows, fine | May need `--limit N` flag |
| jq processing | In-memory, fine | jq handles large JSON well |

## Sources

- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- BashPitfalls: https://mywiki.wooledge.org/BashPitfalls
- GNU Bash Manual (getopts, parameter expansion)
- NO_COLOR convention: https://no-color.org/
- jq 1.8 Manual: https://jqlang.github.io/jq/manual/
