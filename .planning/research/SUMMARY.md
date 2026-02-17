# Research Summary: gsd-cli

**Domain:** Bash CLI tool (pipeline monitoring)
**Researched:** 2026-02-17
**Overall confidence:** HIGH

## Executive Summary

Building a polished bash CLI tool is well-supported by mature patterns established in the shell ecosystem over decades. The git-style subcommand pattern (manual `case` dispatch + per-subcommand `getopts`) is the proven approach for tools like gsd-cli, used by git itself, docker, kubectl, and most serious CLI tools. `getopts` is the right choice for flag parsing within each subcommand, while the top-level subcommand routing uses simple `case` matching on `$1`.

The core stack is minimal: bash 5.x, jq for JSON processing, printf for formatted output, and ANSI escape codes for colors. This is a strength -- few dependencies means fast execution and easy installation. The < 2 second target for `gsd status` is achievable by avoiding subshells, caching `opencode` command output, and using bash builtins over external commands wherever possible.

The biggest risk is scope creep toward complexity that would warrant a rewrite in a "real" language. Google's Shell Style Guide explicitly warns: scripts over 100 lines should be rewritten. We should ignore this for a CLI wrapper tool -- gsd-cli is exactly the right use case for bash (calling other CLI tools, parsing their output, formatting results). But we should watch for signs we're fighting the language (complex data structures, error handling chains, state management).

Installation is trivial: a single file with `#!/usr/bin/env bash`, `chmod +x`, and a symlink into `~/.local/bin` or `/usr/local/bin`. No package manager needed for a personal/team tool.

## Key Findings

**Stack:** Bash 5.x + jq 1.7+ for JSON, printf for output, ANSI escapes for color
**Architecture:** Single-file CLI with `main()` dispatch, per-subcommand functions, shared color/utility library
**Critical pitfall:** Unquoted variable expansions causing word splitting -- the #1 source of bash bugs

## Implications for Roadmap

Based on research, suggested phase structure:

1. **Foundation & Status** - Core script structure, color system, `gsd status` command
   - Addresses: Script skeleton, argument parsing, terminal colors, JSON parsing
   - Avoids: Over-engineering before we know the real output format

2. **Queue & Stuck Detection** - `gsd queue` and `gsd stuck` commands
   - Addresses: QUEUE.md parsing, process monitoring, kill functionality
   - Avoids: Premature optimization

3. **Log & Tail** - `gsd log` and `gsd tail` commands
   - Addresses: opencode export integration, live following
   - Avoids: Building tail before understanding opencode's output format

4. **Polish & Install** - Installation, help text, edge cases
   - Addresses: Global installation, error messages, man page / --help
   - Avoids: Shipping without proper error handling

**Phase ordering rationale:**
- Status first because it exercises all subsystems (colors, jq, printf formatting)
- Queue/stuck next because they share process-monitoring infrastructure
- Log/tail last because they depend on understanding opencode's export format
- Polish at end to capture all edge cases discovered during development

**Research flags for phases:**
- Phase 1: Standard patterns, unlikely to need more research
- Phase 3: Likely needs deeper research into `opencode export` output format
- Phase 3: `tail -f` equivalent in bash needs careful implementation (inotifywait vs polling)

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | bash + jq is battle-tested, verified on target system |
| Features | HIGH | Requirements are clear from idea.md |
| Architecture | HIGH | Git-style subcommand pattern is well-documented |
| Pitfalls | HIGH | Bash pitfalls are extensively catalogued (Greg's Wiki, Google Style Guide) |
| Performance | MEDIUM | < 2s target depends on opencode command latency (untested) |

## Gaps to Address

- `opencode session list` output format needs verification during Phase 1
- `opencode export` output format needs verification during Phase 3
- Whether `opencode stats` exists and what it returns
- Exact format of `/tmp/gsd-*.log` files
- Whether `tail -f` on log files is sufficient or if inotifywait is needed
