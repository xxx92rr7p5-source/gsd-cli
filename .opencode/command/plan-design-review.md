---
description: Design review of plans and architecture
argument-hint: "[plan reference or component]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Review plans and implementations from a design and architecture perspective.

Evaluates structural soundness, pattern adherence, scalability, maintainability, and design consistency. Ensures the solution follows established architecture patterns and design principles.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/plan-design-review.md
</execution_context>

<context>
Target: $ARGUMENTS

@.planning/PROJECT.md (for design intent)
</context>

<process>
Execute the plan-design-review workflow from @./.opencode/get-shit-done/workflows/plan-design-review.md end-to-end.
Preserve all review dimensions (architecture alignment, pattern adherence, scalability, maintainability, design consistency).
</process>

<success_criteria>
- [ ] Design reviewed across all dimensions
- [ ] Architecture alignment verified
- [ ] Pattern adherence checked
- [ ] Scalability concerns identified
- [ ] Design recommendations provided
</success_criteria>
