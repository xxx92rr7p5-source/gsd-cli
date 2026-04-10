<purpose>
Manage workspaces and projects within the GSD system.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_action">
**Determine requested action:** Parse $ARGUMENTS for list, switch, info, current, or stats.
</step>

<step name="load_workspace">
**Load workspace context:** Load STATE.md, ROADMAP.md, PROJECT.md for target workspace.
</step>

<step name="switch">
**Switch workspace:** Verify exists, save current state, update pointer, load context, display confirmation.
</step>

<step name="show_info">
**Show workspace details:** Display comprehensive info including phase, progress, recent activity, decisions, open issues.
</step>

<step name="multi_project">
**Coordinate across projects:** Show cross-project view with totals, dependencies, priorities, conflicts.
</step>

</process>

<success_criteria>
- [ ] Requested action identified
- [ ] Workspace context loaded
- [ ] Action executed (switch/info/stats)
- [ ] Status displayed clearly
- [ ] Next actions offered
</success_criteria>
