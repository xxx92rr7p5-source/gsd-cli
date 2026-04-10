<purpose>
Execute work in fully autonomous mode with minimal user interaction.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_task">
**Understand the task:** Parse $ARGUMENTS. Ask one clarifying question if ambiguous. Load project context.
</step>

<step name="plan">
**Create execution plan:** Decompose into subtasks, identify agent types and dependencies.
</step>

<step name="delegate">
**Spawn agents:** For each subtask, spawn appropriate agent. Run independent tasks in parallel.
</step>

<step name="integrate">
**Integrate results:** Collect outputs, resolve conflicts, ensure consistency.
</step>

<step name="commit">
**Commit changes:** Stage and commit with atomic, descriptive messages.
</step>

<step name="report">
**Generate summary:** Display task summary, subtasks completed, changes, commits, and notes.
</step>

</process>

<success_criteria>
- [ ] Task understood
- [ ] Work decomposed and delegated
- [ ] All subagents completed
- [ ] Changes integrated cleanly
- [ ] Committed atomically
- [ ] Summary provided
</success_criteria>
