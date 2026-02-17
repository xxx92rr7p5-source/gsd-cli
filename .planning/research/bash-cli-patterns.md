# Bash CLI Development Patterns for gsd-cli

**Researched:** 2026-02-17
**Confidence:** HIGH (verified against GNU Bash Manual, Google Shell Style Guide, jq Manual, BashPitfalls)
**Target system:** bash 5.2.21, jq 1.7, Linux (util-linux 2.39.3)

---

## 1. Argument Parsing: Subcommands + Flags

### The Verdict: Manual `case`/`while` for Everything

**Don't use `getopts` or `getopt`.** For a tool with subcommands + long options (`--verbose`, `--kill`, `--json`), manual parsing with `while`/`case` is the right pattern. Here's why:

| Approach | Long options | Subcommands | POSIX | Subprocess |
|----------|-------------|-------------|-------|------------|
| `getopts` (builtin) | NO (`-v` only) | Manual | Yes | No |
| `getopt` (external) | Yes (GNU only) | Manual | No (GNU ext) | Yes |
| Manual `while`/`case` | Yes | Yes | Yes | No |

`getopts` can't do `--verbose`. `getopt` varies between GNU and BSD. Manual parsing is 15 lines of code and handles everything we need.

### Complete Argument Parsing Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly VERSION="0.1.0"

# ── Global state set by flag parsing ──
VERBOSE=false
JSON_OUTPUT=false

usage() {
  cat <<'EOF'
Usage: gsd [OPTIONS] <command> [ARGS]

Pipeline monitoring for GSD runs.

Commands:
  status          Show pipeline dashboard (default)
  queue           Show QUEUE.md status
  stuck           Find stuck processes
  log <session>   Show session log
  tail <session>  Live-follow session output

Options:
  -v, --verbose   Show detailed output
  --json          Output as JSON
  -h, --help      Show this help
  --version       Show version

Examples:
  gsd                    # Same as 'gsd status'
  gsd stuck --kill       # Find and kill stuck processes
  gsd log my-session     # View session log
EOF
}

main() {
  # Phase 1: Parse global flags (before subcommand)
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose)  VERBOSE=true; shift ;;
      --json)        JSON_OUTPUT=true; shift ;;
      --version)     printf 'gsd %s\n' "${VERSION}"; return 0 ;;
      -h|--help)     usage; return 0 ;;
      --)            shift; break ;;      # End of global flags
      -*)            die "Unknown option: $1. See 'gsd --help'." ;;
      *)             break ;;             # First non-flag = subcommand
    esac
  done

  # Phase 2: Extract subcommand (default: status)
  local cmd="${1:-status}"
  shift 2>/dev/null || true

  # Phase 3: Dispatch to subcommand function
  case "${cmd}" in
    status)   cmd_status "$@" ;;
    queue|q)  cmd_queue "$@" ;;
    stuck)    cmd_stuck "$@" ;;
    log)      cmd_log "$@" ;;
    tail)     cmd_tail "$@" ;;
    help)     usage ;;
    *)        die "Unknown command: '${cmd}'. See 'gsd --help'." ;;
  esac
}
```

### Per-Subcommand Flag Parsing

Each subcommand parses its own flags independently:

```bash
cmd_stuck() {
  local kill_mode=false
  local threshold=30

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -k|--kill)       kill_mode=true; shift ;;
      -t|--threshold)
        [[ -n "${2:-}" ]] || die "--threshold requires a value"
        threshold="$2"; shift 2 ;;
      -h|--help)       stuck_usage; return 0 ;;
      -*)              die "Unknown option for 'stuck': $1" ;;
      *)               break ;;
    esac
  done

  # Implementation here, using ${kill_mode} and ${threshold}
  find_stuck_processes "${threshold}" "${kill_mode}"
}

