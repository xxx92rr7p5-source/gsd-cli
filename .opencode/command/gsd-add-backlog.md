---
description: Add items to project backlog
argument-hint: "[description or @reference to backlog items]"
tools:
  read: true
  write: true
  bash: true
  question: true
---
<objective>
Add new items to the project backlog with structured tracking.

Captures features, bugs, tech debt, or ideas as backlog entries. Each item gets a unique ID, priority, and optional area grouping for organized triage.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/add-backlog.md
@./.opencode/get-shit-done/templates/backlog-item.md
</execution_context>

<context>
@.planning/STATE.md
$ARGUMENTS
</context>

<process>
Execute the add-backlog workflow from @./.opencode/get-shit-done/workflows/add-backlog.md end-to-end.
Preserve all workflow gates (item creation, deduplication, priority assignment, state updates).
</process>
