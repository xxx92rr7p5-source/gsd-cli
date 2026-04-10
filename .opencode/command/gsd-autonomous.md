---
description: Fully autonomous execution mode
argument-hint: "[task or plan description]"
tools:
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
  task: true
---
<objective>
Execute work in fully autonomous mode with minimal user interaction.

The orchestrator delegates to specialized agents, makes decisions based on existing project context, and produces results without pausing for confirmation. Use when requirements are clear and you want maximum throughput.

**Warning:** This mode skips approval gates. Only use when you trust the project context and want unblocked execution.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/autonomous.md
@.planning/STATE.md
</execution_context>

<context>
Task: $ARGUMENTS

**Autonomous mode characteristics:**
- No confirmation prompts for intermediate steps
- Agents make best-judgment decisions
- Results committed on completion
- Summary provided when done
</context>

<process>
Execute the autonomous workflow from @./.opencode/get-shit-done/workflows/autonomous.md end-to-end.
All approval gates are bypassed. Agents operate with full autonomy within project conventions.
</process>

<success_criteria>
- [ ] Task decomposed and delegated
- [ ] All subagents completed work
- [ ] Changes committed
- [ ] Summary generated
- [ ] STATE.md updated
</success_criteria>
