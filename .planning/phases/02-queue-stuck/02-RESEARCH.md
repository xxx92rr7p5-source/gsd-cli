# Phase 2: Queue & Stuck Commands — Research

**Researched:** 2026-02-17
**Domain:** Bash CLI — QUEUE.md parsing, process monitoring, SIGTERM kill workflow
**Confidence:** HIGH (building on existing Phase 1 codebase; all patterns already proven)

---

## Summary

Phase 2 completes `gsd queue` and `gsd stuck` — two commands with stubs already present in the `gsd` script from Phase 1. The CLI framework, color system, utility functions, and subcommand dispatch are all in place. This phase is purely about implementing the bodies of `cmd_queue()` and `cmd_stuck()`, and wiring `check_stuck()` fully into `cmd_stuck`.

`cmd_queue()` already has a partial implementation in the script (it reads QUEUE.md via the header loop) but uses a limited regex that only handles `[ ]` and `[x]` checkboxes — it needs to be aligned with `get_queue_items()` which already handles the full format. The `--json` output is missing from `cmd_queue`.

`cmd_stuck()` currently just prints "coming soon". It needs to: scan PID files, call `check_stuck()` for each one, display results in a formatted table, and implement the `--kill` flow with confirmation prompt.

**Primary recommendation:** Implement Phase 2 in a single plan (one `gsd` file modification) since both commands are small and closely related. The stuck detection engine (`check_stuck()`) already exists from Phase 1; `cmd_stuck` just needs to invoke it properly.

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| §2.2.1 | Read and parse `~/dev/punchlab/QUEUE.md` | `QUEUE_FILE` constant + `get_queue_items()` already exists |
| §2.2.2 | Path overridable via `GSD_QUEUE_FILE` | Already implemented via `readonly QUEUE_FILE="${GSD_QUEUE_FILE:-...}"` |
| §2.2.3 | Parse `- [ ] name: description` and `- [x] ...` lines | `get_queue_items()` already handles this; `cmd_queue` needs to use it |
| §2.2.4 | Detect section headers for status assignment | `get_queue_items()` already handles `## In Progress`, `## Queued`, `## Done`, `## Failed` |
| §2.2.5 | Display grouped by status with colors | Need `cmd_queue` output loop grouped by section |
| §2.2.6 | Helpful error if QUEUE.md not found | `die()` call when `! -f "${QUEUE_FILE}"` |
| §2.2.7 | Handle malformed lines gracefully | Already skipped silently in `get_queue_items()` |
| §2.2.8 | `q` alias for `queue` | Already in dispatch: `queue\|q)` |
| §2.3.1 | Find sessions running > N minutes | Scan `/tmp/gsd-*-pid` files, call `check_stuck()` |
| §2.3.2 | `--threshold N` / `-t N` flag | Flag parsing already in `cmd_stuck` stub |
| §2.3.3 | `GSD_STUCK_THRESHOLD` env var | Already: `STUCK_THRESHOLD_MIN="${GSD_STUCK_THRESHOLD:-30}"` |
| §2.3.4 | Display PID, session name, runtime, last log activity | Table output from `check_stuck()` globals `STUCK_RUNTIME`, `STUCK_LOG_STALENESS` |
| §2.3.5 | `--kill` / `-k` flag | Flag parsing already in `cmd_stuck` stub |
| §2.3.6 | Confirm before kill unless `--force` | `read -r -p "Kill N stuck processes? [y/N]: "` confirmation loop |
| §2.3.7 | Verify PID alive before kill | `kill -0 "${pid}" 2>/dev/null` check before `kill "${pid}"` |
| §2.3.8 | Handle stale PID files gracefully | `check_stuck()` already removes stale PIDs silently |
| §2.3.9 | Message when no stuck found | Print "No stuck processes detected." when list is empty |
| §3.5.x | `--json` output for both commands | `jq -n` construction pattern already proven in `cmd_status` |
</phase_requirements>

---

## Standard Stack

No new dependencies for Phase 2. All tools are already available:

### Core (inherited from Phase 1)
| Tool | Purpose | Already Used In |
|------|---------|----------------|
| Bash 5.2 | Script runtime | Entire `gsd` script |
| `jq` 1.7 | JSON construction for `--json` output | `cmd_status` JSON branch |
| `kill -0` | PID liveness check | `check_stuck()` |
| `ps -o etimes=` | Get process runtime seconds | `check_stuck()` |
| `stat -c %Y` | Get log file mtime | `check_stuck()` |
| `date +%s` | Current epoch for staleness calc | `check_stuck()` |
| `kill` (SIGTERM) | Send signal to process | New in `cmd_stuck --kill` |
| `read -r -p` | Confirmation prompt | New in `cmd_stuck --kill` |

