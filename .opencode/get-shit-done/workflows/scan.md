<purpose>
Scan the codebase for specific patterns, issues, dependencies, or structural elements.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_target">
**Determine scan target:** Parse $ARGUMENTS for scan type and target. If no args, offer scan menu (security, deps, api, tests, todos, dead, patterns).
</step>

<step name="run_scan">
**Execute the scan:** Run appropriate searches for the determined scan type. For custom patterns, use grep.
</step>

<step name="aggregate">
**Aggregate results:** Group by file, pattern type, severity, frequency. Remove duplicates and false positives.
</step>

<step name="report">
**Display scan report:** Show scan type, files scanned, findings count, findings grouped by category with severity summary.
</step>

</process>

<success_criteria>
- [ ] Scan target determined
- [ ] Appropriate searches executed
- [ ] Results aggregated and deduplicated
- [ ] Report displayed clearly
- [ ] Actionable findings highlighted
</success_criteria>
