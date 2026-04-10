<purpose>
Ship and deploy completed work to the target environment.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="determine_version">
**Determine version:** If $ARGUMENTS specifies version, use it. Otherwise determine from current state. Determine bump type (patch/minor/major). Confirm with user.
</step>

<step name="pre_flight">
**Pre-flight checks:** Check clean working tree, tests passing, build succeeds. Warn and confirm on failures.
</step>

<step name="changelog">
**Update changelog:** Generate entries from commits since last tag. Format by category (Added/Fixed/Changed/Removed). Append to CHANGELOG.md.
</step>

<step name="tag">
**Create git tag:** Commit changelog. Create annotated tag.
</step>

<step name="deploy">
**Deploy to target:** Based on target environment. For production, require explicit confirmation. Push tags and branches.
</step>

<step name="smoke_test">
**Run smoke tests:** Health check, basic functionality. Alert if failures.
</step>

<step name="announce">
**Announce release:** Display version, changes count, changelog ref, tag, environment, smoke test status. Update STATE.md.
</step>

</process>

<success_criteria>
- [ ] Version determined and confirmed
- [ ] Pre-flight checks passed
- [ ] Changelog updated
- [ ] Git tag created
- [ ] Deployment completed
- [ ] Smoke tests passed
- [ ] Release announced
- [ ] STATE.md updated
</success_criteria>