### No New Dependencies
Phase 2 introduces zero new external tools. Everything is either a bash builtin or a standard Unix utility already present.

---

## Architecture Patterns

### What's Already Built (Phase 1)
```
gsd
├── Constants + color vars               ✅ Done
├── Utility: err(), warn(), debug(), die(), die_usage()  ✅ Done
├── Utility: cleanup(), trap, check_deps()               ✅ Done
├── Utility: format_duration()           ✅ Done
├── Formatting: print_header(), print_table_header(), truncate_str()  ✅ Done
├── Data: get_sessions(), get_running_sessions()         ✅ Done
├── Data: get_completed_sessions()       ✅ Done
├── Data: get_queue_items()              ✅ Done (used by cmd_status)
├── Data: check_stuck()                  ✅ Done (but NOT called by cmd_stuck yet)
├── Help: queue_usage(), stuck_usage()   ✅ Done
├── cmd_status()                         ✅ Complete
├── cmd_queue()                          ⚠️  Partial — has basic display but wrong regex, no --json
├── cmd_stuck()                          ❌  Stub only — "coming soon"
├── cmd_log(), cmd_tail()                🔜 Future (Phase 3)
└── main() dispatch                      ✅ Done
```

### Pattern: cmd_queue() Full Implementation

`cmd_queue` needs to be replaced with a proper implementation. The existing code in the script has a limited `[[ "${line}" =~ ^-[[:space:]]+\[([[:space:]xX])\] ]]` regex that misses `~`, `!`, `S` checkboxes and doesn't use `get_queue_items()`.

**Recommended approach:** Use `get_queue_items()` (already exists, already handles all formats) and loop over the output to display grouped-by-section.

```bash
# Good: reuse existing data function
while IFS=$'\t' read -r q_status q_name q_desc; do
  # display logic here
done < <(get_queue_items)
```

**Grouped display strategy:** Two-pass approach:
1. Collect all items into arrays indexed by status
2. Print each section (In Progress, Queued, Done, Failed) only if non-empty

### Pattern: cmd_stuck() Full Implementation

The stuck command needs to:
1. Discover all PID files: `for pid_file in "${LOG_DIR}"/gsd-*-pid; do`
2. Extract session name: `session="${pid_file##*/gsd-}"` then `session="${session%-pid}"`
3. Call `check_stuck "${session}"` → populates `STUCK_RUNTIME` and `STUCK_LOG_STALENESS`
4. Collect stuck sessions into arrays
5. Display table or "none found" message
6. If `--kill`: prompt (unless `--force`), then kill each

### Pattern: Kill Confirmation Prompt

```bash
# Confirmation prompt — §2.3.6
if [[ "${kill_stuck}" == "true" ]]; then
  if [[ "${force}" == "false" ]]; then
    printf '\n%sWill send SIGTERM to %d stuck process(es):%s\n' "${BOLD_RED}" "${#stuck_pids[@]}" "${RESET}"
    for pid in "${stuck_pids[@]}"; do
      printf '  PID %s  session: %s\n' "${pid}" "${stuck_sessions[${pid}]}"
    done
    printf '\n'
    local confirm
    read -r -p "Kill these processes? [y/N]: " confirm
    if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
      printf 'Aborted.\n'
      return 0
    fi
  fi
  # Perform kills
  for pid in "${stuck_pids[@]}"; do
    if kill -0 "${pid}" 2>/dev/null; then   # Re-verify alive — §2.3.7
      kill "${pid}"  # SIGTERM only — §5.8
      printf '%sKilled PID %s (%s)%s\n' "${GREEN}" "${pid}" "${stuck_sessions[${pid}]}" "${RESET}"
      rm -f "${LOG_DIR}/gsd-${stuck_sessions[${pid}]}-pid"  # Cleanup
    else
      printf '%sPID %s already exited%s\n' "${DIM}" "${pid}" "${RESET}"
    fi
  done
fi
```

**Key constraint:** §5.8 — SIGTERM only (`kill "${pid}"`), never SIGKILL automatically. This is `kill` with no signal flag, which defaults to SIGTERM.

### Pattern: JSON Output for Queue and Stuck

Both `cmd_queue` and `cmd_stuck` need `--json` support (requirement §3.5.x). Follow the same pattern established in `cmd_status`:

