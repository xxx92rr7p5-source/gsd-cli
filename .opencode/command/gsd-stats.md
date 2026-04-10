---
description: Show project and workspace statistics
tools:
  read: true
  bash: true
  grep: true
  glob: true
---
<objective>
Display comprehensive statistics about the project and workspace.

Shows phase counts, completion rates, lines of code, commit history, test coverage, issue counts, and other metrics that give a quantitative view of project health and progress.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/stats.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/ROADMAP.md
</context>

<process>
Execute the stats workflow from @./.opencode/get-shit-done/workflows/stats.md end-to-end.
Collect and display metrics across all dimensions (phases, code, commits, tests, issues).
</process>

<success_criteria>
- [ ] Phase statistics computed
- [ ] Code metrics gathered
- [ ] Commit history analyzed
- [ ] Test coverage reported
- [ ] Statistics displayed clearly
</success_criteria>
