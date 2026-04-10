---
description: Determine and route to next action
tools:
  read: true
  bash: true
  grep: true
  glob: true
  skill: true
---
<objective>
Analyze current project state and intelligently determine the next best action.

Examines ROADMAP.md, STATE.md, and phase directories to identify whether to execute an existing plan, create a new plan, address blockers, or suggest milestone management actions. Routes the user to the most productive next step.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/next.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/ROADMAP.md
@.planning/REQUIREMENTS.md
</context>

<process>
Execute the next workflow from @./.opencode/get-shit-done/workflows/next.md end-to-end.
Preserve all routing logic and decision trees for determining the next action.
</process>

<success_criteria>
- [ ] Project state analyzed
- [ ] Next action determined
- [ ] User routed to appropriate command
- [ ] Context provided for next step
</success_criteria>
