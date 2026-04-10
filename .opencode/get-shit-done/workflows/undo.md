<purpose>
Reverse the most recent action taken by GSD, restoring previous state.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="identify_last_action">
**Identify the last action:** Get most recent commit, check STATE.md recent activity. Display identified action and confirm undo.
</step>

<step name="analyze_impact">
**Analyze impact of undo:** Determine affected files, dependent commits, STATE.md updates. Flag risks.
</step>

<step name="backup">
**Create backup before undo:** Create backup branch with timestamp for recovery capability.
</step>

<step name="revert">
**Execute the revert:** For last commit use git revert HEAD. For specific files checkout from previous commit. Update STATE.md.
</step>

<step name="verify">
**Verify the revert:** Check working tree, verify reverted files in expected state, run tests.
</step>

<step name="confirm">
**Display confirmation:** Show what was reverted, files restored, state updated, tests status, recovery instructions.
</step>

</process>

<success_criteria>
- [ ] Last action identified
- [ ] Impact analyzed and risks flagged
- [ ] Backup created before undo
- [ ] Revert applied cleanly
- [ ] STATE.md updated
- [ ] Working tree verified
- [ ] Recovery instructions provided
</success_criteria>
