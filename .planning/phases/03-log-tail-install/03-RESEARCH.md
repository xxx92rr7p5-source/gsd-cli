# Phase 3: Log, Tail & Installation — Research

**Researched:** 2026-02-17
**Domain:** Bash CLI — opencode export integration, live log tailing, installation scripting
**Confidence:** HIGH (opencode output format verified live; bash tail patterns well-established)

---

## Summary

Phase 3 completes `gsd` by implementing `cmd_log`, `cmd_tail`, and `install.sh`. The CLI framework, color system, error handling, and subcommand dispatch are all fully in place from Phases 1 and 2. This phase addresses the remaining stubs in `cmd_log()` and `cmd_tail()`.

**Critical discovery during research:** The current `gsd` script calls `opencode session list --json` but the actual flag is `--format json`. The JSON schema returned also differs from what the code assumes (`title` not `name`, `updated` epoch ms not `updated_at` string, no `status` field). Phase 3's final-polish pass MUST fix `get_sessions()` and the functions that consume `SESSION_DATA` to use correct field names. This is a pre-existing bug that blocks `gsd status` from working correctly.

**Primary recommendation:** Implement Phase 3 in a single plan: fix `get_sessions()` bug, implement `cmd_log`, implement `cmd_tail`, and create `install.sh`. All patterns are proven; no new dependencies needed.

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| §2.4.1 | `gsd log` requires a session name positional argument | Already validated in `cmd_log()` stub — `local session="${1:-}"` guard |
| §2.4.2 | Invoke `opencode export` to retrieve session data | Verified: `opencode export <sessionID>` returns JSON with `.messages[]` |
| §2.4.3 | Strip raw JSON, present assistant messages and tool results readably | jq filter on `.messages[] | select(.info.role == "assistant") | .parts[] | select(.type == "text") | .text` |
| §2.4.4 | Fatal error if no session name | `die_usage` when `session` is empty — already in stub |
| §2.4.5 | Helpful error if session not found | `opencode export` fails/returns empty if session ID not found; handle gracefully |
| §2.5.1 | `gsd tail` requires a session name positional argument | Same pattern as `cmd_log` |
| §2.5.2 | Live-follow session output | Poll `/tmp/gsd-<session>.log` in a loop; `inotifywait` not available on this system |
| §2.5.3 | Use file polling or inotifywait | inotifywait NOT available — use polling loop only |
| §2.5.4 | Exit cleanly on Ctrl-C with trap | `trap 'printf "\n"; exit 0' INT` before the poll loop |
| §2.5.5 | Error if session not running or log file missing | Check `[[ -f "$log_file" ]]` before entering loop |
| §8.1 | `install.sh` symlinks gsd into `~/.local/bin/` | Standard pattern — verified approach |
| §8.2 | Create `~/.local/bin/` if needed | `mkdir -p "$HOME/.local/bin"` |
| §8.3 | Warn if not in PATH | `[[ ":${PATH}:" != *":$HOME/.local/bin:"* ]]` check |
| §8.4 | Verify symlink works after creation | `"$HOME/.local/bin/gsd" --version` test |
| §8.5 | Also usable as `./gsd` directly | Already works — just need `chmod +x` |
| §8.7 | Named `gsd`, no extension | Already correct |
| §8.8 | `chmod +x` enforced | `install.sh` does `chmod +x gsd` before symlinking |
</phase_requirements>

---

## Standard Stack

No new dependencies for Phase 3. All tools are already available:

### Core (inherited from Phases 1 and 2)
| Tool | Purpose | Status |
|------|---------|--------|
| `opencode export` | Export session data as JSON | Verified - outputs `{info, messages[]}` |
| `jq` | Parse export JSON, extract text parts | Already used throughout |
| `stat -c %Y` | Log file mtime (for tail staleness check) | Already in `check_stuck()` |
| `date +%s` | Current epoch for timing | Already used |
| `trap` | Clean exit on Ctrl-C for tail | Already in cleanup handler |
| `sleep` | Polling interval for tail | Built-in (bash external) |
| `ln -sf` | Create symlink in install.sh | Standard Unix |
| `mkdir -p` | Create ~/.local/bin/ | Standard Unix |

### inotifywait: NOT Available
**Verified:** `inotifywait` is not installed on this system. `gsd tail` MUST use polling (sleep loop) as its only strategy. No `inotifywait`-first with polling fallback needed — go straight to polling.

### No New Dependencies
Phase 3 introduces zero new external tools.

---

## Architecture Patterns

