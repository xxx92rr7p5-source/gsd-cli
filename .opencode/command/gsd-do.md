---
description: General task execution
argument-hint: "[task description]"
tools:
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Execute a general-purpose task with full GSD workflow guarantees.

The default task executor. Plans the work, delegates to appropriate agents, tracks state, commits atomically, and reports results. Use for any task that doesn't have a more specialized command.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/do.md
@.planning/STATE.md
</execution_context>

<context>
Task: $ARGUMENTS
</context>

<process>
Execute the do workflow from @./.opencode/get-shit-done/workflows/do.md end-to-end.
Preserve all workflow gates (clarification, planning, execution, verification, commit, state update).
</process>

<success_criteria>
- [ ] Task understood and scoped
- [ ] Plan created (for non-trivial tasks)
- [ ] Work executed by appropriate agents
- [ ] Results verified
- [ ] Changes committed atomically
- [ ] STATE.md updated
</success_criteria>
