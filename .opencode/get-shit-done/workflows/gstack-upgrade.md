<purpose>
Upgrade the project's technology stack to newer versions or different frameworks.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="identify_upgrade">
**Identify upgrade target:** Parse $ARGUMENTS for target version or framework. If not specified, show available upgrades. Determine upgrade scope (patch/minor/major).
</step>

<step name="assess_impact">
**Assess upgrade impact:** For major upgrades: read changelog, identify breaking changes, check which affect codebase, estimate migration effort.
</step>

<step name="plan_migration">
**Create migration plan:** List breaking changes with affected files and migration steps. Define rollback plan. Confirm with user.
</step>

<step name="execute_upgrade">
**Execute the upgrade:** Create upgrade branch. Update dependencies. Apply migration steps sequentially. Run tests after each change.
</step>

<step name="handle_failures">
**Handle upgrade failures:** If tests fail, identify if related to upgrade. If fixable, fix and retest. If not, offer rollback.
</step>

<step name="finalize">
**Finalize the upgrade:** Commit changes. Update planning artifacts with new versions. Display summary with rollback info.
</step>

</process>

<success_criteria>
- [ ] Upgrade target identified
- [ ] Impact assessed
- [ ] Migration plan created
- [ ] Upgrade executed incrementally
- [ ] Tests passing after upgrade
- [ ] Changes committed
- [ ] Rollback plan documented
- [ ] Planning artifacts updated
</success_criteria>