cmd_log() {
  # Positional argument: session name (required)
  [[ $# -ge 1 ]] || die "Usage: gsd log <session-name>"
  local session="$1"; shift

  # Optional flags after positional arg
  local raw=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --raw)  raw=true; shift ;;
      -*)     die "Unknown option for 'log': $1" ;;
      *)      die "Unexpected argument: $1" ;;
    esac
  done

  show_session_log "${session}" "${raw}"
}
```

### Key Details

- **`shift 2>/dev/null || true`** after extracting the subcommand: handles the case where there's no subcommand (defaults to `status`) without `set -e` killing the script.
- **`break` on first non-flag**: stops global flag parsing, everything after is for the subcommand.
- **`--` support**: conventional way to say "no more flags" (useful if a session name starts with `-`).
- **Alias support**: `queue|q)` allows short aliases.

---

## 2. Terminal Colors in Bash

### Color Constants with TTY Detection

```bash
setup_colors() {
  # Disable colors if:
  # 1. stdout is not a terminal (piping/redirecting)
  # 2. NO_COLOR env var is set (https://no-color.org/)
  # 3. TERM is "dumb" (Emacs shell, CI environments)
  # 4. --json mode is active
  if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-}" != "dumb" ]] && [[ "${JSON_OUTPUT}" == "false" ]]; then
    # Regular colors
    RED=$'\033[31m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    BLUE=$'\033[34m'
    MAGENTA=$'\033[35m'
    CYAN=$'\033[36m'
    WHITE=$'\033[37m'

    # Styles
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    ITALIC=$'\033[3m'
    UNDERLINE=$'\033[4m'
    RESET=$'\033[0m'

    # Compound styles (for convenience)
    HEADER="${BOLD}${BLUE}"
    SUCCESS="${GREEN}"
    WARNING="${YELLOW}"
    ERROR="${BOLD}${RED}"
    INFO="${CYAN}"
    MUTED="${DIM}"
  else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
    BOLD='' DIM='' ITALIC='' UNDERLINE='' RESET=''
    HEADER='' SUCCESS='' WARNING='' ERROR='' INFO='' MUTED=''
  fi
}
```

### Why `$'\033[...'` Instead of `tput`

| Approach | Speed | Portability | Readability |
|----------|-------|-------------|-------------|
| `$'\033[31m'` | Instant (string literal) | Works everywhere with VT100+ | Clear what color it is |
| `$(tput setaf 1)` | Subprocess per color | More "correct" | Requires lookup table |
| `\e[31m` in echo | Requires `echo -e` | Non-portable | Fragile |

Use `$'\033[...'` — it's a bash string literal (no subprocess), and every modern terminal supports ANSI codes.

### Color Semantics for gsd-cli

| Color | Usage | When |
|-------|-------|------|
| `GREEN` | Success, running | Session running normally, task done |
| `RED` | Error, stuck | Session stuck, task failed, errors |
| `YELLOW` | Warning, queued | Queued items, long-running but not stuck |
| `BLUE` | Headers, info | Section headers, labels |
| `CYAN` | Info, metadata | Timestamps, session IDs |
| `DIM` | Deemphasize | Completed/old items, separator lines |
| `BOLD` | Emphasis | Active/important items, headers |
| `BOLD RED` | Critical | Stuck + long duration, kill warnings |

### Reusable Output Functions

```bash
# Log-level output functions
msg()     { printf '%s\n' "$*"; }
info()    { printf '%s%s%s\n' "${INFO}" "$*" "${RESET}"; }
success() { printf '%s%s%s\n' "${SUCCESS}" "$*" "${RESET}"; }
warn()    { printf '%s%s%s\n' "${WARNING}" "Warning: $*" "${RESET}" >&2; }
err()     { printf '%s%s%s\n' "${ERROR}" "Error: $*" "${RESET}" >&2; }
die()     { err "$*"; exit 1; }

# Labeled output (for status dashboard)
label() {
  local label="$1" value="$2"
  printf '%s%-12s%s %s\n' "${DIM}" "${label}:" "${RESET}" "${value}"
}

# Section header
header() {
  printf '\n%s%s%s\n' "${HEADER}" "$*" "${RESET}"
  printf '%s%s%s\n' "${DIM}" "$(printf '%.0s─' $(seq 1 ${#1}))" "${RESET}"
}
```

### Checking stderr TTY Separately

Colors to stderr need separate TTY check:

```bash
# For error messages: check fd 2 (stderr), not fd 1 (stdout)
# This matters when stdout is piped but stderr still goes to terminal
# However, for simplicity in gsd-cli, we use the same color set for both.
# stderr messages will lose color when stdout is piped, which is acceptable.
```

---

## 3. Table / Column Formatting

### printf-Based Tables (Recommended)

For `gsd status` dashboard output with fixed-width columns:

```bash
# ── Status Dashboard Example Output ──
# 
# ◆ Pipeline Status
# ──────────────────────────────────────────────────────────
#  SESSION        STATUS     DURATION   PHASE   NOTES
# ──────────────────────────────────────────────────────────
#  fix-auth       running    12m 30s    build   
#  add-tests      running    45m 12s    plan    ⚠ possibly stuck
#  refactor-api   queued     —          —       3rd in queue
#  update-docs    done       8m 45s     —       ✓ passed
#  fix-typo       failed     2m 10s     test    ✗ exit code 1
# ──────────────────────────────────────────────────────────

print_status_table() {
  local sessions_json="$1"

  header "Pipeline Status"

  # Header row
  printf ' %s%-15s %-10s %-10s %-7s %s%s\n' \
    "${BOLD}" "SESSION" "STATUS" "DURATION" "PHASE" "NOTES" "${RESET}"

  # Separator
  printf ' %s%s%s\n' "${DIM}" "$(printf '%.0s─' {1..58})" "${RESET}"

  # Data rows (from jq-parsed JSON)
  local name status duration phase notes color icon

  while IFS=$'\t' read -r name status duration phase notes; do
    case "${status}" in
      running) color="${GREEN}";  icon=" " ;;
      stuck)   color="${RED}";    icon="!" ;;
      queued)  color="${YELLOW}"; icon="~" ;;
      done)    color="${DIM}";    icon="✓" ;;
      failed)  color="${RED}";    icon="✗" ;;
      *)       color="${RESET}";  icon=" " ;;
    esac

    printf ' %s%-15s %-10s %-10s %-7s %s%s\n' \
      "${color}" "${name}" "${status}" "${duration}" "${phase}" "${notes}" "${RESET}"

  done < <(printf '%s' "${sessions_json}" | jq -r '.[] | [.name, .status, .duration, .phase, .notes] | @tsv')
}
```

### Key printf Format Specifiers

```bash
# Left-aligned, 15 chars wide:
printf '%-15s' "hello"       # "hello          "

