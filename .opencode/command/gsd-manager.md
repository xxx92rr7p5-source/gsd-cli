---
description: Workspace and project management
argument-hint: "[workspace name or action]"
tools:
  read: true
  write: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Manage workspaces and projects within the GSD system.

Provides a hub for workspace operations: switch context, view workspace details, manage milestones, configure workspace settings, and coordinate across multiple projects.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/manager.md
</execution_context>

<context>
Action: $ARGUMENTS

Current workspace context (if any) will be loaded from STATE.md.
</context>

<process>
Execute the manager workflow from @./.opencode/get-shit-done/workflows/manager.md end-to-end.
Handles workspace switching, context management, and multi-project coordination.
</process>

<success_criteria>
- [ ] Requested action executed
- [ ] Workspace context updated (if applicable)
- [ ] User informed of current state
</success_criteria>
