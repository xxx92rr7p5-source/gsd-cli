---
description: CEO-level plan review
argument-hint: "[plan reference or phase number]"
tools:
  read: true
  bash: true
  task: true
  question: true
---
<objective>
Review a plan from a strategic, business-oriented perspective.

Evaluates whether the plan aligns with project goals, business value, resource constraints, and strategic priorities. Focuses on "should we do this" and "is this the right approach" rather than implementation details.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/plan-ceo-review.md
</execution_context>

<context>
Plan: $ARGUMENTS

@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/REQUIREMENTS.md
</context>

<process>
Execute the plan-ceo-review workflow from @./.opencode/get-shit-done/workflows/plan-ceo-review.md end-to-end.
Preserve all review dimensions (strategic alignment, business value, resource fit, risk assessment, prioritization).
</process>

<success_criteria>
- [ ] Plan reviewed for strategic alignment
- [ ] Business value assessed
- [ ] Resource fit evaluated
- [ ] Risks identified
- [ ] Recommendations provided
</success_criteria>
