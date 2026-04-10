---
description: Ship and deploy changes
argument-hint: "[target environment or version]"
tools:
  read: true
  bash: true
  task: true
  question: true
---
<objective>
Ship and deploy completed work to the target environment.

Handles version bumping, changelog generation, tagging, building, and deployment. Supports multiple environments (dev, staging, production) with appropriate safety gates for each.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/ship.md
</execution_context>

<context>
Target: $ARGUMENTS

@.planning/STATE.md
@.planning/ROADMAP.md
</context>

<process>
Execute the ship workflow from @./.opencode/get-shit-done/workflows/ship.md end-to-end.
Preserve all gates (version check, changelog, tagging, build, deploy, smoke test, announcement).
</process>

<success_criteria>
- [ ] Version determined
- [ ] Changelog updated
- [ ] Git tag created
- [ ] Build succeeded
- [ ] Deployment completed
- [ ] Smoke tests passed
</success_criteria>
