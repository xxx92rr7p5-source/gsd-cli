<purpose>
Generate a concise summary of milestone completion status.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_milestone">
**Load milestone context:** Load ROADMAP.md, STATE.md, REQUIREMENTS.md for the target milestone.
</step>

<step name="analyze_phases">
**Analyze phase completion:** For each phase, count plans and summaries. Track completed/in-progress/not-started.
</step>

<step name="compare_planned_vs_delivered">
**Compare planned vs. delivered:** From REQUIREMENTS.md check which are delivered. Calculate coverage percentages.
</step>

<step name="extract_decisions">
**Extract key decisions:** From STATE.md, collect decisions grouped by category.
</step>

<step name="identify_open_issues">
**Identify open issues:** Known bugs, deferred features, tech debt, open questions.
</step>

<step name="generate_summary">
**Generate milestone summary:** Write structured report with progress, planned vs delivered, decisions, open issues, health assessment.
</step>

</process>

<success_criteria>
- [ ] Milestone context loaded
- [ ] All phases analyzed
- [ ] Planned vs. delivered compared
- [ ] Key decisions extracted
- [ ] Open issues identified
- [ ] Summary report generated
- [ ] Health assessment provided
</success_criteria>
