<purpose>
Capture notes and associate them with the current project context.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="capture_note">
**Capture the note:** Parse $ARGUMENTS or ask. Collect optional metadata (area, tags, priority).
</step>

<step name="store_note">
**Store the note:** Create .planning/notes/ if needed. Write timestamped note file.
</step>

<step name="link_to_context">
**Link to project context:** If STATE.md exists, append note reference to recent activity.
</step>

<step name="confirm">
**Confirm storage:** Show file path and retrieval instructions.
</step>

</process>

<success_criteria>
- [ ] Note content captured
- [ ] Metadata collected (area, tags, priority)
- [ ] Note file created with timestamp
- [ ] Note linked to project context
- [ ] Storage confirmed to user
</success_criteria>
