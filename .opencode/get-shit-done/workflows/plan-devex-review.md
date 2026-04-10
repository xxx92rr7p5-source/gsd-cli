<purpose>
Review plans and implementations from a developer experience perspective.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_target">
**Load the target for review:** Parse $ARGUMENTS for plan, component, or API. Load target and any existing API docs, developer guides, or contribution guides.
</step>

<step name="review_api_design">
**Review API design:** Naming clarity and consistency, completeness, error handling quality, versioning strategy, backward compatibility, documentation completeness. Score: Good/Acceptable/Needs improvement/Poor.
</step>

<step name="review_ergonomics">
**Review developer ergonomics:** Setup experience, local development capability, feedback loop speed, tooling configuration, convention clarity, cognitive load.
</step>

<step name="review_documentation">
**Review documentation quality:** README coverage, API docs completeness, architecture docs explain the why, contribution guidelines, examples working, troubleshooting section, changelog.
</step>

<step name="review_onboarding">
**Review onboarding experience:** Setup time under 5 minutes, prerequisites documented, env vars clear, quickstart exists, common pitfalls documented.
</step>

<step name="review_error_handling">
**Review error handling and debugging:** Error messages actionable, stack traces useful, logging at appropriate levels, debug tools available, common errors documented.
</step>

<step name="generate_review">
**Generate DevEx review report:** Score each dimension (API, ergonomics, docs, onboarding, error handling). Provide DevEx score 1-10. Give actionable recommendations.
</step>

</process>

<success_criteria>
- [ ] Target loaded with context
- [ ] API design evaluated
- [ ] Developer ergonomics assessed
- [ ] Documentation quality checked
- [ ] Onboarding experience reviewed
- [ ] Error handling and debugging reviewed
- [ ] DevEx score provided
- [ ] Actionable recommendations given
</success_criteria>
