# GitLab CLI (`glab`) Command Reference

Operational guide for autonomous, non-interactive Git and Merge Request workflows.

---

## 1. Core Commands for SDLC Automation

### 1.1 Create Draft Merge Request (Non-Interactive)

```bash
glab mr create \
  --title "feat({FormattedID}): {concise_title}" \
  --description-file .docs/report.md \
  --target-branch main \
  --source-branch "{BRANCH_NAME}" \
  --draft \
  --assignee @me \
  --label "bot-generated,{FormattedID}" \
  --yes
```

> **Expected output:**  
> Returns the Merge Request URL (e.g., `https://gitlab.example.com/org/repo/-/merge_requests/42`). Capture the URL and numeric identifier (`IID`).

### 1.2 Add Automated Verification Note to MR

```bash
glab mr note create {MR_IID} -m "## 🤖 Automated Validation Report
- **Rally Story:** {FormattedID}
- **Tests:** {PASS_COUNT}/{TOTAL_COUNT} passing (100%)
- **Documentation:** \`.docs/requirements.md\`, \`.docs/design.md\`, \`.docs/report.md\`

Merge Request created in **Draft** mode awaiting human review."
```

### 1.3 Inspection & Authentication Checks

```bash
# Check CLI authentication
glab auth status

# Inspect MR status
glab mr view {MR_IID}
```

---

## 2. Mandatory Safety Flags

| Flag | Category | Rationale |
| :--- | :--- | :--- |
| `--yes` | **Mandatory** | Suppresses interactive prompts on stdin to avoid blocking execution. |
| `--draft` | **Mandatory** | Marks MR as work-in-progress, preventing premature merge or pipeline execution before human sign-off. |
