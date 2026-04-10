<purpose>
Review code changes and automatically apply fixes for identified issues.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="review">
**Perform code review:** Same as gsd-code-review across all dimensions.
</step>

<step name="triage_fixes">
**Triage issues:** Auto-fixable, Fix with review, Manual only. Present and confirm.
</step>

<step name="apply_fixes">
**Apply fixes using agents:** Spawn fix agent per issue, verify with tests, commit or revert.
</step>

<step name="verify">
**Verify fixes:** Re-run review on fixed code. Run test suite.
</step>

<step name="report">
**Generate final report:** List resolved issues with commits and remaining manual items.
</step>

</process>

<success_criteria>
- [ ] Review completed across all dimensions
- [ ] Issues triaged by fixability
- [ ] Auto-fixes applied and verified
- [ ] Tests passing
- [ ] Remaining manual items documented
</success_criteria>
