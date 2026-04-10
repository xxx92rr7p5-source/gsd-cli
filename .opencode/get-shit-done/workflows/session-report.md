<purpose>
Generate a comprehensive report of work done in a session.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_context">
**Load session context:** Load STATE.md. Extract session start time, current position, recent activity.
</step>

<step name="analyze_changes">
**Analyze changes made:** Get commits since session start, files changed, current uncommitted changes. Group by area/feature.
</step>

<step name="extract_decisions">
**Extract decisions made:** From STATE.md decisions section, identify decisions made during this session with rationale.
</step>

<step name="assess_tests">
**Assess test impact:** Check test files changed. Run test suite. Report tests added/modified, status, coverage changes.
</step>

<step name="generate_report">
**Generate session report:** Write to .planning/sessions/[date]-report.md with changes, decisions, files modified, test status, context for next session.
</step>

<step name="display">
**Display summary:** Show key highlights. Offer to save full report and update STATE.md.
</step>

</process>

<success_criteria>
- [ ] Session context loaded
- [ ] All changes analyzed
- [ ] Decisions documented
- [ ] Test impact assessed
- [ ] Report generated
- [ ] Context captured for handoff
</success_criteria>
