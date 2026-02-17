---
phase: 01-foundation-status
plan: 02
subsystem: status-dashboard
tags: [bash, status, dashboard, opencode, queue, stuck-detection, json]
dependency_graph:
  requires: [gsd-executable, cli-framework]
  provides: [status-dashboard, data-layer, queue-parsing, stuck-detection]
  affects: [02-01, 02-02]
tech_stack:
  added: []
  patterns: [jq-json-construction, process-substitution, tab-delimited-internal-format, stuck-detection-pid-log]
key_files:
  created: []
  modified: [gsd]
decisions:
  - "Tab delimiter (\\t) instead of | for internal get_queue_items output — avoids conflicts with | in QUEUE.md content"
  - "QUEUE.md supports both 'name: desc' and 'name | file | phases' formats"
  - "check_stuck() uses global STUCK_RUNTIME and STUCK_LOG_STALENESS for caller inspection"
  - "SESSION_DATA global variable caches opencode output for single invocation per §2.1.9"
metrics:
  duration: "~20 minutes"
  completed: "2026-02-17"
  tasks_completed: 2
  files_created: 0
  files_modified: 1
---

# Phase 1 Plan 2: Status Dashboard Summary

**One-liner:** Full gsd status dashboard with opencode session caching, stuck detection via PID+log staleness, QUEUE.md multi-format parsing, compact/verbose/JSON output modes, and sub-1-second performance.

## What Was Built

Enhanced `gsd` executable with:

**Data Layer:**
- `get_sessions()` — calls `opencode session list --json` once, caches in `SESSION_DATA` global
- `get_running_sessions()` — filters by status field, falls back to all sessions if no status field
- `get_completed_sessions()` — extracts completed/failed, sorts by date, returns last 5
- `check_stuck()` — reads PID file, checks `kill -0`, computes `ps -o etimes=` runtime, checks `stat -c %Y` log staleness, returns "running"/"stuck"/"not_found"/"not_running"
- `get_queue_items()` — parses QUEUE.md with section headers, supports `name: desc` and `name | file | phases` formats, outputs tab-delimited `status\tname\tdescription`

**Formatting Layer:**
- `print_header()` — bold+blue section header with dim separator
- `print_table_header()` — bold header row + dim separator
- `truncate_str()` — truncates with ellipsis at specified width

**Status Dashboard (cmd_status):**
- Compact view: summary counts + running list + top-3 queued + recent completed
- Verbose view: full tables with fixed-width columns for all three sections
- JSON mode: structured output with `timestamp` (ISO 8601), `summary`, `sessions`, `queue`, `completed`
- Empty state: "No active sessions. Queue is empty. All clear!"
- Performance: < 1 second (under 2 second requirement per §2.1.5)

## Verification Results

- `bash -n gsd` → syntax OK ✓
- `./gsd` → compact dashboard with counts ✓
- `./gsd --verbose` → full tables with headers ✓
- `./gsd --json | jq -e '.timestamp'` → ISO 8601 timestamp ✓
- `./gsd --json | jq -e '.summary'` → summary object with running/stuck/queued counts ✓
- `GSD_QUEUE_FILE=/nonexistent ./gsd` → empty state, no crash ✓
- `time ./gsd` → ~0.9 seconds (< 2 second requirement) ✓
- No `| while` patterns ✓
- No `local var=$(cmd)` patterns ✓

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed queue item display — trailing spaces and mangled descriptions**
- **Found during:** Task 2 verification
- **Issue:** `get_queue_items` used `|` as delimiter, but QUEUE.md content also contains `|` characters. In JSON mode, `awk -F'|'` split on content `|` producing garbled output. Names had trailing spaces.
- **Fix:** Changed `get_queue_items` to output tab-delimited format (`status\tname\tdesc`). Updated all callers to use `IFS=$'\t'`. Changed JSON construction to use `jq -Rr 'split("\t")'`. Also extended section/checkbox handling to support `##Current Queue` section and `~`, `!`, `S` checkbox variants.
- **Files modified:** gsd (get_queue_items, cmd_status JSON construction, queue display loops)
- **Commit:** 0f278f8

**2. [Rule 1 - Bug] Fixed 4 pipe-to-while patterns in verbose/compact output sections**
- **Found during:** Task 2 plan verification check (`grep '| while' gsd`)
- **Issue:** `jq ... | while IFS read` used pipe subshell instead of process substitution
- **Fix:** Converted to `while read; done < <(jq ...)` process substitution pattern
- **Files modified:** gsd (4 locations in cmd_status)
- **Commit:** 0f278f8

## Commits

| Hash | Message |
|------|---------|
| 7e52dd6 | feat(01-01): create gsd executable with complete CLI framework |
| 0f278f8 | feat(01-02): implement status dashboard with data layer and formatting |

## Status

**Tasks 1 and 2 COMPLETE. Task 3 (checkpoint:human-verify) is PENDING user verification.**

## Self-Check: PASSED

- ✅ `gsd` file exists at repo root (880 lines)
- ✅ Commit 7e52dd6 exists (01-01 CLI framework)
- ✅ Commit 0f278f8 exists (01-02 status dashboard)
- ✅ 01-02-SUMMARY.md exists