# Right-aligned, 8 chars wide:
printf '%8s' "hello"         # "   hello"

# Truncate to max width (bash parameter expansion):
name="very-long-session-name"
printf '%-15.15s' "${name}"  # "very-long-sessi"

# Multiple columns:
printf '%-20s %8s %12s\n' "Name" "Status" "Duration"

# Repeat character (for separators):
printf '%.0s─' {1..60}      # "────────────────..." (60 dashes)
# Or without brace expansion:
printf '%*s' 60 '' | tr ' ' '─'
```

### Handling Variable-Width Content

When content width is unknown (session names vary):

```bash
# Option 1: Truncate with ellipsis
truncate() {
  local str="$1" max="$2"
  if (( ${#str} > max )); then
    printf '%s…' "${str:0:$((max - 1))}"
  else
    printf '%s' "${str}"
  fi
}

# Usage:
printf '%-15s' "$(truncate "${session_name}" 15)"

# Option 2: Dynamic column width (calculate max)
calc_max_width() {
  local max=0
  local item
  for item in "$@"; do
    (( ${#item} > max )) && max=${#item}
  done
  printf '%d' "${max}"
}

# Option 3: Use column command for dynamic alignment
# Pipe TSV data to column:
generate_tsv_data | column -t -s $'\t'
```

### column Command Usage

For truly dynamic table widths (when you don't know column sizes ahead of time):

```bash
# Generate tab-separated data, pipe to column
{
  printf '%s\t%s\t%s\n' "SESSION" "STATUS" "DURATION"
  printf '%s\t%s\t%s\n' "fix-auth" "running" "12m 30s"
  printf '%s\t%s\t%s\n' "add-tests" "stuck" "45m 12s"
} | column -t -s $'\t'

# Output:
# SESSION    STATUS   DURATION
# fix-auth   running  12m 30s
# add-tests  stuck    45m 12s
```

**Caveat:** `column` strips ANSI color codes from width calculation in some versions but not others. For colored output, `printf` with hardcoded widths is more reliable.

### Compact Dashboard Layout

For `gsd status` default (non-verbose) view:

```bash
print_compact_status() {
  local running=0 stuck=0 queued=0 done_count=0 failed=0

  # Count by status
  running=$(printf '%s' "${sessions}" | jq '[.[] | select(.status == "running")] | length')
  stuck=$(printf '%s' "${sessions}" | jq '[.[] | select(.status == "stuck")] | length')
  queued=$(printf '%s' "${sessions}" | jq '[.[] | select(.status == "queued")] | length')

  # Summary line
  printf '%s◆ Pipeline:%s ' "${BOLD}" "${RESET}"
  (( running > 0 )) && printf '%s%d running%s ' "${GREEN}" "${running}" "${RESET}"
  (( stuck > 0 ))   && printf '%s%d stuck%s '   "${RED}" "${stuck}" "${RESET}"
  (( queued > 0 ))  && printf '%s%d queued%s '  "${YELLOW}" "${queued}" "${RESET}"
  printf '\n'
}
```

---

## 4. JSON Parsing with jq

### Core jq Patterns for gsd-cli

```bash
# ── Extract a single field ──
session_id=$(printf '%s' "${json}" | jq -r '.id')

# ── Extract from array ──
# Get all session names:
printf '%s' "${json}" | jq -r '.[].name'

# ── Filter array ──
# Get only running sessions:
printf '%s' "${json}" | jq '[.[] | select(.status == "running")]'

# ── Format as TSV for bash consumption ──
# This is THE key pattern: convert JSON array to tab-separated values
# that bash can read with `while IFS=$'\t' read -r`
printf '%s' "${json}" | jq -r '.[] | [.name, .status, .duration] | @tsv'

# ── Conditional formatting in jq ──
printf '%s' "${json}" | jq -r '.[] |
  [
    .name,
    .status,
    (if .duration > 1800 then "stuck" else "ok" end)
  ] | @tsv'

# ── Count items ──
count=$(printf '%s' "${json}" | jq 'length')

# ── Safe field access (with defaults) ──
printf '%s' "${json}" | jq -r '.name // "unknown"'

# ── Multiple fields at once (efficient: one jq call) ──
read -r name status duration < <(
  printf '%s' "${json}" | jq -r '[.name, .status, (.duration | tostring)] | join("\t")'
)
```

### The @tsv + read Pattern (Most Important)

This is how to efficiently bridge jq's JSON world into bash variables:

```bash
# Convert JSON array to bash-processable rows
process_sessions() {
  local json="$1"
  local name status duration phase

  while IFS=$'\t' read -r name status duration phase; do
    # Now ${name}, ${status}, ${duration}, ${phase} are bash variables
    printf '%-15s %-10s %-10s %-7s\n' "${name}" "${status}" \
      "$(format_duration "${duration}")" "${phase}"
  done < <(printf '%s' "${json}" | jq -r '
    .[] | [
      .name,
      .status,
      (.duration // 0 | tostring),
      (.phase // "—")
    ] | @tsv
  ')
}
```

Why this pattern:
- **Single jq invocation** for the entire array (fast)
- **@tsv escapes** handle special characters in values
- **Process substitution** (`< <(...)`) avoids subshell variable scope issues
- **IFS=$'\t'** splits only on tabs, not spaces (safe for values with spaces)

### Error Handling for jq

```bash
# Pattern: Capture output and check exit code
safe_jq() {
  local input="$1"
  local filter="$2"
  local result

  if ! result=$(printf '%s' "${input}" | jq -r "${filter}" 2>/dev/null); then
    return 1
  fi

  # jq returns "null" for missing fields, convert to empty
  if [[ "${result}" == "null" ]]; then
    return 1
  fi

  printf '%s' "${result}"
}

# Usage:
name=$(safe_jq "${json}" '.name') || name="unknown"

# Pattern: Validate JSON before processing
validate_json() {
  local input="$1"
  if ! printf '%s' "${input}" | jq empty 2>/dev/null; then
    err "Invalid JSON received"
    if [[ "${VERBOSE}" == "true" ]]; then
      err "Raw output: ${input:0:200}"
    fi
    return 1
  fi
}

# Pattern: Handle jq not installed
require_jq() {
  if ! command -v jq &>/dev/null; then
    die "jq is required but not installed. Install with: sudo apt install jq"
  fi
}
```

### Performance: Minimize jq Invocations

```bash
# BAD: Multiple jq calls on same data (spawns jq process each time)
name=$(echo "${json}" | jq -r '.name')
status=$(echo "${json}" | jq -r '.status')
duration=$(echo "${json}" | jq -r '.duration')

# GOOD: Single jq call, extract all fields at once
read -r name status duration < <(
  printf '%s' "${json}" | jq -r '[.name, .status, (.duration | tostring)] | join("\t")'
)

# GOOD: Cache command output, process cached result
get_session_data() {
  # Call opencode once, cache the result
  local _cache
  _cache=$(opencode session list --json 2>/dev/null) || {
    err "Failed to get sessions from opencode"
    return 1
  }

  # Now use cached result for multiple queries
  RUNNING_COUNT=$(printf '%s' "${_cache}" | jq '[.[] | select(.status == "running")] | length')
  STUCK_SESSIONS=$(printf '%s' "${_cache}" | jq -r '[.[] | select(.duration > 1800)] | .[] | .name')
  TOTAL_COUNT=$(printf '%s' "${_cache}" | jq 'length')
}
```

### Constructing JSON Output (for --json flag)

```bash
# Build JSON output with jq --null-input
output_status_json() {
  local sessions="$1" queue_status="$2"

  jq --null-input \
    --argjson sessions "${sessions}" \
    --argjson queue "${queue_status}" \
    '{
      timestamp: (now | todate),
      sessions: $sessions,
      queue: $queue,
      summary: {
        running: ($sessions | map(select(.status == "running")) | length),
        stuck: ($sessions | map(select(.status == "stuck")) | length),
        queued: ($sessions | map(select(.status == "queued")) | length)
      }
    }'
}
```

---

## 5. Script Structure & Best Practices

### Complete Script Skeleton

```bash
#!/usr/bin/env bash
#
# gsd - Pipeline monitoring tool for GSD runs
# Usage: gsd [OPTIONS] <command> [ARGS]
#

set -euo pipefail

# ── Constants ──────────────────────────────────────────
readonly VERSION="0.1.0"
readonly SCRIPT_NAME="${0##*/}"
readonly QUEUE_FILE="${GSD_QUEUE_FILE:-$HOME/dev/punchlab/QUEUE.md}"
readonly LOG_DIR="${GSD_LOG_DIR:-/tmp}"
readonly STUCK_THRESHOLD_MIN="${GSD_STUCK_THRESHOLD:-30}"

# ── Global State ──────────────────────────────────────
VERBOSE=false
JSON_OUTPUT=false

# ── Color Setup ────────────────────────────────────────
setup_colors() {
  if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
    RED=$'\033[31m'    GREEN=$'\033[32m'  YELLOW=$'\033[33m'
    BLUE=$'\033[34m'   CYAN=$'\033[36m'   BOLD=$'\033[1m'
    DIM=$'\033[2m'     RESET=$'\033[0m'
  else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' RESET=''
  fi
}

# ── Utility Functions ──────────────────────────────────
err()  { printf '%s%s%s\n' "${RED}" "$*" "${RESET}" >&2; }
die()  { err "Error: $*"; exit 1; }
debug() { [[ "${VERBOSE}" == "true" ]] && printf '%s[debug] %s%s\n' "${DIM}" "$*" "${RESET}" >&2; }

check_deps() {
  command -v jq &>/dev/null       || die "jq is required. Install: sudo apt install jq"
  command -v opencode &>/dev/null || die "opencode is required. See: https://github.com/sst/opencode"
}

# ── Cleanup ────────────────────────────────────────────
cleanup() {
  # Remove any temp files created during execution
  :  # placeholder
}
trap cleanup EXIT

# ── Helper Functions ───────────────────────────────────
format_duration() { ... }
print_header() { ... }

# ── Data Functions ─────────────────────────────────────
get_sessions() { ... }
get_queue() { ... }
find_stuck() { ... }

# ── Subcommand Functions ──────────────────────────────
cmd_status() { ... }
cmd_queue() { ... }
cmd_stuck() { ... }
cmd_log() { ... }
cmd_tail() { ... }

# ── Main ───────────────────────────────────────────────
main() {
  setup_colors
  check_deps

  # Parse global flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose)  VERBOSE=true; shift ;;
      --json)        JSON_OUTPUT=true; shift ;;
      --version)     printf '%s\n' "gsd ${VERSION}"; return 0 ;;
      -h|--help)     usage; return 0 ;;
      --)            shift; break ;;
      -*)            die "Unknown option: $1" ;;
      *)             break ;;
    esac
  done

  # JSON mode disables colors
  [[ "${JSON_OUTPUT}" == "true" ]] && { RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' RESET=''; }

  local cmd="${1:-status}"
  shift 2>/dev/null || true

  case "${cmd}" in
    status)   cmd_status "$@" ;;
    queue|q)  cmd_queue "$@" ;;
    stuck)    cmd_stuck "$@" ;;
    log)      cmd_log "$@" ;;
    tail)     cmd_tail "$@" ;;
    help)     usage ;;
    *)        die "Unknown command: '${cmd}'" ;;
  esac
}

