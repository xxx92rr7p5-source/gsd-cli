---
description: Developer experience review
argument-hint: "[plan, component, or API]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Review plans and implementations from a developer experience perspective.

Evaluates API design, developer ergonomics, documentation quality, onboarding experience, error messages, debugging experience, and overall ease of use for developers who will interact with the code.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/plan-devex-review.md
</execution_context>

<context>
Target: $ARGUMENTS
</context>

<process>
Execute the plan-devex-review workflow from @./.opencode/get-shit-done/workflows/plan-devex-review.md end-to-end.
Preserve all review dimensions (API design, developer ergonomics, documentation, onboarding, error handling, debugging experience).
</process>

<success_criteria>
- [ ] DevEx reviewed across all dimensions
- [ ] API design evaluated
- [ ] Developer ergonomics assessed
- [ ] Documentation quality checked
- [ ] Onboarding experience reviewed
- [ ] DevEx improvement recommendations provided
</success_criteria>
