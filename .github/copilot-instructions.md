# GitHub Copilot Instructions — SDLC Automation Workspace

High-level directives and routing for GitHub Copilot and Agent Mode in this workspace (Python / Java).

---

## 1. Routing & Agent Trigger

When the user mentions a Rally ticket (`US\d+`, `DE\d+`) or requests *"automate this issue"*, *"issue to PR"*, *"create MR for..."*:
- Delegate full execution to the `@sdlc-orchestrator` agent (`.github/agents/sdlc-orchestrator.agent.md`).
- Execution is governed by the `sdlc-automation` skill (`.github/skills/sdlc-automation/SKILL.md`).

---

## 2. Inviolable Core Principles

1. **Spec-Driven Development:** NEVER create or modify functional code without approved specifications in `.docs/requirements.md` (EARS) and `.docs/design.md`.
2. **Human-in-the-Loop (4 Mandatory Gates):** Pause execution and require explicit user approval at:
   - **Gate 1:** Rally issue ingestion and scope validation.
   - **Gate 2:** Technical specifications approval (`requirements.md` + `design.md`).
   - **Gate 3:** Code implementation and test suite pass rate (100% green).
   - **Gate 4:** Draft Merge Request verification in GitLab.
3. **Traceability:** Mandatory header comment in every created or modified file:
   - Python: `# Rally: {FormattedID} — EARS Requirement: {REQ_ID}`
   - Java: `// Rally: {FormattedID} — EARS Requirement: {REQ_ID}`
4. **Operational Safety:** All MRs are created with `--draft`. Destructive git operations (`git push --force`) and blocking interactive commands are strictly forbidden.
