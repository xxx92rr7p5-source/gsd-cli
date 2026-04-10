---
description: Import external project or data
argument-hint: "[source path, URL, or description]"
tools:
  read: true
  write: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Import an external project, codebase, or dataset into the current workspace.

Analyzes the source, maps its structure, identifies dependencies and compatibility issues, and integrates it into the project with proper planning artifacts.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/import.md
</execution_context>

<context>
Source: $ARGUMENTS

@.planning/STATE.md (if available for target project context)
</context>

<process>
Execute the import workflow from @./.opencode/get-shit-done/workflows/import.md end-to-end.
Preserve all workflow gates (source analysis, compatibility check, integration planning, import execution, verification).
</process>

<success_criteria>
- [ ] Source analyzed and understood
- [ ] Compatibility issues identified
- [ ] Import plan created
- [ ] Data/code imported successfully
- [ ] Integration verified
- [ ] Planning artifacts updated
</success_criteria>
