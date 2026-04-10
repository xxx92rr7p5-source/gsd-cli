---
description: Seed and initialize a project idea
argument-hint: "[idea description or @reference to idea document]"
tools:
  read: true
  write: true
  bash: true
  task: true
  question: true
---
<objective>
Take a rough project idea and develop it into a structured seed document.

Explores the idea through targeted questions, researches feasibility, outlines scope, identifies risks, and produces a structured seed document that can be used as input for /gsd-new-project.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/plant-seed.md
@./.opencode/get-shit-done/templates/seed.md
</execution_context>

<context>
Idea: $ARGUMENTS
</context>

<process>
Execute the plant-seed workflow from @./.opencode/get-shit-done/workflows/plant-seed.md end-to-end.
Preserve all phases (exploration, feasibility analysis, scoping, risk identification, seed document creation).
</process>

<success_criteria>
- [ ] Idea explored and clarified
- [ ] Feasibility assessed
- [ ] Scope outlined
- [ ] Risks identified
- [ ] Seed document created
</success_criteria>
