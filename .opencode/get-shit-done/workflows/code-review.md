<purpose>
Review code changes for correctness, architecture alignment, security, and maintainability.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="identify_changes">
**Identify changes:** If $ARGUMENTS specifies branch/PR/range, use that. Otherwise review working tree.
</step>

<step name="review_correctness">
**Review correctness:** Logic errors, missing error handling, race conditions.
</step>

<step name="review_architecture">
**Review architecture:** Pattern adherence, layer boundaries, appropriate abstractions.
</step>

<step name="review_security">
**Review security:** Input validation, auth, data exposure, dependency vulnerabilities, secrets.
</step>

<step name="review_style">
**Review style:** Naming, function size, comments, test coverage, error messages.
</step>

<step name="generate_report">
**Compile review report:** Organize by severity with file:line refs and suggestions.
</step>

</process>

<success_criteria>
- [ ] All review dimensions covered
- [ ] Issues categorized by severity
- [ ] Specific locations identified
- [ ] Actionable suggestions provided
- [ ] Report displayed clearly
</success_criteria>
