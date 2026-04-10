---
description: List available workspaces
tools:
  read: true
  bash: true
  glob: true
---
<objective>
List all available workspaces with their status and metadata.

Shows workspace name, creation date, current phase, completion percentage, and last activity timestamp for quick overview and navigation.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/list-workspaces.md
</execution_context>

<process>
Execute the list-workspaces workflow from @./.opencode/get-shit-done/workflows/list-workspaces.md end-to-end.
Display workspace inventory with status summary.
</process>

<success_criteria>
- [ ] All workspaces enumerated
- [ ] Status shown for each workspace
- [ ] Navigation hints provided
</success_criteria>
