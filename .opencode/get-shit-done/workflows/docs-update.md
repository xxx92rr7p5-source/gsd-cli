<purpose>
Update project documentation to reflect current codebase state and recent changes.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="assess_scope">
**Determine documentation scope:** Parse $ARGUMENTS for specific docs. If none, assess all documentation (README, API, architecture, setup, contribution, changelog). Check last modification dates.
</step>

<step name="identify_gaps">
**Identify documentation gaps:** Compare codebase state against docs. New features without docs, changed APIs with outdated docs, removed features still documented.
</step>

<step name="prioritize">
**Prioritize updates:** Critical (misleading/incorrect), High (missing docs for shipped features), Medium (outdated), Low (nice-to-have).
</step>

<step name="update_docs">
**Update documentation:** For each gap, read source, update or create docs, ensure consistency. Use documentation agents for parallel work.
</step>

<step name="verify">
**Verify documentation quality:** Check links, code examples, formatting consistency, no contradictions, table of contents current.
</step>

<step name="commit">
**Commit documentation changes:** Stage and commit with docs: message.
</step>

<step name="report">
**Report documentation updates:** Display updated files, created files, remaining gaps, commits.
</step>

</process>

<success_criteria>
- [ ] Documentation inventory assessed
- [ ] Gaps identified and prioritized
- [ ] Critical gaps fixed
- [ ] Documentation verified for accuracy
- [ ] Changes committed
- [ ] Remaining gaps documented
</success_criteria>
