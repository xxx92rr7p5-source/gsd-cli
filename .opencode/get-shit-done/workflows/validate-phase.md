<purpose>
Validate that a phase has been completed correctly and all success criteria are met.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_phase">
**Load phase context:** If $ARGUMENTS specifies phase, use that. Otherwise use current phase from STATE.md. Load ROADMAP.md and all PLAN.md files.
</step>

<step name="extract_criteria">
**Extract success criteria:** From each PLAN.md, extract objectives, success criteria, deliverables. Compile master list.
</step>

<step name="verify_deliverables">
**Verify deliverables:** For each criterion, check SUMMARY.md exists, deliverable present in codebase, tests pass.
</step>

<step name="run_tests">
**Execute tests:** Run test suite, build, lint. Record results.
</step>

<step name="check_documentation">
**Check documentation:** Verify SUMMARY files complete, code comments adequate, README/docs updated if APIs changed.
</step>

<step name="confirm_goal">
**Confirm phase goal achieved:** From ROADMAP.md get phase goal. Assess based on plans executed, tests passing, no critical issues.
</step>

<step name="create_verification">
**Create VERIFICATION.md:** Write deliverables table, test results, documentation status, goal assessment, open items, verdict.
</step>

<step name="report">
**Display verification results:** Show summary. If all met, recommend next phase. If issues found, recommend addressing them.
</step>

</process>

<success_criteria>
- [ ] Phase plan loaded and success criteria extracted
- [ ] Deliverables verified against plan
- [ ] Tests executed and passing
- [ ] Documentation reviewed
- [ ] Phase goal confirmed
- [ ] VERIFICATION.md created
</success_criteria>
