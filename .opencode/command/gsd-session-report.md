---
description: Generate session report
argument-hint: "[session identifier or time range]"
tools:
  read: true
  write: true
  bash: true
  glob: true
  grep: true
---
<objective>
Generate a comprehensive report of work done in a session.

Summarizes all changes made, decisions recorded, files modified, tests affected, and context that should be preserved for future sessions. Useful for handoffs and session continuity.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/session-report.md
</execution_context>

<context>
@.planning/STATE.md
$ARGUMENTS
</context>

<process>
Execute the session-report workflow from @./.opencode/get-shit-done/workflows/session-report.md end-to-end.
Preserve all reporting sections (changes, decisions, files, tests, context, next steps).
</process>

<success_criteria>
- [ ] Session changes enumerated
- [ ] Decisions documented
- [ ] File modifications listed
- [ ] Test impact assessed
- [ ] Context captured for handoff
- [ ] Next steps suggested
</success_criteria>
