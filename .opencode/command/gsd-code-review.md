---
description: Code review workflow
argument-hint: "[branch, PR, or commit range]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Review code changes for correctness, architecture alignment, security, and maintainability.

Analyzes diffs, identifies issues across multiple dimensions (logic errors, style violations, security concerns, test coverage), and produces a structured review report.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/code-review.md
</execution_context>

<context>
Target: $ARGUMENTS

Review scope: current working tree changes, specific branch, or referenced PR/commit.
</context>

<process>
Execute the code-review workflow from @./.opencode/get-shit-done/workflows/code-review.md end-to-end.
Preserve all review dimensions (correctness, architecture, security, style, tests).
</process>

<success_criteria>
- [ ] Changes analyzed across all dimensions
- [ ] Issues categorized by severity
- [ ] Review report generated
- [ ] Actionable feedback provided for each issue
</success_criteria>
