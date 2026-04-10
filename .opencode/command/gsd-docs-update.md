---
description: Update project documentation
argument-hint: "[scope or specific docs to update]"
tools:
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
  task: true
---
<objective>
Update project documentation to reflect current codebase state and recent changes.

Scans for documentation gaps, updates stale docs, generates missing documentation, and ensures consistency across README, API docs, architecture docs, and other project documentation.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/docs-update.md
</execution_context>

<context>
Scope: $ARGUMENTS

@.planning/STATE.md (if available)
</context>

<process>
Execute the docs-update workflow from @./.opencode/get-shit-done/workflows/docs-update.md end-to-end.
Preserve all documentation dimensions (README, API, architecture, changelog, setup guides, contribution guides).
</process>

<success_criteria>
- [ ] Documentation gaps identified
- [ ] Stale docs updated
- [ ] Missing docs created
- [ ] Consistency verified
- [ ] Documentation changes committed
</success_criteria>
