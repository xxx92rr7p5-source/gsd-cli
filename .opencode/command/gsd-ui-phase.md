---
description: UI-specific phase execution
argument-hint: "[phase number or UI component]"
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
Execute UI-focused work with attention to design, interaction, and frontend quality.

Specialized phase execution for UI/UX work. Handles component implementation, styling, responsiveness, accessibility, and interaction patterns with UI-specific quality gates.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/ui-phase.md
@./.opencode/get-shit-done/references/ui-brand.md
</execution_context>

<context>
Target: $ARGUMENTS

@.planning/STATE.md (if available)
</context>

<process>
Execute the ui-phase workflow from @./.opencode/get-shit-done/workflows/ui-phase.md end-to-end.
Preserve all UI quality gates (design alignment, responsiveness, accessibility, interaction, visual consistency).
</process>

<success_criteria>
- [ ] UI work planned and scoped
- [ ] Components implemented
- [ ] Styling applied and consistent
- [ ] Responsiveness verified
- [ ] Accessibility checked
- [ ] UI quality gates passed
</success_criteria>
