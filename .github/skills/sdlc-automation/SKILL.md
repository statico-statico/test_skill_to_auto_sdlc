---
name: sdlc-automation
description: >
  End-to-end SDLC automation skill transforming Rally issues into GitLab Merge Requests
  for Python and Java projects. Governs spec-driven development (EARS), hexagonal/layered architecture,
  self-healing test loops, glab CLI workflows, and 4 mandatory human gates.
license: proprietary
compatibility: >
  Requires glab CLI, Rally MCP server, Git, Python 3.10+ or Java 17+.
allowed-tools: terminal codebase editFiles fetch mcp:rally-mcp
metadata:
  version: "2.1.0"
  methodology: spec-driven-development
  supported-stacks: "Python, Java"
---

# SDLC Automation Skill — Standard Operating Procedure (SOP)

This skill defines the standardized sequence for transforming a Broadcom Rally issue into a verified GitLab Merge Request with mandatory human gates.

---

## 0. Activation Triggers
- Rally identifier in the prompt: `US\d+` (User Story) or `DE\d+` (Defect).
- User prompt: *"automate this issue"*, *"issue to PR"*, *"create MR for US..."*.

---

## Phase Matrix & Human Gates

| Phase | Core Action | Inputs / Tools | Output / Artifact | 🚪 Human Gate |
| :--- | :--- | :--- | :--- | :--- |
| **0. Stack** | Detect language and test runner | `detect-stack.bat` / `.sh` | Stack variables | Automated |
| **1. Ingest** | Fetch and validate Rally ticket | `mcp:rally-mcp` | Sanitized ticket data | **Gate 1:** Validate Scope |
| **2. Specs** | Formulate EARS & Architecture | `templates/requirements.md`, `design.md` | `.docs/requirements.md`, `.docs/design.md` | **Gate 2:** Approve Specs |
| **3. Build** | Implement code & test loop | `#editFiles`, test runner (max 3 retries) | Source code + 100% green tests | **Gate 3:** Approve Code |
| **4. GitLab** | Branch, commit, report & MR | `git`, `glab mr create --draft` | Remote branch + Draft MR + `.docs/report.md` | **Gate 4:** Verify MR |
| **5. Closure** | Sync & cross-reference Rally | `mcp:rally-mcp` | Rally `Completed` + discussion note | Final sign-off |

---

## Detailed Protocol by Phase

### Phase 0: Technology Stack Discovery
1. Run `.github/skills/sdlc-automation/scripts/detect-stack.bat` (Windows) or `detect-stack.sh` (Unix).
2. **Python:** Package manager (`poetry`/`pipenv`/`pip`), test runner (`pytest`/`unittest`), linter (`ruff`/`flake8`).
3. **Java:** Maven (`pom.xml` ➔ `mvn test`) or Gradle (`build.gradle` ➔ `gradle test`).

### Phase 1: Rally Ingestion & State Machine
1. Query Rally with minimum fields: `FormattedID,ObjectID,Name,Description,AcceptanceCriteria,ScheduleState,Owner,Iteration,Project`.
2. **State Machine Rules (`ScheduleState`):**
   - `Accepted`: **ABORT IMMEDIATELY** (immutable).
   - `Completed`: Warn user and request confirmation before reprocessing.
   - `Defined`: Promote to `In-Progress`.
   - `In-Progress`: Continue.
3. Sanitize HTML into clean Markdown.
4. 🚪 **Gate 1:** Present ticket ID, title, acceptance criteria count, and state transition. Wait for explicit confirmation.

### Phase 2: Technical Specifications (Spec-Driven)
1. **`.docs/requirements.md`:** Apply `templates/requirements.md`. Map each acceptance criterion to **EARS** (`references/ears-notation.md`):
   - `WHEN` (Event), `WHILE` (State), `IF` (Error/Exception), `WHERE` (Optional), `THE SYSTEM SHALL` (Ubiquitous).
2. **`.docs/design.md`:** Apply `templates/design.md`.
   - **Java:** **Mandatory Hexagonal Architecture** (`domain/` pure without framework imports, `application/port/`, `infrastructure/adapter/`).
   - **Python:** **Layered Architecture** (`routers/` ➔ `services/` ➔ `models/` ➔ `repositories/`), unless high-complexity core domain justifies hexagonal.
   - Mermaid diagram, file inventory, contracts, and test strategy.
3. 🚪 **Gate 2:** Present both documents. **DO NOT write functional code without explicit user approval.**

### Phase 3: Implementation & Self-Healing Loop
1. Implement changes adhering strictly to `.docs/design.md`.
2. Add inline traceability header to each affected file:
   - Python: `# Rally: {FormattedID} — EARS Requirement: {REQ_ID}`
   - Java: `// Rally: {FormattedID} — EARS Requirement: {REQ_ID}`
3. **Self-Healing Quality Loop:**
   - Run project test suite (`pytest` or `mvn/gradle test`).
   - If tests fail: diagnose trace, apply minimal surgical fix, re-run (max 3 iterations).
   - If still failing after 3 attempts: halt and request human assistance.
4. Validate against `references/quality-checklist.md` (zero exposed secrets, parameterized SQL, strictly typed validation).
5. 🚪 **Gate 3:** Present summary of changes, coverage, and 100% green tests. Wait for confirmation.

### Phase 4: Git Workflow & GitLab Draft MR
1. Run `.github/skills/sdlc-automation/scripts/git-workflow.bat` / `.sh`:
   - Branch: `feature/{FormattedID}-{title-slug}`
   - Commit: `feat({FormattedID}): {Title}`
   - Push: `git push -u origin HEAD`
2. Generate `.docs/report.md` with traceability matrix and metrics.
3. Create Draft MR:
   ```bash
   glab mr create --title "feat({FormattedID}): {Title}" \
     --description-file .docs/report.md \
     --target-branch main \
     --source-branch "$BRANCH_NAME" \
     --draft --assignee @me \
     --label "bot-generated,{FormattedID}" --yes
   ```
4. 🚪 **Gate 4:** Share MR URL and request approval to close Rally ticket.

### Phase 5: Rally Closure & Cross-Referencing
1. Transition Rally `ScheduleState` to `"Completed"`.
2. Post discussion note on Rally item with GitLab MR URL, branch name, and spec references.

---

## Safety Guardrails
1. **FORBIDDEN:** Destructive git commands (`git push --force`, remote `git reset --hard`).
2. **MANDATORY:** `--draft` flag on every Merge Request.
3. **MANDATORY:** Stop and wait at all 4 human gates.
4. **MANDATORY:** Abort if Rally item is already `Accepted`.