### What's Already Built (Phases 1 and 2)
```
gsd
├── Constants + color vars               ✅ Done
├── Utility: err(), warn(), debug(), die(), die_usage()  ✅ Done
├── Utility: cleanup(), trap, check_deps()               ✅ Done
├── Utility: format_duration()           ✅ Done
├── Formatting: print_header(), print_table_header(), truncate_str()  ✅ Done
├── Data: get_sessions(), get_running_sessions()         ✅ Done (but BUG: --json → --format json)
├── Data: get_queue_items(), check_stuck()               ✅ Done
├── Help: log_usage(), tail_usage()      ✅ Done
├── cmd_status()                         ✅ Complete (but SESSION_DATA field names wrong)
├── cmd_queue()                          ✅ Complete
├── cmd_stuck()                          ✅ Complete
├── cmd_log()                            ❌ Stub only — "coming in a future plan"
├── cmd_tail()                           ❌ Stub only — "coming in a future plan"
└── main() dispatch                      ✅ Done
```

### Verified: opencode export JSON Schema

Confirmed by running `opencode export <sessionID>` live:

```json
{
  "info": {
    "id": "ses_...",
    "title": "gsd-cli-exec-2",
    "time": { "created": 1771..., "updated": 1771... }
  },
  "messages": [
    {
      "info": {
        "role": "user" | "assistant",
        "time": { "created": 1771... }
      },
      "parts": [
        { "type": "text", "text": "..." },
        { "type": "step-start" },
        { "type": "step-finish" },
        { "type": "tool", "tool": "task", "state": { "status": "completed", "title": "..." } },
        { "type": "patch", "files": [...], "hash": "..." }
      ]
    }
  ]
}
```

**Key findings:**
- Assistant messages contain `parts` array with mixed types
- Only `type == "text"` parts have a `.text` field with readable content
- `type == "tool"` parts have `.tool` name and `.state.title` and `.state.status`
- `type == "step-start"`, `"step-finish"`, `"patch"` have no text content
- User messages are `role == "user"`, always have `type == "text"` parts

### Verified: opencode session list JSON Schema

**CRITICAL BUG DISCOVERED:** Current code uses `opencode session list --json` but:
- The correct flag is `opencode session list --format json`
- The JSON fields are: `id`, `title`, `updated` (epoch ms), `created` (epoch ms), `projectId`, `directory`
- There is **NO** `status`, `name`, `updated_at`, or `pid` field
- Sessions in the list have no running/completed status — opencode doesn't expose that

This means:
1. `get_sessions()` must use `--format json` not `--json`
2. `get_running_sessions()` filter by `.status == "running"` will never match — must be rethought
3. `get_completed_sessions()` filter by `.status == "completed"` will never match
4. Session identification for `gsd log` uses `title` field, not `name`

### Pattern: cmd_log() Session Lookup

The user provides a session name (e.g., `gsd log gsd-cli-exec-2`). We need to find the session ID:

```bash
cmd_log() {
  # ... flag parsing ...
  local session="${1:-}"
  [[ -z "${session}" ]] && die_usage "Missing required argument: <session>"

  # Look up session ID from title
  get_sessions
  local session_id
  session_id=$(printf '%s' "${SESSION_DATA}" | \
    jq -r --arg title "${session}" \
    '.[] | select(.title == $title or .id == $title) | .id' 2>/dev/null | head -1)

  if [[ -z "${session_id}" ]]; then
    die "Session not found: ${session}"
  fi

  # Export and render
  local export_json
  export_json=$(opencode export "${session_id}" 2>/dev/null) || \
    die "Failed to export session: ${session}"

  if [[ -z "${export_json}" ]]; then
    die "Session not found or empty: ${session}"
  fi

  # Render assistant messages (text parts only)
  printf '%s%s — Session Log%s\n' "${BOLD}" "${session}" "${RESET}"
  printf '%s%s%s\n\n' "${DIM}" "$(printf '%.0s─' {1..60})" "${RESET}"

  while IFS= read -r part_json; do
    local role text tool_name tool_status
    role=$(printf '%s' "${part_json}" | jq -r '.role' 2>/dev/null)
    text=$(printf '%s' "${part_json}" | jq -r '.text // empty' 2>/dev/null)
    tool_name=$(printf '%s' "${part_json}" | jq -r '.tool_name // empty' 2>/dev/null)
    tool_status=$(printf '%s' "${part_json}" | jq -r '.tool_status // empty' 2>/dev/null)

    if [[ -n "${text}" ]]; then
      if [[ "${role}" == "user" ]]; then
        printf '%s[User]%s %s\n\n' "${BOLD}${CYAN}" "${RESET}" "${text}"
      else
        printf '%s[Assistant]%s\n%s\n\n' "${BOLD}${GREEN}" "${RESET}" "${text}"
      fi
    elif [[ -n "${tool_name}" ]]; then
      printf '%s[Tool: %s] %s%s\n' "${DIM}" "${tool_name}" "${tool_status}" "${RESET}"
    fi
  done < <(printf '%s' "${export_json}" | jq -c '
    .messages[] |
    .info.role as $role |
    .parts[] |
    if .type == "text" then
      {role: $role, text: .text, tool_name: null, tool_status: null}
    elif .type == "tool" then
      {role: $role, text: null, tool_name: .tool, tool_status: (.state.status // "")}
    else
      empty
    end
  ' 2>/dev/null)
}
```