```bash
# JSON for queue
if [[ "${JSON_OUTPUT:-false}" == "true" ]]; then
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  # Build JSON items array from get_queue_items() output
  local items_json
  items_json=$(get_queue_items | \
    jq -Rr 'split("\t") | if length >= 2 then
      {status: .[0], name: .[1], description: (.[2] // "")}
    else empty end' | jq -sc '.') || items_json="[]"
  jq -n \
    --arg timestamp "${timestamp}" \
    --argjson items "${items_json}" \
    --arg queue_file "${QUEUE_FILE}" \
    '{timestamp: $timestamp, queue_file: $queue_file, items: $items}'
  return 0
fi
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Session name from PID file path | Custom regex parser | `"${pid_file##*/gsd-}"; "${name%-pid}"` | Bash parameter expansion handles this cleanly |
| QUEUE.md parsing | New parser in cmd_queue | `get_queue_items()` already exists | Avoid duplication; same function used by `cmd_status` |
| PID liveness | ps-based check | `kill -0 "${pid}" 2>/dev/null` | Simpler, no parsing, handles permission correctly |
| Duration formatting | Custom logic | `format_duration()` already exists | Already tested in Phase 1 |
| Table headers | New print function | `print_header()`, `print_table_header()` already exist | Consistent UI |

---

## Common Pitfalls

### Pitfall 1: Glob When No PID Files Exist
**What goes wrong:** `for pid_file in /tmp/gsd-*-pid; do` — if no files match, `pid_file` is the literal string `/tmp/gsd-*-pid`.
**How to avoid:** Always guard: `for pid_file in "${LOG_DIR}"/gsd-*-pid; do [[ -f "${pid_file}" ]] || continue`
**Warning signs:** Loop runs once with a literal glob string, `check_stuck` gets `*` as session name.

### Pitfall 2: Associative Arrays for Stuck Data
**What goes wrong:** Using `declare -A stuck_sessions` without proper quoting/initialization.
**How to avoid:** Use parallel indexed arrays for PID→session mapping. Or use a tab-delimited accumulator string and re-parse.
**Alternative:** Collect to temp file, process in second pass.

### Pitfall 3: read -r -p in Non-Interactive Mode
**What goes wrong:** `read -r -p "Kill? [y/N]: "` hangs if stdin is piped/redirected.
**How to avoid:** Only show prompt when `[[ -t 0 ]]` (stdin is TTY). If non-interactive and not `--force`, treat as "No" (safe default).

### Pitfall 4: Arithmetic with STUCK_THRESHOLD_MIN
**What goes wrong:** `threshold_seconds=$(( STUCK_THRESHOLD_MIN * 60 ))` — if `STUCK_THRESHOLD_MIN` is empty or non-numeric, arithmetic fails.
**How to avoid:** Already guarded in `cmd_stuck` stub: `if [[ ! "${2}" =~ ^[0-9]+$ ]]; then die_usage ...`. Ensure this check runs before assignment.

### Pitfall 5: cmd_queue --json Flag Not Parsed
**What goes wrong:** `cmd_queue` doesn't parse `--json` from its local flag loop (JSON_OUTPUT is set globally but the `--json` check must happen inside the function too).
**How to avoid:** Check `[[ "${JSON_OUTPUT:-false}" == "true" ]]` at the top of the JSON branch — JSON_OUTPUT is exported from `main()`.

### Pitfall 6: Overwriting cmd_queue vs. Enhancing It
**What goes wrong:** The current `cmd_queue` in the script has a working basic display loop. Completely replacing it risks breaking what works.
**How to avoid:** Rewrite cleanly by replacing the function body while keeping the flag parsing structure, help exit, and file-not-found die() call.

---

## Code Examples

### PID File Scan Loop (Correct Pattern)
```bash
# Source: established bash pattern for safe glob iteration
local stuck_pids=()
local stuck_names=()
local stuck_runtimes=()
local stuck_staleness=()

for pid_file in "${LOG_DIR}"/gsd-*-pid; do
  [[ -f "${pid_file}" ]] || continue

  # Extract session name: /tmp/gsd-MY-SESSION-pid → MY-SESSION
  local session
  session="${pid_file##*/gsd-}"
  session="${session%-pid}"

  local status
  status=$(check_stuck "${session}")

  case "${status}" in
    stuck)
      local pid
      pid=$(< "${pid_file}")
      stuck_pids+=("${pid}")
      stuck_names+=("${session}")
      stuck_runtimes+=("${STUCK_RUNTIME}")
      stuck_staleness+=("${STUCK_LOG_STALENESS}")
      ;;
    not_running|not_found)
      ;;  # Already cleaned up by check_stuck
    running)
      ;;  # Not stuck, ignore
  esac
