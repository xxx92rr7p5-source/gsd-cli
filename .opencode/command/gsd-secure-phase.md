---
description: Security-hardening phase execution
argument-hint: "[scope or specific area]"
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
Execute a security-hardening phase across the codebase.

Identifies and remediates security vulnerabilities, implements security best practices, hardens configurations, and adds security tests. Covers input validation, authentication, authorization, data protection, and dependency security.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/secure-phase.md
</execution_context>

<context>
Scope: $ARGUMENTS

@.planning/STATE.md (if available)
</context>

<process>
Execute the secure-phase workflow from @./.opencode/get-shit-done/workflows/secure-phase.md end-to-end.
Preserve all security dimensions (input validation, auth, data protection, dependencies, configuration hardening, security testing).
</process>

<success_criteria>
- [ ] Security scan completed
- [ ] Vulnerabilities identified and prioritized
- [ ] Hardening applied
- [ ] Security tests added
- [ ] Security report generated
</success_criteria>
