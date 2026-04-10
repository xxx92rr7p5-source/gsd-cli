<purpose>
Remove a workspace and its associated data with safety confirmations.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="identify_workspace">
**Identify workspace to remove:** Parse $ARGUMENTS. If not specified, list available workspaces. Verify exists.
</step>

<step name="confirm_removal">
**Confirm removal:** Display workspace summary. Require exact name match for confirmation.
</step>

<step name="archive">
**Archive workspace:** Copy to .gsd/archive/ with timestamp. Create archive manifest with expiry date (30 days).
</step>

<step name="remove">
**Remove workspace:** Delete workspace directory. Update registry. Clear active workspace pointer if applicable.
</step>

<step name="confirm">
**Confirm removal:** Show archive location, expiry date, remaining workspace count.
</step>

</process>

<success_criteria>
- [ ] Workspace identified and verified
- [ ] Explicit confirmation received
- [ ] Workspace archived before removal
- [ ] Archive manifest created
- [ ] Workspace directory removed
- [ ] Registry updated
- [ ] Active workspace pointer cleared (if applicable)
</success_criteria>
