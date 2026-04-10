---
description: Manage workstreams within a project
argument-hint: "[workstream action or name]"
tools:
  read: true
  write: true
  bash: true
  task: true
  question: true
---
<objective>
Create, manage, and coordinate workstreams within a project.

Workstreams represent parallel tracks of work that can be planned and executed independently. Supports creating workstreams, assigning phases, tracking progress per stream, and coordinating cross-stream dependencies.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/workstreams.md
</execution_context>

<context>
Action: $ARGUMENTS

@.planning/STATE.md
@.planning/ROADMAP.md
</context>

<process>
Execute the workstreams workflow from @./.opencode/get-shit-done/workflows/workstreams.md end-to-end.
Preserve workstream creation, tracking, dependency management, and coordination capabilities.
</process>

<success_criteria>
- [ ] Workstream action executed
- [ ] Workstream state updated
- [ ] Dependencies tracked
- [ ] Progress reported
</success_criteria>
