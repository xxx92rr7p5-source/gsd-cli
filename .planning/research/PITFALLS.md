# Domain Pitfalls

**Domain:** Bash CLI tool development
**Researched:** 2026-02-17

## Critical Pitfalls

Mistakes that cause rewrites or major issues.

### Pitfall 1: Unquoted Variable Expansions
**What goes wrong:** Variables containing spaces, globs, or empty strings break commands silently. `cp $file $target` with `file="my document.txt"` runs `cp my document.txt target` (3 args, not 2).
**Why it happens:** Bash does word splitting and glob expansion on unquoted expansions. Developers from other languages don't expect this.
**Consequences:** Silent data corruption, wrong files deleted, commands fail intermittently depending on filenames/content.
**Prevention:** ALWAYS quote: `"${var}"`. Use `[[ ]]` not `[ ]`. Use `"$@"` not `$*`. Run ShellCheck on every commit.
**Detection:** ShellCheck catches most instances. Look for any `$var` without quotes.
**Source:** BashPitfalls #2, #4, #14, #24, #36. Google Shell Style Guide "Quoting" section.

### Pitfall 2: Pipe Subshell Variable Scope
**What goes wrong:** Variables set inside `cmd | while read` loops don't persist after the loop. You think you counted items but `count` is still 0.
**Why it happens:** Each segment of a pipeline runs in a separate subshell. Variable changes in subshells don't propagate to the parent.
**Consequences:** Logic bugs that are extremely confusing to debug. Counter variables stay at 0, flags stay unset.
**Prevention:** Use process substitution: `while read -r line; do ...; done < <(cmd)`. Or use `readarray`.
**Detection:** Any `| while` pattern is suspicious. Search for it.
**Source:** BashPitfalls #8. Google Shell Style Guide "Pipes to While".

### Pitfall 3: set -e Surprises (errexit)
**What goes wrong:** `set -e` causes script to exit on unexpected commands. `(( i++ ))` when `i=0` evaluates to 0 (falsy), which `set -e` treats as failure, killing the script.
**Why it happens:** `set -e` exit behavior is complex: it doesn't trigger in `if` conditions, `&&`/`||` chains, or subshells, but DOES trigger in arithmetic expressions that evaluate to 0.
**Consequences:** Script exits silently at hard-to-predict points. Debugging is painful because the exit point varies with data.
**Prevention:** Use `set -euo pipefail` but understand the gotchas. Use `|| true` after arithmetic that might be 0. Test error paths explicitly. Never rely solely on `set -e` -- use explicit error checks for important operations.
**Detection:** Test with edge-case data (empty strings, zero values, missing files).
**Source:** BashPitfalls #66 (set -euo pipefail section).

### Pitfall 4: local Masks Exit Codes
**What goes wrong:** `local var=$(some_cmd)` always succeeds because `local` returns 0, masking the command's exit code.
**Why it happens:** `local` is a command itself. Its return code (always 0) overwrites `$?`.
**Consequences:** Error handling with `$?` after `local var=$(cmd)` never detects failures. Silent data loss.
**Prevention:** Separate declaration and assignment: `local var; var=$(some_cmd)`.
**Detection:** Search for `local.*=.*\$(` pattern.
**Source:** BashPitfalls #27. Google Shell Style Guide.

## Moderate Pitfalls

### Pitfall 5: Parsing ls Output
**What goes wrong:** `for f in $(ls /tmp/gsd-*.log)` breaks on filenames with spaces, globs, or special characters.
**Prevention:** Use globs directly: `for f in /tmp/gsd-*.log; do [[ -e "$f" ]] || continue`. Or `find ... -print0 | while IFS= read -r -d ''`.
**Source:** BashPitfalls #1.

### Pitfall 6: echo -e Portability
**What goes wrong:** `echo -e "\033[31m"` works in bash but not in all POSIX shells. Some shells print the literal `-e`.
**Prevention:** Use `printf` for all formatted output. Use `$'\033[31m'` for ANSI codes in variable assignments.
**Source:** BashPitfalls #14. Google Shell Style Guide.

