<purpose>
Add new items to the project backlog with structured tracking and deduplication.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_context">
**Load backlog context:**

Check for existing backlog files:
```bash
ls .planning/backlog/ 2>/dev/null
```

If no .planning/backlog/ directory, create it:
```bash
mkdir -p .planning/backlog
```

Load STATE.md for project context.
</step>

<step name="capture_item">
**Capture the backlog item:**

If $ARGUMENTS provided, use as item description.
Otherwise, ask user: "What would you like to add to the backlog?"

Gather additional details:
- Priority (critical/high/medium/low)
- Area/category (e.g., frontend, backend, infra, docs)
- Type (feature, bug, tech-debt, idea)

Generate a unique backlog ID (e.g., BLG-001, BLG-002).
</step>

<step name="deduplicate">
**Check for duplicates:**

Scan existing backlog items for similar titles or descriptions.
If a similar item exists, present it to the user.
</step>

<step name="create_item">
**Create backlog item file:**

Write to .planning/backlog/BLG-NNN.md with structure:
- ID, title, type, priority, area, created date, status
- Description
- Acceptance Criteria
- Notes
</step>

<step name="update_state">
**Update STATE.md:**

Increment backlog count in STATE.md.
Add entry to recent activity log.
</step>

<step name="confirm">
**Display confirmation:**

Show added item details and offer to add another.
</step>

</process>

<success_criteria>
- [ ] Backlog item captured with all fields
- [ ] Duplicate check performed
- [ ] Unique ID assigned
- [ ] File created in .planning/backlog/
- [ ] STATE.md updated
- [ ] Confirmation displayed
</success_criteria>
