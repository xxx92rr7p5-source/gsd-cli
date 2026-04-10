---
description: Undo last action
argument-hint: "[action identifier or description]"
tools:
  read: true
  bash: true
  write: true
  question: true
---
<objective>
Reverse the most recent action taken by GSD, restoring previous state.

Identifies the last committed change, analyzes its impact, and safely reverts it. Works with git history and STATE.md to ensure clean rollback without data loss.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/undo.md
</execution_context>

<context>
@.planning/STATE.md
$ARGUMENTS
</context>

<process>
Execute the undo workflow from @./.opencode/get-shit-done/workflows/undo.md end-to-end.
Preserve safety gates (confirmation, impact analysis, backup, rollback, verification).
</process>

<success_criteria>
- [ ] Last action identified
- [ ] Impact analyzed
- [ ] User confirmed undo
- [ ] Revert applied cleanly
- [ ] STATE.md updated
</success_criteria>