### Pattern: cmd_tail() Poll Loop

`inotifywait` is NOT available. Use a polling sleep loop:

```bash
cmd_tail() {
  # ... flag parsing ...
  local session="${1:-}"
  [[ -z "${session}" ]] && die_usage "Missing required argument: <session>"

  local log_file="${LOG_DIR}/gsd-${session}.log"

  if [[ ! -f "${log_file}" ]]; then
    die "No log file found for session '${session}': ${log_file}"
  fi

  # Clean Ctrl-C exit (§2.5.4)
  trap 'printf "\n%sStopped following %s%s\n" "${DIM}" "${session}" "${RESET}"; exit 0' INT

  printf '%sFollowing session: %s%s\n' "${BOLD}" "${session}" "${RESET}"
  printf '%s%s%s\n' "${DIM}" "$(printf '%.0s─' {1..60})" "${RESET}"
  printf '%s(Press Ctrl-C to stop)%s\n\n' "${DIM}" "${RESET}"

  # Use tail -f for live following — it handles SIGINT cleanly
  tail -f "${log_file}"
}
```

**Key insight:** `tail -f` is available on Linux and handles the polling internally at the OS level. It exits cleanly when the process receives SIGINT (Ctrl-C). Using `tail -f` is correct and simpler than a manual sleep loop. The trap on INT handles the exit message.

**Alternative (manual polling) — use if `tail -f` doesn't work:**
```bash
local pos=0
while true; do
  if [[ ! -f "${log_file}" ]]; then
    printf '%sLog file disappeared — session may have ended%s\n' "${YELLOW}" "${RESET}"
    exit 0
  fi
  local content
  content=$(tail -c +$((pos + 1)) "${log_file}" 2>/dev/null)
  if [[ -n "${content}" ]]; then
    printf '%s' "${content}"
    pos=$(wc -c < "${log_file}" 2>/dev/null || printf '%s' "${pos}")
  fi
  sleep 0.5
done
```

**Recommendation:** Use `tail -f` directly — it's simpler, battle-tested, and available on all Linux systems. The SIGINT trap provides the clean exit message.

### Pattern: install.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GSD_SCRIPT="${SCRIPT_DIR}/gsd"
INSTALL_DIR="${HOME}/.local/bin"
INSTALL_TARGET="${INSTALL_DIR}/gsd"

printf 'Installing gsd...\n'

# Ensure gsd exists and is executable
if [[ ! -f "${GSD_SCRIPT}" ]]; then
  printf 'Error: gsd script not found at %s\n' "${GSD_SCRIPT}" >&2
  exit 1
fi
chmod +x "${GSD_SCRIPT}"

# Create install directory if needed (§8.2)
mkdir -p "${INSTALL_DIR}"

# Create symlink (§8.1)
ln -sf "${GSD_SCRIPT}" "${INSTALL_TARGET}"

# Verify the symlink works (§8.4)
if ! "${INSTALL_TARGET}" --version &>/dev/null; then
  printf 'Error: symlink created but gsd --version failed\n' >&2
  exit 1
fi

printf '✓ Installed: %s → %s\n' "${INSTALL_TARGET}" "${GSD_SCRIPT}"

# Warn if ~/.local/bin not in PATH (§8.3)
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
  printf '\nWarning: %s is not in your PATH\n' "${INSTALL_DIR}"
  printf 'Add this to your shell config (~/.bashrc, ~/.zshrc, etc.):\n'
  printf '  export PATH="${HOME}/.local/bin:${PATH}"\n'
  printf 'Then reload: source ~/.bashrc\n'
fi

