<purpose>
Run comprehensive audit on the codebase and automatically fix identified issues.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_args">
**Parse arguments:** Check for --dry-run flag and optional scope.
</step>

<step name="scan">
**Run comprehensive scan:**
For each audit dimension: dependencies, security, style, dead code, configuration, tests.
Collect all issues with severity, location, and suggested fix.
</step>

<step name="categorize">
**Categorize findings:** Auto-fixable, Review-needed, Manual-only.
</step>

<step name="apply_fixes">
**Apply automatic fixes (unless --dry-run):**
For each auto-fixable issue: apply fix, run tests, commit with descriptive message.
If tests fail, revert and flag. If --dry-run, display what would be fixed.
</step>

<step name="report">
**Generate audit report:** Write to .planning/audit-report.md with findings summary. Display to user.
</step>

<step name="update_state">
**Update STATE.md:** Record audit results with date, issue counts, and fix count.
</step>

</process>

<success_criteria>
- [ ] Codebase scanned across all dimensions
- [ ] Issues categorized by fixability
- [ ] Auto-fixes applied safely (unless --dry-run)
- [ ] Report generated with all findings
- [ ] STATE.md updated
</success_criteria>
