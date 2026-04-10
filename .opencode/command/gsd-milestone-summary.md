---
description: Summarize milestone status
argument-hint: "[milestone version or name]"
tools:
  read: true
  bash: true
  grep: true
  glob: true
---
<objective>
Generate a concise summary of milestone completion status.

Reports what was planned vs. delivered, phase completion rates, key decisions made, open issues, and whether the milestone meets its original goals.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/milestone-summary.md
</execution_context>

<context>
Milestone: $ARGUMENTS

@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/REQUIREMENTS.md
</context>

<process>
Execute the milestone-summary workflow from @./.opencode/get-shit-done/workflows/milestone-summary.md end-to-end.
Preserve all reporting sections (planned vs. delivered, completion metrics, decisions, open issues).
</process>

<success_criteria>
- [ ] Milestone phases analyzed
- [ ] Planned vs. delivered compared
- [ ] Key decisions summarized
- [ ] Open issues listed
- [ ] Summary report generated
</success_criteria>
