<purpose>
Review a plan from a strategic, business-oriented perspective.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_plan">
**Load the plan for review:** Parse $ARGUMENTS for plan reference or phase number. Load the plan, PROJECT.md, ROADMAP.md, REQUIREMENTS.md.
</step>

<step name="review_strategic_alignment">
**Review strategic alignment:** Does the plan align with project vision? Advance roadmap objectives? Address the right requirements? Is timing right relative to other phases? Score: Strongly aligned / Aligned / Neutral / Misaligned / Conflicts.
</step>

<step name="assess_business_value">
**Assess business value:** User impact, revenue impact, competitive advantage, risk reduction, opportunity cost. Score: High / Medium / Low / No clear value.
</step>

<step name="evaluate_resources">
**Evaluate resource fit:** Time estimate vs available time, technical complexity, external dependencies, team capacity. Flag resource concerns.
</step>

<step name="assess_risks">
**Assess risks:** Market risk, technical risk, timeline risk, dependency risk. Rate likelihood and impact for each.
</step>

<step name="generate_review">
**Generate CEO review report:** Display strategic alignment, business value, resource fit, risk assessment table, recommendation (Proceed/Modify/Defer/Reconsider), and key questions to answer.
</step>

</process>

<success_criteria>
- [ ] Plan loaded with full context
- [ ] Strategic alignment assessed
- [ ] Business value evaluated
- [ ] Resource fit analyzed
- [ ] Risks identified and rated
- [ ] Clear recommendation provided
- [ ] Key questions surfaced
</success_criteria>
