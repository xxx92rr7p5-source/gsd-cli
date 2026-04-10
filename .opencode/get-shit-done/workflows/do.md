<purpose>
Execute a general-purpose task with full GSD workflow guarantees.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="understand_task">
**Clarify the task:** Parse $ARGUMENTS. Ask 1-2 questions if needed. Load project context.
</step>

<step name="scope">
**Scope the work:** Determine complexity. For non-trivial tasks, create brief plan. Confirm with user.
</step>

<step name="execute">
**Execute the work:** Simple tasks directly. Complex tasks with spawned agents.
</step>

<step name="verify">
**Verify the results:** Check completion, run tests, verify no regressions.
</step>

<step name="commit">
**Commit changes:** Stage and commit with atomic message.
</step>

<step name="update_state">
**Update STATE.md:** Record activity, decisions, open issues.
</step>

<step name="report">
**Report results:** Display changes, commits, test status.
</step>

</process>

<success_criteria>
- [ ] Task understood and scoped
- [ ] Plan created (for non-trivial tasks)
- [ ] Work executed correctly
- [ ] Results verified
- [ ] Changes committed atomically
- [ ] STATE.md updated
- [ ] User informed of results
</success_criteria>
