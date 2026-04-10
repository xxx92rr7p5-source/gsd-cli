<purpose>
List all available workspaces with their status and metadata.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="discover_workspaces">
**Find all workspaces:** Scan workspace directories. For each, collect name, creation date, current phase, completion, last activity.
</step>

<step name="collect_status">
**Collect workspace status:** Load STATE.md and ROADMAP.md for each workspace. Extract phase and progress.
</step>

<step name="display">
**Display workspace list:** Show table with status, phase, progress, last active. Highlight current workspace.
</step>

<step name="offer_actions">
**Offer actions:** Switch, Create, Remove.
</step>

</process>

<success_criteria>
- [ ] All workspaces discovered
- [ ] Status collected for each
- [ ] List displayed with key metadata
- [ ] Navigation actions offered
</success_criteria>
