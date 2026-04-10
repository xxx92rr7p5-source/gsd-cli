<purpose>
Explore and discover information about the codebase, domain, or a specific topic.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="define_scope">
**Define exploration scope:** Parse $ARGUMENTS. Determine 2-4 focus areas.
</step>

<step name="spawn_explorers">
**Spawn parallel exploration agents:** For each focus area, spawn agent with deliverables.
</step>

<step name="collect_findings">
**Collect findings:** Gather results, group by theme, identify overlaps.
</step>

<step name="synthesize">
**Synthesize discovery document:** Write to .planning/discovery/[slug].md.
</step>

<step name="present">
**Present discovery:** Display synthesis with key findings and next actions.
</step>

</process>

<success_criteria>
- [ ] Exploration scope defined
- [ ] Parallel agents dispatched
- [ ] All agents completed
- [ ] Findings synthesized
- [ ] Discovery document created
- [ ] Next steps suggested
</success_criteria>
