<purpose>
Take a rough project idea and develop it into a structured seed document.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="capture_idea">
**Capture the initial idea:** Parse $ARGUMENTS. If vague, ask for the idea. Get it in the user's own words.
</step>

<step name="explore">
**Explore through questions:** Ask targeted questions about problem, users, value, differentiation, scope, constraints.
</step>

<step name="research_feasibility">
**Assess feasibility:** Research similar solutions, technical feasibility, resource estimate.
</step>

<step name="scope">
**Define scope:** Draft MVP, V1, and Future scope. Identify what to include and defer.
</step>

<step name="identify_risks">
**Identify risks:** Technical, market, resource risks, and unknowns needing validation.
</step>

<step name="create_seed">
**Create seed document:** Write to .planning/seeds/[slug].md with problem, solution, users, value, scope, feasibility, risks.
</step>

<step name="route">
**Suggest next steps:** /gsd-new-project to build, /gsd-explore for more research, or revise seed document.
</step>

</process>

<success_criteria>
- [ ] Idea captured in user's words
- [ ] Exploration questions answered
- [ ] Feasibility assessed
- [ ] Scope defined (MVP/V1/Future)
- [ ] Risks identified
- [ ] Seed document created
- [ ] Next steps suggested
</success_criteria>
