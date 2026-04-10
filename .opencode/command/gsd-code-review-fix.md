---
description: Code review with automatic fix
argument-hint: "[branch, PR, or commit range]"
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
Review code changes and automatically apply fixes for identified issues.

Combines the code review workflow with automatic remediation. Reviews changes, identifies issues, then spawns fix agents for each remediable problem. Non-fixable issues are reported for manual handling.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/code-review-fix.md
</execution_context>

<context>
Target: $ARGUMENTS
</context>

<process>
Execute the code-review-fix workflow from @./.opencode/get-shit-done/workflows/code-review-fix.md end-to-end.
1. Review changes (same as gsd-code-review)
2. Spawn fix agents for each remediable issue
3. Apply fixes with atomic commits
4. Report remaining manual items
</process>

<success_criteria>
- [ ] All issues identified
- [ ] Remediabale issues fixed automatically
- [ ] Fix commits are atomic and documented
- [ ] Report lists any remaining manual items
</success_criteria>
