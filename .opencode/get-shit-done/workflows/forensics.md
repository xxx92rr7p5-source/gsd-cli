<purpose>
Conduct forensic investigation of a past incident to determine root cause, timeline, and contributing factors.
</purpose>

<required_reading>
Read all files referenced by the invoking prompt's execution_context before starting.
</required_reading>

<process>

<step name="initialize">
**Initialize investigation:** Parse $ARGUMENTS. Create workspace in .planning/forensics/. Generate INC-NNN ID.
</step>

<step name="timeline">
**Reconstruct timeline:** Gather evidence from git log, file changes, debug logs. Build chronological table.
</step>

<step name="root_cause">
**Determine root cause:** Analyze timeline for trigger, contributing factors, amplifiers. Use 5 Whys.
</step>

<step name="impact">
**Assess impact:** Determine scope, duration, users affected, data impact.
</step>

<step name="remediation">
**Define remediation:** For each cause: immediate fix, prevention, detection, process improvement.
</step>

<step name="report">
**Generate incident report:** Write to .planning/forensics/INC-NNN.md with full analysis.
</step>

</process>

<success_criteria>
- [ ] Timeline reconstructed from evidence
- [ ] Root cause identified with evidence
- [ ] Contributing factors documented
- [ ] Impact assessed
- [ ] Remediation actions defined
- [ ] Incident report generated
</success_criteria>
