<purpose>
Review UI implementation for design fidelity, usability, accessibility, and visual consistency.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="identify_target">
**Identify review target:** Parse $ARGUMENTS for component, page, or scope. If none, review most recently modified UI files. Load brand guidelines.
</step>

<step name="review_design_fidelity">
**Review design fidelity:** Check layout, spacing, typography, colors, iconography against brand/spec. Note deviations.
</step>

<step name="review_usability">
**Review usability:** Visual hierarchy, interactive elements obvious, forms well-labeled, states handled, navigation intuitive.
</step>

<step name="review_accessibility">
**Review accessibility:** WCAG 2.1 AA - contrast ratios, keyboard navigation, focus indicators, ARIA, semantic HTML, alt text.
</step>

<step name="review_responsive">
**Review responsive behavior:** Check at mobile, tablet, desktop breakpoints. No horizontal scroll, readable text, adequate touch targets.
</step>

<step name="review_brand">
**Review brand alignment:** Logo usage, brand colors, typography, tone, spacing against brand guidelines.
</step>

<step name="report">
**Generate UI review report:** Score each dimension. List issues with locations. Provide overall verdict.
</step>

</process>

<success_criteria>
- [ ] All review dimensions covered
- [ ] Issues identified with specific locations
- [ ] Accessibility compliance checked
- [ ] Brand alignment assessed
- [ ] Review report with verdict
</success_criteria>
