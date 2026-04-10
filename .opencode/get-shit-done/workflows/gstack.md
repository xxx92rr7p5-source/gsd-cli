<purpose>
Manage the project's technology stack and dependencies.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_action">
**Determine stack action:** Parse $ARGUMENTS: list, add, remove, audit, outdated. If no action, show current stack overview.
</step>

<step name="show_stack">
**Show current stack:** Detect package manager. Display dependencies and dev dependencies. Detect key technologies.
</step>

<step name="add_dependency">
**Add a dependency:** Install package. Verify it works. Update planning artifacts if stack changes significantly.
</step>

<step name="remove_dependency">
**Remove a dependency:** Check if package is used in codebase. If unused, safe to remove. If used, warn about breaking changes.
</step>

<step name="audit_deps">
**Audit dependencies:** Run security audit and outdated check. Report vulnerabilities, deprecated packages, major version gaps, unused deps.
</step>

<step name="update_state">
**Update planning artifacts:** If stack changed significantly, update STACK.md and note in STATE.md.
</step>

</process>

<success_criteria>
- [ ] Stack action identified
- [ ] Action executed correctly
- [ ] Dependencies managed
- [ ] Audit results reported (if applicable)
- [ ] Planning artifacts updated
</success_criteria>