printf '\nDone! Run: gsd --help\n'
```

### Pattern: Fix get_sessions() Bug

The existing `get_sessions()` must be fixed to use `--format json`:

```bash
get_sessions() {
  local json
  # CORRECT: use --format json, not --json
  json=$(opencode session list --format json 2>/dev/null) || json="[]"

  if printf '%s' "${json}" | jq -e 'type == "array"' &>/dev/null; then
    SESSION_DATA="${json}"
  else
    debug "opencode session list returned invalid JSON; using empty session list"
    SESSION_DATA="[]"
  fi
}
```

And `get_running_sessions()` / `get_completed_sessions()` must be adapted since opencode sessions have no `status` field. Running sessions are identified by PID files, not opencode's session list. The `gsd status` dashboard should show sessions from `opencode session list` as "recent" (not "running") — actual running detection comes from PID files.

**Updated approach for `get_running_sessions()`:**
- Return sessions that have a matching `/tmp/gsd-<title>.log` file or `/tmp/gsd-<title>-pid` file
- OR: return all sessions and mark them with running status based on PID file presence

**Simplest fix:** In `cmd_status`, use the PID file scan (like `cmd_stuck`) to find truly running sessions, and show opencode session list as "recent sessions" with formatted timestamps.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Session transcript rendering | Custom markdown parser | `jq` filter on `.messages[].parts[] | select(.type == "text") | .text` | JSON already structured; jq handles it |
| Live file following | Manual poll loop with read offsets | `tail -f` | Available on all Linux, handles buffering, exits cleanly |
| Install directory detection | Complex PATH manipulation | `"${HOME}/.local/bin"` direct | Standard user-level install location |
| Session lookup | Fuzzy matching | Exact `.title` or `.id` match via jq | Simple, predictable, user controls session naming |

---

## Common Pitfalls

### Pitfall 1: opencode session list --json vs --format json
**What goes wrong:** `opencode session list --json` outputs the help page, not JSON. `get_sessions()` gets help text, jq type check fails, SESSION_DATA stays `"[]"`, status dashboard shows nothing.
**Why it happens:** opencode uses `--format json` not `--json`.
**How to avoid:** Use `opencode session list --format json`. Fix `get_sessions()` in Phase 3.
**Warning signs:** `gsd status` shows 0 running sessions even when sessions exist.

### Pitfall 2: Session Name vs Session ID in gsd log
**What goes wrong:** User passes session `title` (e.g., `gsd-cli-exec-2`) but `opencode export` needs the session `id` (e.g., `ses_3948bbb2dffe...`).
**How to avoid:** `cmd_log` must look up session by title from `SESSION_DATA`, then call `opencode export "${session_id}"`.
**Warning signs:** `opencode export my-session` returns empty output.

### Pitfall 3: tail -f and the cleanup trap conflict
**What goes wrong:** The global `trap cleanup EXIT` in the main script also fires when `tail -f` is interrupted. The Ctrl-C INT trap in `cmd_tail` fires, then EXIT fires too.
**How to avoid:** The `cleanup()` function only removes `TMPFILE` if set — it won't cause issues. The INT trap should `exit 0` which triggers EXIT/cleanup but that's fine (TMPFILE isn't set for tail). Add `printf` message in INT handler BEFORE `exit 0`.
**Warning signs:** Double-output messages on Ctrl-C.

### Pitfall 4: opencode export empty output for invalid session
**What goes wrong:** `opencode export bad-session-id` may output empty string or an error to stderr. If we pipe it directly to jq, jq will fail on empty input.
**How to avoid:** Capture output, check if empty BEFORE passing to jq. Use `[[ -z "${export_json}" ]]` check.
**Warning signs:** `jq` parse errors in `cmd_log`.

### Pitfall 5: install.sh relative path symlink
**What goes wrong:** `ln -sf gsd ~/.local/bin/gsd` creates a relative symlink. When the user `cd`s away from the repo, the symlink is broken.
**How to avoid:** Always use absolute path: `ln -sf "${SCRIPT_DIR}/gsd" "${INSTALL_DIR}/gsd"`. Get `SCRIPT_DIR` with `"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`.
**Warning signs:** `gsd: no such file or directory` after installation.

### Pitfall 6: SESSION_DATA field name mismatch
**What goes wrong:** Current `gsd status` code uses `.id // .name` but session list has no `.name` field. `.updated_at` doesn't exist — it's `.updated` (epoch ms). `.status` doesn't exist.
**How to avoid:** In Phase 3 polish pass, update all `SESSION_DATA` consumers to use:
- `.title` for session name/title
- `.id` for session ID  
- `.updated` for timestamp (epoch ms → human readable)
- No `.status` — use PID file presence

