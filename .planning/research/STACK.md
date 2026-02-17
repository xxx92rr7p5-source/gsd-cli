# Technology Stack

**Project:** gsd-cli
**Researched:** 2026-02-17

## Recommended Stack

### Core Runtime
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Bash | 5.2+ | Script runtime | Available everywhere, perfect for CLI wrappers. Google Style Guide: "Bash is the only shell scripting language permitted for executables" |
| jq | 1.7+ | JSON parsing | The standard CLI JSON processor. Essential for parsing `opencode` output. Already installed on target system |

### Formatting & Output
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| printf | (builtin) | Formatted output | Bash builtin, no subprocess. Supports field width, alignment. Preferred over echo for formatted output |
| ANSI escapes | - | Terminal colors | Universal terminal support. No dependency needed |
| column | util-linux 2.39+ | Table alignment | Available on Linux, useful for dynamic column widths. Fallback to printf if unavailable |

### Process Monitoring
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| ps | (system) | Process status | Check if PIDs are alive, get runtime |
| kill | (builtin) | Signal processes | For `gsd stuck --kill` |
| stat | (system) | File timestamps | Detect log file staleness for stuck detection |
| date | (system) | Time calculations | Duration formatting, staleness checks |

### Installation
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| ln -s | (system) | Symlink into PATH | Simplest installation method |
| chmod | (system) | Make executable | Required for direct execution |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Language | Bash | Node.js | Bash is faster for CLI wrappers (no runtime startup), fewer dependencies, simpler installation |
| Language | Bash | Python | Same reasons as Node.js. gsd-cli is a thin wrapper, not a data processing tool |
| JSON parser | jq | python -c 'import json...' | jq is purpose-built, faster, more readable for JSON pipelines |
| JSON parser | jq | bash-only JSON parsing | Fragile, slow, unmaintainable. jq is the right tool |
| Colors | ANSI escapes | tput | ANSI codes are faster (no subprocess), more portable in practice, easier to read in code |
| Arg parsing | getopts (builtin) | getopt (external) | getopts is POSIX, portable, no subprocess. getopt varies between GNU and BSD |
| Arg parsing | getopts + case | argparse libraries | External deps add complexity. Our flag set is small enough for getopts |
| Tables | printf | column -t | printf gives exact control. column is good for dynamic data but less predictable |

## No External Dependencies Beyond jq

The tool should have exactly ONE external dependency: `jq`. Everything else is either a bash builtin or a standard Unix utility. This keeps installation trivial and execution fast.

## Dependency Check Pattern

```bash
# Check at startup, fail fast with helpful message
check_deps() {
  if ! command -v jq &>/dev/null; then
    printf '%s\n' "Error: jq is required but not installed." >&2
    printf '%s\n' "Install: sudo apt install jq  (or brew install jq)" >&2
    return 1
  fi
  if ! command -v opencode &>/dev/null; then
    printf '%s\n' "Error: opencode is required but not installed." >&2
    printf '%s\n' "See: https://github.com/sst/opencode" >&2
    return 1
  fi
}
```

## Sources

- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- jq Manual: https://jqlang.github.io/jq/manual/
- System verification: bash 5.2.21, jq 1.7, column util-linux 2.39.3
