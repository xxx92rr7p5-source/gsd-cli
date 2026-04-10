---
description: Review backlog items
argument-hint: "[filter or area]"
tools:
  read: true
  bash: true
  write: true
  question: true
---
<objective>
Review and triage backlog items to prioritize work.

Lists pending backlog items, allows filtering by area or priority, and supports triage actions (prioritize, defer, reject, split). Helps keep the backlog actionable and focused.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/review-backlog.md
</execution_context>

<context>
Filter: $ARGUMENTS

@.planning/STATE.md
@.planning/ROADMAP.md
</context>

<process>
Execute the review-backlog workflow from @./.opencode/get-shit-done/workflows/review-backlog.md end-to-end.
Preserve listing, filtering, triage actions, and reprioritization logic.
</process>

<success_criteria>
- [ ] Backlog items listed
- [ ] Filtering applied (if requested)
- [ ] Triage decisions made
- [ ] Priorities updated
- [ ] Cleanup actions applied
</success_criteria>
