---
description: User acceptance testing audit
argument-hint: "[phase or feature name]"
tools:
  read: true
  bash: true
  task: true
  question: true
---
<objective>
Conduct user acceptance testing audit on completed phases or features.

Validates that delivered functionality matches original requirements and user expectations. Runs through test scenarios, documents pass/fail status, and creates remediation plans for failures.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/audit-uat.md
</execution_context>

<context>
Target: $ARGUMENTS

@.planning/REQUIREMENTS.md
@.planning/ROADMAP.md
@.planning/STATE.md
</context>

<process>
Execute the audit-uat workflow from @./.opencode/get-shit-done/workflows/audit-uat.md end-to-end.
Preserve all workflow gates (test extraction, scenario execution, pass/fail recording, failure remediation).
</process>

<success_criteria>
- [ ] Testable deliverables identified
- [ ] UAT scenarios executed
- [ ] Pass/fail results documented
- [ ] Failures have remediation plans
- [ ] UAT report generated
</success_criteria>
