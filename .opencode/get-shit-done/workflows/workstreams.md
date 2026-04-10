<purpose>
Create, manage, and coordinate workstreams within a project.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_action">
**Determine workstream action:** Parse $ARGUMENTS: create, list, status, assign, complete. If none, show current workstreams.
</step>

<step name="create_workstream">
**Create a new workstream:** Create .planning/workstreams/. Write workstream file with name, status, description, assigned phases, dependencies, progress.
</step>

<step name="list_workstreams">
**List workstreams:** Scan .planning/workstreams/. Display table with name, status, phases, progress, dependencies.
</step>

<step name="show_status">
**Show workstream status:** Load workstream file. Show assigned phases with status, dependencies, blockers, recent progress.
</step>

<step name="manage_dependencies">
**Manage dependencies:** Check for circular dependencies, verify dependency workstreams exist, note blocking relationships.
</step>

<step name="coordinate">
**Cross-workstream coordination:** Identify spanning phases, coordination points, conflicts, shared deliverables.
</step>

</process>

<success_criteria>
- [ ] Workstream action identified
- [ ] Action executed correctly
- [ ] Workstream file created/updated
- [ ] Dependencies tracked
- [ ] Coordination points identified
- [ ] Status displayed clearly
</success_criteria>
