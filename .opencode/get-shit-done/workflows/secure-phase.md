<purpose>
Execute a security-hardening phase across the codebase.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="scope">
**Define security scope:** Parse $ARGUMENTS for specific focus. If none, run full audit across all dimensions: input validation, auth, authorization, data protection, dependencies, configuration, infrastructure.
</step>

<step name="scan">
**Run security scan:** For each dimension, run targeted scans (npm audit, secret scanning, pattern matching). Spawn security analysis agents for deep review.
</step>

<step name="prioritize">
**Prioritize findings:** Critical (exploitable vulns), High (missing auth), Medium (config issues), Low (best practice gaps).
</step>

<step name="harden">
**Apply hardening:** For each finding, apply fix, run tests, commit with security-focused message. Confirm critical/high with user (unless YOLO).
</step>

<step name="add_tests">
**Add security tests:** Create input validation tests, auth bypass tests, permission boundary tests, error handling tests.
</step>

<step name="report">
**Generate security report:** Write to .planning/security-report.md with findings summary, fixes applied, remaining issues, tests added.
</step>

</process>

<success_criteria>
- [ ] All security dimensions scanned
- [ ] Findings prioritized by severity
- [ ] Critical/high issues fixed
- [ ] Security tests added
- [ ] Security report generated
- [ ] Remaining issues documented for manual action
</success_criteria>
