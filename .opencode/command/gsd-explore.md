---
description: Explore and discovery command
argument-hint: "[topic, area, or question to explore]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Explore and discover information about the codebase, domain, or a specific topic.

Spawns parallel exploration agents that investigate different aspects of the query. Synthesizes findings into a structured discovery document. Use for understanding unfamiliar areas, researching approaches, or mapping unknown territory.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/explore.md
</execution_context>

<context>
Exploration target: $ARGUMENTS

@.planning/STATE.md (if available for project context)
</context>

<process>
Execute the explore workflow from @./.opencode/get-shit-done/workflows/explore.md end-to-end.
Preserve parallel agent spawning, findings synthesis, and structured output generation.
</process>

<success_criteria>
- [ ] Exploration scope defined
- [ ] Parallel agents dispatched
- [ ] Findings synthesized
- [ ] Discovery document generated
- [ ] Next steps suggested
</success_criteria>
