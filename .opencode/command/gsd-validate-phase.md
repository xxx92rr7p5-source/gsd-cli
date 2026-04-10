---
description: Validate phase completion
argument-hint: "[phase number]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Validate that a phase has been completed correctly and all success criteria are met.

Checks the phase plan against actual deliverables, verifies tests pass, confirms documentation is updated, and validates that the phase goal has been achieved. Produces a VERIFICATION.md file.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/validate-phase.md
</execution_context>

<context>
Phase: $ARGUMENTS

@.planning/STATE.md
</context>

<process>
Execute the validate-phase workflow from @./.opencode/get-shit-done/workflows/validate-phase.md end-to-end.
Preserve all validation checks (deliverable verification, test execution, documentation review, goal confirmation).
</process>

<success_criteria>
- [ ] Phase plan loaded and success criteria extracted
- [ ] Deliverables verified against plan
- [ ] Tests executed and passing
- [ ] Documentation reviewed
- [ ] Phase goal confirmed
- [ ] VERIFICATION.md created
</success_criteria>
