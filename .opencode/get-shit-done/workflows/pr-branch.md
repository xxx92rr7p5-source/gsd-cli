<purpose>
Create and manage Git branches for pull requests.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="determine_action">
**Determine requested action:** Parse $ARGUMENTS for branch name, PR description, or show current status.
</step>

<step name="create_branch">
**Create branch:** Generate branch name from description. Commit uncommitted work first. Create and switch to branch.
</step>

<step name="generate_pr_description">
**Generate PR description:** Analyze commits on branch. Generate summary, changes list, testing instructions.
</step>

<step name="manage_lifecycle">
**Manage branch lifecycle:** Support list open branches, clean up merged, rebase on main, show branch status.
</step>

<step name="confirm">
**Display confirmation:** Show branch name, commit count, status, PR description, push/PR commands.
</step>

</process>

<success_criteria>
- [ ] Branch created or switched to
- [ ] Work committed before branching
- [ ] PR description generated
- [ ] Branch status clear
- [ ] Push/PR commands provided
</success_criteria>