### Pitfall 7: Local variable declaration shadowing in cmd_log loop
**What goes wrong:** `while IFS= read -r part_json; do local role text...; done` — `local` inside a loop re-declares the variable each iteration (fine in bash, but using `local` inside a loop body is style anti-pattern per Google style guide).
**How to avoid:** Declare locals before the loop, assign inside.

---

## Code Examples

### Verified: opencode export jq filter for readable output
```bash
# Source: verified by running opencode export live on this system
printf '%s' "${export_json}" | jq -r '
  .messages[] |
  .info.role as $role |
  .parts[] |
  if .type == "text" then
    (if $role == "user" then "[User] " else "[Assistant]\n" end) + .text
  elif .type == "tool" then
    "[Tool: " + (.tool // "unknown") + "] " + (.state.status // "")
  else
    empty
  end
' 2>/dev/null
```

### Verified: get_sessions() fix
```bash
# Source: verified opencode CLI — correct flag is --format json
get_sessions() {
  local json
  json=$(opencode session list --format json 2>/dev/null) || json="[]"
  if printf '%s' "${json}" | jq -e 'type == "array"' &>/dev/null; then
    SESSION_DATA="${json}"
  else
    debug "opencode session list returned invalid JSON; using empty session list"
    SESSION_DATA="[]"
  fi
}
```

### Verified: install.sh absolute symlink pattern
```bash
# Source: standard bash script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "${SCRIPT_DIR}/gsd" "${HOME}/.local/bin/gsd"
```

### Verified: cmd_tail with tail -f
```bash
# Source: POSIX tail -f — available on all Linux, including this system
trap 'printf "\n%sStopped following %s%s\n" "${DIM}" "${session}" "${RESET}"; exit 0' INT
tail -f "${log_file}"
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| `opencode session list --json` (broken) | `opencode session list --format json` | Fixes status dashboard |
| `inotifywait` for file watching | `tail -f` (inotifywait not available) | Simpler, always works |
| Display `.name`/`.updated_at` from session list | Display `.title`/`.updated` (epoch ms) | Correct field names |

**Deprecated/wrong:**
- `opencode session list --json`: Does NOT produce JSON — outputs help text. Use `--format json`.

---

## Open Questions

1. **Session title vs ID for gsd log** — User must provide a title (human-readable) or ID?
   - **What we know:** `opencode export` accepts session ID. Session list returns `id` and `title`.
   - **Recommendation:** Accept both — try as `title` match first, fall back to `id` match. This gives the best UX.

2. **gsd status "running" sessions** — How to identify truly running sessions (no status field in opencode)?
   - **What we know:** PID files at `/tmp/gsd-*-pid` indicate running sessions. Session list has no `status`.
   - **Recommendation:** In `get_running_sessions()`, cross-reference session titles from `SESSION_DATA` with existing PID files. OR: use PID file scan as the authoritative source of "running" and only use `SESSION_DATA` for metadata (title display).
   - **Phase 3 scope:** Polish pass to fix `cmd_status` field names. Running detection via PID files is already in `check_stuck()`.

3. **gsd log --json output format** — What JSON shape to produce?
   - **What we know:** Must include `timestamp` (§3.5.2) and structured data (§3.5.3).
   - **Recommendation:** `{timestamp, session_id, session_title, messages: [{role, text}]}`

---

## Sources

### Primary (HIGH confidence)
- Live `opencode export <sessionID>` output — verified JSON schema directly
- Live `opencode session list --format json` — verified correct flag and field names
- `opencode --help`, `opencode export --help`, `opencode session list --help` — all verified live
- Existing `gsd` script (Phase 1+2 implementation) — read lines 1–1080
- `REQUIREMENTS.md` §2.4, §2.5, §8 — authoritative spec

### Secondary (MEDIUM confidence)
- `inotifywait` absence confirmed by `which inotifywait` check
- `tail -f` availability confirmed — standard GNU coreutils on Linux
- Bash `trap` INT + EXIT interaction — from Google Shell Style Guide patterns

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new dependencies, all tools verified on this system
- Architecture: HIGH — patterns verified against live opencode output
- Pitfalls: HIGH — opencode --json bug found during live research (critical discovery)
- opencode export schema: HIGH — verified by running against real sessions

**Research date:** 2026-02-17
**Valid until:** 2026-03-17 (opencode schema could change with new releases; verify if opencode is upgraded)
