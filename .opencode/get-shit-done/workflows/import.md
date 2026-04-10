<purpose>
Import an external project, codebase, or dataset into the current workspace.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="identify_source">
**Identify source:** Parse $ARGUMENTS for path, URL, or description. Download if remote.
</step>

<step name="analyze_source">
**Analyze the source:** Examine structure, tech stack, dependencies, build system.
</step>

<step name="check_compatibility">
**Check compatibility:** Stack conflicts, dependency mismatches, naming collisions, license.
</step>

<step name="plan_import">
**Create import plan:** Determine target location, adaptations, dependencies. Get confirmation.
</step>

<step name="execute_import">
**Execute:** Create target, copy content, run adaptations, install deps, verify build.
</step>

<step name="update_planning">
**Update planning:** Run /gsd-map-codebase or /gsd-new-project. Update STATE.md.
</step>

<step name="cleanup">
**Clean up:** Remove temp files. Commit the import.
</step>

</process>

<success_criteria>
- [ ] Source identified and downloaded
- [ ] Source analyzed and understood
- [ ] Compatibility checked
- [ ] Import plan created and confirmed
- [ ] Content imported successfully
- [ ] Planning artifacts updated
- [ ] Temporary files cleaned up
</success_criteria>
