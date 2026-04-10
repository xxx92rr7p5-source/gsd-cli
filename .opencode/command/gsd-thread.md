---
description: Thread and conversation management
argument-hint: "[thread action or ID]"
tools:
  read: true
  write: true
  bash: true
  question: true
---
<objective>
Manage threaded conversations and discussion context within the project.

Create, list, resume, or archive discussion threads. Threads capture decision rationale, open questions, and exploration results in a structured, searchable format.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/thread.md
</execution_context>

<context>
Action: $ARGUMENTS
</context>

<process>
Execute the thread workflow from @./.opencode/get-shit-done/workflows/thread.md end-to-end.
Preserve thread creation, listing, resumption, and archival capabilities.
</process>

<success_criteria>
- [ ] Requested thread action completed
- [ ] Thread context preserved or restored
- [ ] Decisions and questions captured
</success_criteria>
