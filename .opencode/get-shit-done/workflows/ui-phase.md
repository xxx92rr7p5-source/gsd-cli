<purpose>
Execute UI-focused work with attention to design, interaction, and frontend quality.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_context">
**Load UI context:** If $ARGUMENTS specifies phase/component, target that. Otherwise identify current UI work from STATE.md. Load brand guidelines.
</step>

<step name="plan_ui">
**Plan UI work:** Define layout, styling (per brand), interactions, responsiveness, accessibility. Create brief UI plan.
</step>

<step name="implement">
**Implement UI changes:** Spawn UI executor agents for parallel work. Use brand guidelines. Ensure accessibility compliance.
</step>

<step name="verify">
**Verify UI quality:** Check visual consistency, responsiveness, accessibility (WCAG 2.1 AA), performance, cross-browser.
</step>

<step name="commit">
**Commit changes:** Stage and commit UI changes atomically.
</step>

<step name="report">
**Report results:** Display implemented features, quality check results (pass/fail per dimension), commits.
</step>

</process>

<success_criteria>
- [ ] UI work planned with all dimensions
- [ ] Components implemented per plan
- [ ] Styling matches brand guidelines
- [ ] Responsiveness verified
- [ ] Accessibility checked and compliant
- [ ] Changes committed
- [ ] Quality report generated
</success_criteria>
