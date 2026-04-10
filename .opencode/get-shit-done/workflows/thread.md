<purpose>
Manage threaded conversations and discussion context within the project.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="parse_action">
**Determine thread action:** Parse $ARGUMENTS: new, list, resume, archive. If no action, show current threads.
</step>

<step name="create_thread">
**Create a new thread:** Create .planning/threads/ if needed. Generate thread ID and slug. Write thread file with topic, discussion, decisions, open questions sections.
</step>

<step name="list_threads">
**List threads:** Scan .planning/threads/. For each, extract ID, title, status, creation date, last activity. Display table with counts.
</step>

<step name="resume_thread">
**Resume a thread:** Load thread file, display context (discussion, decisions, open questions). Capture new discussion and append.
</step>

<step name="archive_thread">
**Archive thread:** Summarize decisions and outcomes. Update status. Move to .planning/threads/archived/.
</step>

</process>

<success_criteria>
- [ ] Thread action identified
- [ ] Action executed (create/list/resume/archive)
- [ ] Thread file created or updated
- [ ] Decisions captured
- [ ] Status displayed
</success_criteria>
