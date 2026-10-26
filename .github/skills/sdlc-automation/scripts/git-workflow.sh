#!/usr/bin/env bash
# ==============================================================================
# Script: git-workflow.sh
# Purpose: Automate Git and GitLab CLI workflow on Unix/Linux/macOS:
#          Branch creation, conventional commit, remote push, and Draft MR generation.
# Parameters:
#   $1 - Rally FormattedID (e.g. US10293)
#   $2 - Requirement title (e.g. "Implement Session Timeout Warning")
#   $3 - Target branch (optional, default: main)
#   $4 - MR description file (optional, default: .docs/report.md)
# ==============================================================================

set -euo pipefail

FORMATTED_ID="${1:-}"
TITLE="${2:-}"
TARGET_BRANCH="${3:-main}"
DESC_FILE="${4:-.docs/report.md}"

if [ -z "$FORMATTED_ID" ] || [ -z "$TITLE" ]; then
    echo "ERROR: Missing required parameters." >&2
    echo "Usage: $0 <FormattedID> <Title> [TargetBranch] [DescriptionFile]" >&2
    exit 1
fi

# 1. Validate that git is initialized
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: Current directory is not a valid Git repository." >&2
    exit 1
fi

# 2. Validate description file
if [ ! -f "$DESC_FILE" ]; then
    if [ -f ".docs/mr-description.md" ]; then
        DESC_FILE=".docs/mr-description.md"
    else
        echo "WARNING: Report file $DESC_FILE not found. Creating fallback description." >&2
        mkdir -p .docs
        cat <<EOF > .docs/temp-mr-desc.md
# feat($FORMATTED_ID): $TITLE

SDLC automation completed by Agent.
Rally ID: $FORMATTED_ID
EOF
        DESC_FILE=".docs/temp-mr-desc.md"
    fi
fi

# 3. Generate sanitized branch slug
CLEAN_TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | cut -c 1-40)
BRANCH_NAME="feature/${FORMATTED_ID}-${CLEAN_TITLE}"

echo "==> Creating working branch: $BRANCH_NAME"
git checkout -B "$BRANCH_NAME"

# 4. Stage and create conventional commit
echo "==> Staging local changes..."
git add .

if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "NOTICE: No local modifications detected to commit."
else
    COMMIT_MSG="feat(${FORMATTED_ID}): ${TITLE}

- Implements approved requirements for Rally ${FORMATTED_ID}
- Specifications: .docs/requirements.md
- Technical design: .docs/design.md
- Bidirectional Rally-GitLab traceability

Rally-Issue: ${FORMATTED_ID}"

    git commit -m "$COMMIT_MSG"
    echo "==> Conventional commit created successfully."
fi

# 5. Push branch to remote origin
echo "==> Pushing branch upstream..."
if git remote | grep -q "origin"; then
    git push -u origin HEAD
else
    echo "NOTICE: No 'origin' remote found. Skipping 'git push'." >&2
fi

# 6. Create Draft Merge Request via glab CLI
echo "==> Creating Draft Merge Request via glab CLI..."
if command -v glab >/dev/null 2>&1; then
    MR_OUTPUT=$(glab mr create \
        --title "feat(${FORMATTED_ID}): ${TITLE}" \
        --description-file "$DESC_FILE" \
        --target-branch "$TARGET_BRANCH" \
        --source-branch "$BRANCH_NAME" \
        --draft \
        --assignee @me \
        --label "bot-generated,${FORMATTED_ID}" \
        --yes 2>&1 || true)

    echo "$MR_OUTPUT"

    MR_URL=$(echo "$MR_OUTPUT" | grep -Eo 'https?://[^ ]+/merge_requests/[0-9]+' | head -n 1 || echo "")
    MR_IID=$(echo "$MR_URL" | grep -Eo '[0-9]+$' || echo "")

    if [ -n "$MR_IID" ] && [ -n "$MR_URL" ]; then
        echo "==> Adding automated validation note to MR #$MR_IID..."
        glab mr note create "$MR_IID" -m "## 🤖 Automated Validation Report
- **Rally Story:** $FORMATTED_ID
- **Documentation:** \`.docs/requirements.md\` and \`.docs/design.md\`
- **Post-Task Report:** \`.docs/report.md\`

Merge Request created in **Draft** mode awaiting human review." >/dev/null 2>&1 || true
    fi

    cat <<EOF

================================================================================
GIT WORKFLOW RESULT:
BRANCH_NAME=$BRANCH_NAME
MR_URL=${MR_URL:-"Not available / Pending verification"}
MR_IID=${MR_IID:-"N/A"}
================================================================================
EOF
else
    echo "WARNING: 'glab' binary is not installed in the environment." >&2
    echo "Branch '$BRANCH_NAME' was created locally." >&2
fi