main "$@"
```

### Error Handling Deep Dive

```bash
# set -euo pipefail breakdown:
#   -e (errexit):    Exit on non-zero return (with caveats)
#   -u (nounset):    Error on undefined variables
#   -o pipefail:     Pipeline fails if ANY command fails (not just last)

# CAUTION with -e: These are safe because -e doesn't trigger in conditionals:
if some_cmd; then ...          # Safe: inside 'if'
some_cmd || handle_error       # Safe: part of || chain
some_cmd && other_cmd          # Safe: part of && chain

# DANGER with -e + arithmetic:
i=0
(( i++ ))                      # EXITS! Because i++ returns 0 (the pre-increment value)
(( ++i ))                      # Safe: returns 1
(( i += 1 ))                   # Safe: returns 1

# SAFE arithmetic pattern:
(( i++ )) || true              # Prevent errexit on zero result

# Pattern: Explicit error handling for critical operations
get_sessions() {
  local output
  output=$(opencode session list --json 2>&1) || {
    local exit_code=$?
    if (( exit_code == 127 )); then
      die "opencode not found in PATH"
    else
      err "opencode session list failed (exit ${exit_code})"
      debug "Output: ${output}"
      return 1
    fi
  }
  printf '%s' "${output}"
}
```

### Making Scripts Installable

```bash
# Option 1: Symlink (recommended for development)
# From the repo directory:
ln -sf "$(pwd)/gsd" ~/.local/bin/gsd

