---
description: Stack upgrade and migration
argument-hint: "[target version or framework]"
tools:
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
  task: true
  question: true
---
<objective>
Upgrade the project's technology stack to newer versions or different frameworks.

Plans and executes major version upgrades, framework migrations, and technology stack changes with careful compatibility checking, incremental migration, and rollback capability.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/gstack-upgrade.md
</execution_context>

<context>
Upgrade target: $ARGUMENTS
</context>

<process>
Execute the gstack-upgrade workflow from @./.opencode/get-shit-done/workflows/gstack-upgrade.md end-to-end.
Preserve migration planning, compatibility checking, incremental upgrade, testing, and rollback capability.
</process>

<success_criteria>
- [ ] Upgrade target identified and planned
- [ ] Compatibility assessed
- [ ] Migration executed incrementally
- [ ] Tests passing after upgrade
- [ ] Rollback plan documented
</success_criteria>