done
```

### cmd_queue JSON Output
```bash
if [[ "${JSON_OUTPUT:-false}" == "true" ]]; then
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local items_json
  items_json=$(get_queue_items 2>/dev/null | \
    jq -Rr 'split("\t") | if length >= 2 then
      {status: .[0], name: .[1], description: (.[2] // "")}
    else empty end' 2>/dev/null | \
    jq -sc '.' 2>/dev/null) || items_json="[]"
  [[ "${items_json}" == "null" || -z "${items_json}" ]] && items_json="[]"
  jq -n \
    --arg timestamp "${timestamp}" \
    --arg queue_file "${QUEUE_FILE}" \
    --argjson items "${items_json}" \
    '{timestamp: $timestamp, queue_file: $queue_file, items: $items}'
  return 0
fi
```

### cmd_stuck JSON Output
```bash
if [[ "${JSON_OUTPUT:-false}" == "true" ]]; then
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local stuck_json="[]"
  if [[ "${#stuck_pids[@]}" -gt 0 ]]; then
    local i
    stuck_json="["
    for (( i=0; i<${#stuck_pids[@]}; i++ )); do
      [[ "${i}" -gt 0 ]] && stuck_json+=","
      stuck_json+=$(jq -n \
        --arg pid "${stuck_pids[${i}]}" \
        --arg session "${stuck_names[${i}]}" \
        --argjson runtime "${stuck_runtimes[${i}]}" \
        --argjson log_staleness "${stuck_staleness[${i}]}" \
        '{pid: $pid, session: $session, runtime_seconds: $runtime, log_staleness_seconds: $log_staleness}')
    done
    stuck_json+="]"
  fi
  jq -n \
    --arg timestamp "${timestamp}" \
    --argjson threshold "${STUCK_THRESHOLD_MIN}" \
    --argjson stuck "${stuck_json}" \
    '{timestamp: $timestamp, threshold_minutes: $threshold, stuck: $stuck}'
  return 0
fi
```

---

## What the Existing Code Already Provides

These are in the `gsd` script from Phase 1 and require NO modification:

| Function/Variable | Status | Used by Phase 2 |
|-------------------|--------|-----------------|
| `STUCK_THRESHOLD_MIN` | ✅ Global, overridable | `cmd_stuck` threshold check |
| `LOG_DIR` | ✅ `readonly` constant | PID + log file paths |
| `QUEUE_FILE` | ✅ `readonly` constant | Queue file path |
| `check_stuck()` | ✅ Complete | Called in loop by `cmd_stuck` |
| `STUCK_RUNTIME` | ✅ Global set by `check_stuck` | Display in stuck table |
| `STUCK_LOG_STALENESS` | ✅ Global set by `check_stuck` | Display in stuck table |
| `get_queue_items()` | ✅ Complete | Called by `cmd_queue` |
| `format_duration()` | ✅ Complete | Format runtime in stuck table |
| `print_header()` | ✅ Complete | Section headers |
| `print_table_header()` | ✅ Complete | Table column headers |
| `truncate_str()` | ✅ Complete | Session name truncation |
| `queue_usage()` | ✅ Complete | Help output |
| `stuck_usage()` | ✅ Complete | Help output |
| `cmd_queue()` flag parsing | ✅ Done | Keep, rewrite body |
| `cmd_stuck()` flag parsing | ✅ Done | Keep, add implementation |
| `JSON_OUTPUT` exported | ✅ Exported from main | Used by both commands |
| `VERBOSE` exported | ✅ Exported from main | Used by debug() calls |

---

## Open Questions

1. **opencode session list JSON schema** — Does `opencode session list` return sessions with a `name` field matching the PID file convention `gsd-<name>-pid`? Phase 1's `check_stuck()` assumes the session argument is the name from the PID file, not the opencode session ID.
   - **What we know:** `cmd_status` uses `.id // .name` as the session identifier.
   - **What's unclear:** Whether PID files are named after `.id` or `.name`.
   - **Recommendation:** `cmd_stuck` works independently of opencode session data — it scans PID files directly. This is correct behavior. No integration with `SESSION_DATA` needed for Phase 2.

2. **QUEUE.md `--json` flag scope** — The requirements say `--json` for both commands (§3.5). The `queue_usage()` function doesn't list `--json` as an option.
   - **Recommendation:** Add `--json` to the `cmd_queue` flag parsing loop (check `JSON_OUTPUT` which is already exported from main).

---

## Sources

### Primary (HIGH confidence)
- Existing `gsd` script (Phase 1 implementation) — verified by reading lines 1–881
- `REQUIREMENTS.md` §2.2, §2.3, §5 — authoritative spec
- `ARCHITECTURE.md` patterns — Phase 1 research, verified in implementation
- `PITFALLS.md` — Phase 1 research

### Secondary (MEDIUM confidence)
- GNU Bash Manual — `kill`, `read`, `declare -a` semantics
- BashPitfalls wiki — glob-with-no-matches behavior verified

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new dependencies, all tools proven in Phase 1
- Architecture: HIGH — patterns directly from existing working code
- Pitfalls: HIGH — learned from Phase 1 pitfalls research + code review

**Research date:** 2026-02-17
**Valid until:** 2026-03-17 (stable bash patterns; no dependency versioning concerns)