### Pitfall 7: cd Without Error Check
**What goes wrong:** `cd /some/dir; rm -rf *` runs `rm` in the WRONG directory if `cd` fails.
**Prevention:** Always `cd /dir || die "message"` or run in subshell `(cd /dir && do_stuff)`.
**Source:** BashPitfalls #19.

### Pitfall 8: Race Conditions in Process Monitoring
**What goes wrong:** PID checked with `ps`, found alive, then process exits before `kill`. Or: PID reused by different process.
**Prevention:** Always handle `kill` failures gracefully. Check process name matches expected pattern. Don't assume PIDs are stable over time.
**Detection:** Test with processes that exit quickly.

### Pitfall 9: jq Not Installed
**What goes wrong:** Script fails with cryptic "command not found" deep in execution.
**Prevention:** Check dependencies at startup with `command -v jq &>/dev/null || die "jq required"`. Provide install instructions in error message.

### Pitfall 10: Temp File Cleanup
**What goes wrong:** Temp files left behind on error/interrupt, filling /tmp over time.
**Prevention:** Use `trap cleanup EXIT`. Create temps with `mktemp`. Clean up in trap handler.

### Pitfall 11: Color Codes in Piped/Redirected Output
**What goes wrong:** ANSI escape codes appear as garbage when output is piped to another command or redirected to a file.
**Prevention:** Check `[[ -t 1 ]]` (stdout is a TTY) before enabling colors. Respect `NO_COLOR` env var. Disable colors in `--json` mode.
**Source:** NO_COLOR convention (https://no-color.org/).

## Minor Pitfalls

### Pitfall 12: Forgetting `--` in Commands
**What goes wrong:** Filenames starting with `-` are interpreted as flags. `rm $file` when file is `-rf` is catastrophic.
**Prevention:** Use `--` to separate options from arguments: `rm -- "${file}"`. Or prefix paths: `./${file}`.
**Source:** BashPitfalls #3.

### Pitfall 13: Integer Comparison with String Operators
**What goes wrong:** `[[ $a > 7 ]]` does string comparison, not numeric. "9" > "7" but "10" < "7" (lexicographic).
**Prevention:** Use `(( a > 7 ))` for numeric comparison, or `[[ $a -gt 7 ]]`.
**Source:** BashPitfalls #7.

### Pitfall 14: Heredoc Indentation
**What goes wrong:** Using `<<EOF` with indented content includes the indentation in the string.
**Prevention:** Use `<<-EOF` with tab indentation (not spaces) to strip leading tabs.

### Pitfall 15: QUEUE.md Format Changes
**What goes wrong:** Hardcoded QUEUE.md parsing breaks when someone changes the markdown format.
**Prevention:** Use flexible regex patterns. Handle missing/malformed lines gracefully. Show raw line on parse failure rather than crashing.

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Script foundation | set -e surprises | Test arithmetic edge cases, understand errexit rules |
| Color output | Colors in pipes | TTY detection + NO_COLOR from day 1 |
| Status command | jq parse failures | Validate JSON before processing, fallback messages |
| Status command | opencode not running | Handle empty session list gracefully |
| Queue parsing | QUEUE.md not found | Check file exists, show helpful error |
| Stuck detection | PID race conditions | Handle stale PIDs, verify process names |
| Stuck --kill | Killing wrong process | Confirm PID matches expected pattern before kill |
| Log command | opencode export format unknown | Research format before implementing, handle variations |
| Tail command | No inotifywait | Fall back to polling with `sleep` |
| Installation | PATH conflicts | Check for existing `gsd` command, warn user |

## Sources

- BashPitfalls (comprehensive): https://mywiki.wooledge.org/BashPitfalls
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- GNU Bash Manual: trap, set builtin documentation
- NO_COLOR convention: https://no-color.org/
