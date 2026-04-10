---
description: Remove a workspace
argument-hint: "[workspace name]"
tools:
  read: true
  bash: true
  question: true
---
<objective>
Remove a workspace and its associated data with safety confirmations.

Archives workspace data before removal, updates workspace registry, and cleans up references. Requires explicit confirmation to prevent accidental data loss.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/remove-workspace.md
</execution_context>

<context>
Workspace to remove: $ARGUMENTS
</context>

<process>
Execute the remove-workspace workflow from @./.opencode/get-shit-done/workflows/remove-workspace.md end-to-end.
Preserve all safety gates (confirmation, archival, cleanup, verification).
</process>

<success_criteria>
- [ ] Workspace identified and confirmed
- [ ] User confirmed removal (explicit)
- [ ] Data archived before deletion
- [ ] Workspace removed cleanly
- [ ] Registry updated
</success_criteria>
