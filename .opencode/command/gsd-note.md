---
description: Take notes
argument-hint: "[note content or @reference]"
tools:
  read: true
  write: true
  bash: true
  question: true
---
<objective>
Capture notes and associate them with the current project context.

Creates structured notes in the project's planning directory, tagged with timestamps and optional area labels for later retrieval and organization.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/note.md
</execution_context>

<context>
Note: $ARGUMENTS

@.planning/STATE.md (for project context)
</context>

<process>
Execute the note workflow from @./.opencode/get-shit-done/workflows/note.md end-to-end.
Preserve note capture, timestamping, area tagging, and storage.
</process>

<success_criteria>
- [ ] Note captured with timestamp
- [ ] Note stored in appropriate location
- [ ] Note linked to project context
- [ ] Retrieval instructions provided
</success_criteria>
