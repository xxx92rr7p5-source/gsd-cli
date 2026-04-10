---
description: Stack management and dependency operations
argument-hint: "[action: list, add, remove, audit]"
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
Manage the project's technology stack and dependencies.

Handles dependency audits, version updates, package additions and removals, compatibility checks, and stack configuration. Keeps the project's technology choices current and secure.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/gstack.md
</execution_context>

<context>
Action: $ARGUMENTS
</context>

<process>
Execute the gstack workflow from @./.opencode/get-shit-done/workflows/gstack.md end-to-end.
Preserve dependency management, stack configuration, and compatibility checking capabilities.
</process>

<success_criteria>
- [ ] Requested stack action completed
- [ ] Dependencies updated (if applicable)
- [ ] Compatibility verified
- [ ] Changes committed
</success_criteria>
