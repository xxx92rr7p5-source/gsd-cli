---
description: Scan codebase for patterns, issues, or structure
argument-hint: "[scan target or pattern]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
---
<objective>
Scan the codebase for specific patterns, issues, dependencies, or structural elements.

Fast, targeted scans for code patterns, security issues, dependency usage, API surface, or any queryable aspect of the codebase. Results are structured and actionable.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/scan.md
</execution_context>

<context>
Scan target: $ARGUMENTS
</context>

<process>
Execute the scan workflow from @./.opencode/get-shit-done/workflows/scan.md end-to-end.
Preserve scan targeting, pattern matching, result aggregation, and reporting.
</process>

<success_criteria>
- [ ] Scan scope defined
- [ ] Patterns searched
- [ ] Results aggregated
- [ ] Report generated with actionable findings
</success_criteria>
