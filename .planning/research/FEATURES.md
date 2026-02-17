# Feature Landscape

**Domain:** CLI pipeline monitoring tool
**Researched:** 2026-02-17

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| `gsd status` dashboard | Core value prop - at-a-glance view | Medium | Needs opencode + process + queue data |
| Colored output | CLI tools without color feel broken | Low | ANSI escape codes |
| `--help` / help text | Users will type `gsd --help` immediately | Low | Per-subcommand help too |
| Error messages to stderr | POSIX convention, enables piping | Low | All errors via `err()` function |
| `gsd queue` | QUEUE.md is the central workflow artifact | Low | Parse markdown, color by status |
| `gsd stuck` | The pain point that motivated the tool | Medium | Process monitoring + log staleness |
| `gsd stuck --kill` | Natural follow-up to finding stuck processes | Low | kill PID after confirmation |
| Exit codes | Scripts/automation need reliable exit codes | Low | 0=success, 1=error, 2=usage error |
| Fast execution (< 2s) | CLI tools must feel instant | Medium | Avoid unnecessary subprocesses |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| `gsd log <session>` | Readable view of opencode sessions | Medium | Strip JSON, show assistant messages |
| `gsd tail <session>` | Live-follow running sessions | High | Needs file watching or polling |
| `--json` output flag | Machine-readable output for scripting | Low | Output raw JSON instead of formatted |
| `--verbose` flag | Detailed view when debugging | Low | Show PIDs, full paths, timestamps |
| Automatic stuck detection in status | Highlight stuck items without separate command | Low | Reuse stuck logic in status display |
| Duration formatting | "2h 15m" instead of seconds | Low | Human-readable time deltas |
| No-config design | Works immediately, no setup | Low | Convention over configuration |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| TUI / curses interface | Adds massive complexity, fragile | Simple printed output, re-run to refresh |
| Config files | Complexity for no gain in a small tool | Hardcode conventions, use env vars for overrides |
| Daemon mode | Background process management is hard | Just run `gsd status` when you want to check |
| Log rotation / cleanup | Out of scope, /tmp handles this | Let OS clean /tmp |
| Session management | opencode handles this | Wrap opencode, don't replace it |
| Color themes | Over-engineering | Pick good defaults, respect NO_COLOR |
| Plugin system | Way over-engineering | Single-file tool |
| Auto-update | Complexity for a team tool | git pull |

## Feature Dependencies

```
Color system ─────────────────────┐
                                  ├──> gsd status
Argument parsing ─────────────────┤
                                  ├──> gsd queue
JSON parsing (jq) ────────────────┤
                                  ├──> gsd stuck ──> gsd stuck --kill
Process monitoring ───────────────┘
                                  
opencode export parsing ──────────┬──> gsd log
                                  │
File watching / polling ──────────┴──> gsd tail
```

## MVP Recommendation

Prioritize:
1. `gsd status` - exercises all subsystems, delivers core value
2. `gsd stuck` - solves the original pain point (lost 4 hours)
3. `gsd queue` - quick win, simple markdown parsing

Defer:
- `gsd log`: Needs opencode export format investigation
- `gsd tail`: Most complex feature, needs file watching. Build last
- `--json` output: Nice-to-have, add after core commands work

## Sources

- idea.md project specification
- Common CLI tool conventions (git, docker, kubectl patterns)