# Option 2: Copy (for "installation")
install -m 755 gsd /usr/local/bin/gsd

# Option 3: Add repo to PATH (in ~/.bashrc)
export PATH="$HOME/dev/punchlab/gsd-cli:$PATH"
```

**The shebang line matters:**

```bash
#!/usr/bin/env bash     # GOOD: finds bash in PATH (portable)
#!/bin/bash             # OK: works on most Linux, but not NixOS/Guix
#!/bin/sh               # WRONG: not bash, may be dash/ash
```

**File naming:** Name the script `gsd` (no `.sh` extension). Google Shell Style Guide: "Executables added to PATH should have no extension."

### Dependency Checking Pattern

```bash
check_deps() {
  local missing=()

  command -v jq &>/dev/null       || missing+=("jq")
  command -v opencode &>/dev/null || missing+=("opencode")

  if (( ${#missing[@]} > 0 )); then
    err "Missing required dependencies: ${missing[*]}"
    printf '\n' >&2
    for dep in "${missing[@]}"; do
      case "${dep}" in
        jq)       printf '  %s: sudo apt install jq  (or brew install jq)\n' "jq" >&2 ;;
        opencode) printf '  %s: see https://github.com/sst/opencode\n' "opencode" >&2 ;;
      esac
    done
    exit 1
  fi
}
```

---

## 6. Performance Optimization

### Target: < 2 seconds for `gsd status`

The main bottleneck will be external commands, especially `opencode session list`. Here's how to stay fast:

### Avoid Unnecessary Subshells

```bash
# BAD: Each $() spawns a subshell
len=$(echo "${str}" | wc -c)

# GOOD: Bash builtin
len=${#str}

# BAD: External command for simple string ops
dirname=$(dirname "${path}")
basename=$(basename "${path}")

# GOOD: Parameter expansion (bash builtin, no subprocess)
dirname="${path%/*}"
basename="${path##*/}"

# BAD: External command for arithmetic
result=$(expr 5 + 3)

# GOOD: Bash arithmetic (builtin)
result=$((5 + 3))

# BAD: Unnecessary cat
cat file | grep pattern

# GOOD: Direct redirect
grep pattern file
# Or for variable: grep pattern <<< "${var}"
```

### Cache External Command Output

```bash
# BAD: Call opencode multiple times
running=$(opencode session list --json | jq '[.[] | select(.status == "running")] | length')
stuck=$(opencode session list --json | jq '[.[] | select(.status == "stuck")] | length')
queued=$(opencode session list --json | jq '[.[] | select(.status == "queued")] | length')

# GOOD: Call once, parse multiple times
_sessions_cache=""
get_sessions_cached() {
  if [[ -z "${_sessions_cache}" ]]; then
    _sessions_cache=$(opencode session list --json 2>/dev/null) || {
      err "Failed to get sessions"
      return 1
    }
  fi
  printf '%s' "${_sessions_cache}"
}

# Now each call reuses the cache:
running=$(get_sessions_cached | jq '...')
stuck=$(get_sessions_cached | jq '...')
```

### Single jq Call for Multiple Extractions

```bash
# BAD: 3 jq processes
name=$(printf '%s' "${json}" | jq -r '.name')
status=$(printf '%s' "${json}" | jq -r '.status')
duration=$(printf '%s' "${json}" | jq -r '.duration')

# GOOD: 1 jq process, read into multiple variables
read -r name status duration < <(
  printf '%s' "${json}" | jq -r '[.name, .status, (.duration | tostring)] | join("\t")'
)

# BETTER for arrays: Process entire dataset in one jq call
printf '%s' "${json}" | jq -r '.[] | [.name, .status, (.duration | tostring)] | @tsv' |
while IFS=$'\t' read -r name status duration; do
  # process each row
  :
done
```

### Parallel Data Collection

When `gsd status` needs data from multiple independent sources:

```bash
cmd_status() {
  # Collect data in parallel using background processes
  local sessions_file queue_file
  sessions_file=$(mktemp)
  queue_file=$(mktemp)

  # Launch both in background
  opencode session list --json > "${sessions_file}" 2>/dev/null &
  local sessions_pid=$!

  parse_queue_file > "${queue_file}" 2>/dev/null &
  local queue_pid=$!

  # Wait for both (and check exit codes)
  local sessions_ok=true queue_ok=true
  wait "${sessions_pid}" || sessions_ok=false
  wait "${queue_pid}" || queue_ok=false

  # Read results
  local sessions="" queue=""
  [[ "${sessions_ok}" == "true" ]] && sessions=$(<"${sessions_file}")
  [[ "${queue_ok}" == "true" ]] && queue=$(<"${queue_file}")

  # Cleanup
  rm -f "${sessions_file}" "${queue_file}"

  # Render
  render_status "${sessions}" "${queue}"
}
```

### Avoid Repeated Glob Expansion

```bash
# BAD: Glob evaluated each time
for f in /tmp/gsd-*.log; do ... done
for f in /tmp/gsd-*.log; do ... done  # Evaluated again!

# GOOD: Capture glob once into array
log_files=(/tmp/gsd-*.log)
# Check if glob matched anything
if [[ ! -e "${log_files[0]:-}" ]]; then
  debug "No log files found"
  return 0
fi
for f in "${log_files[@]}"; do ... done
```

### Use Builtins Over External Commands

```bash
# String operations — use parameter expansion:
"${var^^}"          # uppercase (bash 4+)
"${var,,}"          # lowercase (bash 4+)
"${var/old/new}"    # replace first
"${var//old/new}"   # replace all
"${var#prefix}"     # strip prefix
"${var%suffix}"     # strip suffix
"${var:0:10}"       # substring

# Date math — avoid calling `date` in loops:
# Get epoch once, then do arithmetic
now=$(date +%s)
file_age=$(( now - $(stat -c %Y "${file}") ))

# Test — use [[ ]] over [ ]:
# [[ is a bash keyword (no subprocess), [ is a command
[[ -f "${file}" ]]  # Fast (builtin keyword)
[ -f "${file}" ]    # Slower (command, even if builtin)
```

### Benchmark: How Long Each Operation Takes

Approximate timings on a modern Linux system:

| Operation | Time | Notes |
|-----------|------|-------|
| Bash variable assignment | ~0 | Builtin |
| `[[ ]]` test | ~0 | Builtin keyword |
| `printf` | ~0 | Builtin |
| `${var#pattern}` | ~0 | Builtin |
| `$(( arithmetic ))` | ~0 | Builtin |
| Single `jq` invocation | ~5ms | External process startup |
| Single `date` invocation | ~3ms | External process |
| `stat` on one file | ~1ms | System call |
| `opencode session list` | ~200-1000ms | Network/process (estimate) |
| `ps aux` | ~10ms | Process table scan |

**Implication:** The opencode command will dominate execution time. Everything else is noise. Focus optimization on calling opencode minimally (once per invocation if possible).

---

## 7. QUEUE.md Parsing

### Parsing Markdown Status Lists

Given QUEUE.md format like:

```markdown
## In Progress
- [ ] fix-auth: Fix authentication flow
- [x] add-tests: Add unit tests for parser

## Queued
- [ ] refactor-api: Clean up API layer
- [ ] update-docs: Update documentation

## Done
- [x] fix-typo: Fix typo in README
```

```bash
parse_queue() {
  local queue_file="${QUEUE_FILE}"

  if [[ ! -f "${queue_file}" ]]; then
    warn "Queue file not found: ${queue_file}"
    return 1
  fi

  local section="" line
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # Detect section headers
    if [[ "${line}" =~ ^##[[:space:]]+(.+) ]]; then
      section="${BASH_REMATCH[1]}"
      continue
    fi

    # Parse task lines: "- [ ] name: description" or "- [x] name: description"
    if [[ "${line}" =~ ^-[[:space:]]+\[([[:space:]x])\][[:space:]]+([^:]+):[[:space:]]*(.*) ]]; then
      local checked="${BASH_REMATCH[1]}"
      local name="${BASH_REMATCH[2]}"
      local desc="${BASH_REMATCH[3]}"

      # Trim whitespace
      name="${name## }"
      name="${name%% }"

      local status
      if [[ "${checked}" == "x" ]]; then
        status="done"
      else
        case "${section,,}" in
          *progress*) status="in-progress" ;;
          *queue*)    status="queued" ;;
          *done*)     status="done" ;;
          *fail*)     status="failed" ;;
          *)          status="unknown" ;;
        esac
      fi

      # Output as TSV for downstream processing
      printf '%s\t%s\t%s\t%s\n' "${name}" "${status}" "${section}" "${desc}"
    fi
  done < "${queue_file}"
}
```

---

## 8. Process Monitoring Patterns

### Checking if a PID is Alive

```bash
is_pid_alive() {
  local pid="$1"
  kill -0 "${pid}" 2>/dev/null
}

# Get process start time (for duration calculation)
get_process_start() {
  local pid="$1"
  # etimes = elapsed time in seconds since process started
  ps -o etimes= -p "${pid}" 2>/dev/null | tr -d ' '
}
```

### Finding GSD Processes

```bash
find_gsd_processes() {
  local pid_files=(/tmp/gsd-*-pid)
  [[ -e "${pid_files[0]:-}" ]] || return 0

  for pid_file in "${pid_files[@]}"; do
    local pid session_name
    pid=$(<"${pid_file}")
    session_name="${pid_file##*/gsd-}"
    session_name="${session_name%-pid}"

    if is_pid_alive "${pid}"; then
      local elapsed
      elapsed=$(get_process_start "${pid}") || elapsed=0

      # Check corresponding log file for staleness
      local log_file="/tmp/gsd-${session_name}.log"
      local log_age=0
      if [[ -f "${log_file}" ]]; then
        local now
        now=$(date +%s)
        local log_mtime
        log_mtime=$(stat -c %Y "${log_file}")
        log_age=$(( now - log_mtime ))
      fi

      local is_stuck=false
      if (( elapsed > STUCK_THRESHOLD_MIN * 60 )) && (( log_age > 300 )); then
        is_stuck=true
      fi

      printf '%s\t%s\t%s\t%s\t%s\n' \
        "${session_name}" "${pid}" "${elapsed}" "${log_age}" "${is_stuck}"
    else
      # Stale PID file — process already exited
      debug "Stale PID file: ${pid_file} (pid ${pid} not running)"
    fi
  done
}
```

---

## 9. Installation Script

```bash
#!/usr/bin/env bash
# install.sh — Install gsd CLI tool
set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"

main() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Ensure install directory exists and is in PATH
  mkdir -p "${INSTALL_DIR}"

  if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
    printf 'Warning: %s is not in your PATH.\n' "${INSTALL_DIR}" >&2
    printf 'Add this to your ~/.bashrc:\n  export PATH="%s:$PATH"\n' "${INSTALL_DIR}" >&2
  fi

  # Create symlink
  ln -sf "${script_dir}/gsd" "${INSTALL_DIR}/gsd"
  printf 'Installed: %s -> %s\n' "${INSTALL_DIR}/gsd" "${script_dir}/gsd"

  # Verify
  if command -v gsd &>/dev/null; then
    printf 'Success! Run "gsd --help" to get started.\n'
  else
    printf 'Symlink created, but "gsd" not yet in PATH. Start a new shell or source your profile.\n'
  fi
}

main "$@"
```

---

## 10. Testing Patterns

```bash
# Quick smoke test (run after changes):
test_gsd() {
  echo "=== Testing gsd CLI ==="

  echo "--- gsd --version ---"
  ./gsd --version || echo "FAIL: --version"

  echo "--- gsd --help ---"
  ./gsd --help || echo "FAIL: --help"

  echo "--- gsd status ---"
  ./gsd status || echo "FAIL: status"

  echo "--- gsd status --json ---"
  ./gsd status --json | jq . || echo "FAIL: --json"

  echo "--- gsd status --verbose ---"
  ./gsd status --verbose || echo "FAIL: --verbose"

  echo "--- gsd queue ---"
  ./gsd queue || echo "FAIL: queue"

  echo "--- Color disabled in pipe ---"
  ./gsd status | cat  # Should have no ANSI codes

  echo "--- Unknown command ---"
  ./gsd asdfasdf 2>/dev/null && echo "FAIL: should have errored" || echo "OK: errored as expected"

  echo "=== Done ==="
}
```

---

## Sources

| Source | Confidence | What it provided |
|--------|------------|-----------------|
| GNU Bash Manual (official docs) | HIGH | getopts spec, parameter expansion, builtins |
| Google Shell Style Guide | HIGH | Script structure, naming, quoting, main() pattern |
| BashPitfalls (Greg's Wiki) | HIGH | 60+ specific bash mistakes to avoid |
| jq 1.8 Manual (official) | HIGH | jq flags, @tsv, filter syntax |
| System verification (bash 5.2.21, jq 1.7) | HIGH | Confirmed available versions |
| NO_COLOR convention | HIGH | Standard for disabling color output |
| Personal expertise patterns | MEDIUM | Subcommand dispatch, performance tips (common patterns) |
