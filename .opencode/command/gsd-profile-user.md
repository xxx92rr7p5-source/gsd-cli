---
description: User profiling and analysis
argument-hint: "[user identifier or context]"
tools:
  read: true
  write: true
  bash: true
  task: true
  question: true
---
<objective>
Create or update user profiles with behavioral patterns, preferences, and interaction history.

Builds understanding of user context to personalize workflows, anticipate needs, and optimize interaction patterns. Stores profile data in structured format for future sessions.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/profile-user.md
</execution_context>

<context>
User context: $ARGUMENTS

Existing profiles will be loaded if available.
</context>

<process>
Execute the profile-user workflow from @./.opencode/get-shit-done/workflows/profile-user.md end-to-end.
Preserve profile creation, update, and analysis steps.
</process>

<success_criteria>
- [ ] User context analyzed
- [ ] Profile created or updated
- [ ] Patterns and preferences documented
- [ ] Profile stored for future sessions
</success_criteria>
