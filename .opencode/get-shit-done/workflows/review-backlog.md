<purpose>
Review and triage backlog items to prioritize work.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_backlog">
**Load backlog items:** Scan .planning/backlog/. Extract ID, title, priority, area, type, status, date. If no backlog, suggest /gsd-add-backlog.
</step>

<step name="filter">
**Apply filters:** If $ARGUMENTS provided, filter by area, priority, type, or status. Otherwise show all.
</step>

<step name="display">
**Display backlog:** Show table with ID, priority, type, area, title, age. Group by priority.
</step>

<step name="triage">
**Triage items:** For each item offer: prioritize, defer, reject, split, accept.
</step>

<step name="apply_changes">
**Apply triage decisions:** Update backlog item files. Move rejected to rejected/. Create todo for accepted items.
</step>

<step name="report">
**Report results:** Show processed counts and remaining pending. Offer to start working on accepted items.
</step>

</process>

<success_criteria>
- [ ] All backlog items loaded
- [ ] Filter applied (if requested)
- [ ] Items displayed with key metadata
- [ ] Triage decisions captured
- [ ] Changes applied to backlog files
- [ ] Results reported
</success_criteria>
