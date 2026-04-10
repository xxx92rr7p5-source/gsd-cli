<purpose>
Review plans and implementations from a design and architecture perspective.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_target">
**Load the target for review:** Parse $ARGUMENTS for plan reference or component. Load target, PROJECT.md for design intent, ARCHITECTURE.md for architecture.
</step>

<step name="review_architecture">
**Review architecture alignment:** Follows established architecture, respects layer boundaries, appropriate component decomposition, consistent data flow patterns, no architectural debt. Score the alignment.
</step>

<step name="review_patterns">
**Review pattern adherence:** Design patterns used appropriately, no anti-patterns, SOLID principles, DRY, separation of concerns. Note specific violations.
</step>

<step name="review_scalability">
**Review scalability:** Will design scale with load, bottlenecks, data model scalability, caching strategies, state management for scale. Flag concerns with severity.
</step>

<step name="review_maintainability">
**Review maintainability:** Module organization clarity, abstraction level, coupling, testability, debuggability, ease of extension.
</step>

<step name="review_consistency">
**Review design consistency:** Naming conventions, API design patterns, error handling approach, configuration management, UI patterns.
</step>

<step name="generate_review">
**Generate design review report:** Score architecture, patterns, scalability, maintainability, consistency. List recommendations with rationale. Provide verdict (Approved/Approved with notes/Needs redesign).
</step>

</process>

<success_criteria>
- [ ] Target loaded with design context
- [ ] Architecture alignment assessed
- [ ] Pattern adherence checked
- [ ] Scalability evaluated
- [ ] Maintainability assessed
- [ ] Design consistency verified
- [ ] Review report with verdict
</success_criteria>
