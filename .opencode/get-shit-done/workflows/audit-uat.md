<purpose>
Conduct user acceptance testing audit on completed phases or features.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_context">
**Load UAT context:** Load REQUIREMENTS.md, ROADMAP.md, STATE.md. Target specific phase if $ARGUMENTS provided.
</step>

<step name="extract_tests">
**Extract testable deliverables:** From SUMMARY.md and PLAN.md, extract features, acceptance criteria. Generate test scenarios.
</step>

<step name="execute_tests">
**Run UAT scenarios:** Present each scenario to user with action and expected outcome. Record pass/fail/skip. Run automated checks.
</step>

<step name="analyze_failures">
**Analyze failed tests:** Document actual vs expected, identify likely cause, categorize.
</step>

<step name="generate_report">
**Create UAT report:** Write to .planning/phases/[phase]/[phase]-UAT.md. Update STATE.md.
</step>

<step name="route_failures">
**Handle failures:** Offer fix planning, debug, or manual fix. If all passed, confirm ready.
</step>

</process>

<success_criteria>
- [ ] Testable deliverables extracted
- [ ] All UAT scenarios executed
- [ ] Results recorded (pass/fail/skip)
- [ ] Failures analyzed with likely causes
- [ ] UAT report created
- [ ] User routed to next action
</success_criteria>
