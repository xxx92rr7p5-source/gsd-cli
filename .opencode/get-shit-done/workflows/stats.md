<purpose>
Display comprehensive statistics about the project and workspace.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="collect_phase_stats">
**Collect phase statistics:** Count total/completed phases, total plans/summaries from ROADMAP.md and phase directories.
</step>

<step name="collect_code_stats">
**Collect code statistics:** Count lines of code by language, file count, directory count.
</step>

<step name="collect_commit_stats">
**Collect commit history stats:** Total commits, commits this week, top contributors, commit frequency.
</step>

<step name="collect_test_stats">
**Collect test statistics:** Test file count, run test suite for results.
</step>

<step name="collect_issue_stats">
**Collect issue statistics:** Active debug sessions, pending/done todos, backlog items.
</step>

<step name="display">
**Display statistics dashboard:** Show progress, code, commits, tests, issues, and timeline sections.
</step>

</process>

<success_criteria>
- [ ] Phase statistics computed
- [ ] Code metrics gathered
- [ ] Commit history analyzed
- [ ] Test statistics collected
- [ ] Issue counts tallied
- [ ] Dashboard displayed clearly
</success_criteria>
