<purpose>
Analyze current project state and intelligently determine the next best action.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_state">
**Load project state:** Load STATE.md, ROADMAP.md, PROJECT.md. If no planning dir, suggest /gsd-new-project.
</step>

<step name="analyze_position">
**Determine current position:** From STATE.md and ROADMAP.md: current phase, plan status, paused work, todos, debug sessions.
</step>

<step name="count_phase_artifacts">
**Count phase artifacts:** Count plans, summaries, UAT files, context files for current phase. Check for UAT gaps.
</step>

<step name="route">
**Determine next action:** Apply routing logic based on phase artifact counts and state.
</step>

<step name="present">
**Present recommendation:** Show recommended command with rationale, context, and alternative actions.
</step>

</process>

<success_criteria>
- [ ] Project state fully loaded
- [ ] Current position determined
- [ ] Phase artifacts counted
- [ ] Next action determined by routing logic
- [ ] Recommendation presented with rationale
- [ ] Alternative actions listed
</success_criteria>
