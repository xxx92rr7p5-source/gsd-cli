---
description: Forensic investigation for post-incident analysis
argument-hint: "[incident description or time range]"
tools:
  read: true
  bash: true
  glob: true
  grep: true
  task: true
  write: true
  question: true
---
<objective>
Conduct forensic investigation of a past incident to determine root cause, timeline, and contributing factors.

Reconstructs what happened, when, why, and how to prevent recurrence. Produces a structured incident report with timeline, root cause analysis, and remediation actions.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/forensics.md
</execution_context>

<context>
Incident: $ARGUMENTS

@.planning/STATE.md (if available)
Git log and history will be analyzed for timeline reconstruction.
</context>

<process>
Execute the forensics workflow from @./.opencode/get-shit-done/workflows/forensics.md end-to-end.
Preserve all investigation phases (timeline reconstruction, root cause analysis, impact assessment, remediation planning).
</process>

<success_criteria>
- [ ] Incident timeline reconstructed
- [ ] Root cause identified with evidence
- [ ] Contributing factors documented
- [ ] Impact assessment completed
- [ ] Remediation actions defined
- [ ] Incident report generated
</success_criteria>
