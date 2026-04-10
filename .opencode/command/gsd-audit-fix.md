---
description: Run audit and fix issues found in codebase
argument-hint: "[--dry-run] [scope]"
tools:
  read: true
  bash: true
  write: true
  task: true
  glob: true
  grep: true
---
<objective>
Run comprehensive audit on the codebase and automatically fix identified issues.

Scans for security vulnerabilities, dependency issues, code style violations, unused code, and configuration problems. Applies fixes where safe, reports on items requiring manual intervention.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/audit-fix.md
</execution_context>

<context>
$ARGUMENTS

**Flags:**
- `--dry-run` — Report issues without applying fixes
- `[scope]` — Limit audit to specific area (e.g., 'deps', 'security', 'style')
</context>

<process>
Execute the audit-fix workflow from @./.opencode/get-shit-done/workflows/audit-fix.md end-to-end.
Preserve all workflow gates (scan, categorize, fix, verify, report).
</process>

<success_criteria>
- [ ] Codebase scanned for issues
- [ ] Issues categorized by severity
- [ ] Safe fixes applied automatically
- [ ] Report generated for manual items
- [ ] STATE.md updated with audit results
</success_criteria>
