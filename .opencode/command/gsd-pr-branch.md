---
description: Create and manage PR branches
argument-hint: "[branch name or PR description]"
tools:
  read: true
  bash: true
  write: true
  task: true
  question: true
---
<objective>
Create and manage Git branches for pull requests.

Handles branch creation from current work, branch naming conventions, PR description generation, and branch lifecycle management (create, update, clean up).
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/pr-branch.md
</execution_context>

<context>
Branch/PR: $ARGUMENTS

@.planning/STATE.md (for context about current work)
</context>

<process>
Execute the pr-branch workflow from @./.opencode/get-shit-done/workflows/pr-branch.md end-to-end.
Preserve branch creation, naming, PR description generation, and lifecycle management.
</process>

<success_criteria>
- [ ] Branch created with proper naming convention
- [ ] Work committed atomically
- [ ] PR description generated
- [ ] Branch ready for review
</success_criteria>
