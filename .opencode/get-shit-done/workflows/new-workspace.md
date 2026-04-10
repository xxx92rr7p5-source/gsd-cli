<purpose>
Create a new workspace for a project or initiative.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_name">
**Determine workspace name:** Parse $ARGUMENTS. Validate (no spaces, lowercase, alphanumeric + hyphens).
</step>

<step name="check_exists">
**Check for existing workspace:** If exists, offer to switch or rename.
</step>

<step name="create_structure">
**Create workspace directory structure:** Create .planning/ with phases/, todos/, debug/, milestones/ subdirs.
</step>

<step name="initialize_config">
**Create default configuration:** Write config.json and initial STATE.md with workspace metadata.
</step>

<step name="confirm">
**Display confirmation:** Show structure and next steps (/gsd-new-project, /gsd-manager).
</step>

</process>

<success_criteria>
- [ ] Workspace name validated
- [ ] No name collision
- [ ] Directory structure created
- [ ] Configuration initialized
- [ ] STATE.md created
- [ ] Confirmation displayed with next steps
</success_criteria>
