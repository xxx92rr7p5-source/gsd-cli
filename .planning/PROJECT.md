# gsd-cli — Pipeline Monitoring Tool

## Overview
A bash CLI tool that gives instant visibility into opencode GSD pipeline runs. Like `htop` for our build pipeline.

## Core Commands
- `gsd status` — dashboard showing running, stuck, queued, completed
- `gsd queue` — pretty-print QUEUE.md
- `gsd stuck` — find hung processes, optionally kill them
- `gsd log <session>` — readable session transcript
- `gsd tail <session>` — live-follow session output

## Technical Decisions
- Single bash script (no node/python dependency beyond opencode + jq)
- Uses opencode CLI (session list, export, stats) under the hood
- Convention over configuration
- ANSI colors with NO_COLOR support

## Scope
- CLI output only (no TUI)
- Works from any directory
- Fast (< 2 seconds for status)
