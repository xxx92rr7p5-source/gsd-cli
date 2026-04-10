---
description: UI review and quality assessment
argument-hint: "[component, page, or scope]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Review UI implementation for design fidelity, usability, accessibility, and visual consistency.

Evaluates components and pages against design intent, brand guidelines, accessibility standards, and responsive behavior. Produces a structured review with actionable improvements.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/ui-review.md
@./.opencode/get-shit-done/references/ui-brand.md
</execution_context>

<context>
Review target: $ARGUMENTS
</context>

<process>
Execute the ui-review workflow from @./.opencode/get-shit-done/workflows/ui-review.md end-to-end.
Preserve all review dimensions (design fidelity, usability, accessibility, responsiveness, visual consistency, brand alignment).
</process>

<success_criteria>
- [ ] UI reviewed across all dimensions
- [ ] Issues identified and prioritized
- [ ] Improvement suggestions provided
- [ ] Accessibility compliance checked
- [ ] Brand alignment assessed
</success_criteria>
