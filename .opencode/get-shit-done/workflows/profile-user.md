<purpose>
Create or update user profiles with behavioral patterns, preferences, and interaction history.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="load_existing">
**Load existing profile:** Check .planning/profiles/ or .gsd/profiles/. Note existing data or start fresh.
</step>

<step name="gather_context">
**Gather user context:** Ask about role, experience, preferences, goals, constraints. Keep conversational.
</step>

<step name="analyze_patterns">
**Analyze interaction patterns:** From conversation history: communication style, decision patterns, technical preferences, pain points.
</step>

<step name="create_profile">
**Create or update profile:** Write structured profile with role, preferences, goals, constraints, observed patterns, history.
</step>

<step name="apply">
**Apply profile to session:** Note how profile should influence interactions. Confirm key preferences noted.
</step>

</process>

<success_criteria>
- [ ] Existing profile loaded (if any)
- [ ] User context gathered
- [ ] Interaction patterns analyzed
- [ ] Profile created or updated
- [ ] Profile applied to current session
- [ ] Confirmation displayed
</success_criteria>
