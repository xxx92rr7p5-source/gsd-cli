---
description: Create a new workspace
argument-hint: "[workspace name and description]"
tools:
  read: true
  write: true
  bash: true
  question: true
---
<objective>
Create a new workspace for a project or initiative.

Sets up the workspace directory structure, initializes planning artifacts, configures defaults, and prepares the workspace for project initialization via /gsd-new-project.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/new-workspace.md
@./.opencode/get-shit-done/templates/workspace.md
</execution_context>

<context>
Workspace: $ARGUMENTS
</context>

<process>
Execute the new-workspace workflow from @./.opencode/get-shit-done/workflows/new-workspace.md end-to-end.
Preserve all setup steps (directory creation, config initialization, defaults configuration).
</process>

<success_criteria>
- [ ] Workspace directory structure created
- [ ] Planning artifacts initialized
- [ ] Configuration set up
- [ ] Workspace ready for /gsd-new-project
</success_criteria>
