#!/usr/bin/env bash
# ==============================================================================
# Script: validate-rally-fields.sh
# Purpose: Validate the integrity of fields extracted from Rally WSAPI and
#          enforce state machine rules before processing.
# Exit codes:
#   0 - Validation successful (Ready to process)
#   1 - Error: Missing or malformed required fields
#   2 - Critical error: Artifact in 'Accepted' state (Immutable, abort)
#   3 - Warning: Artifact in 'Completed' state (Requires human confirmation)
# ==============================================================================

set -euo pipefail

INPUT_FILE="${1:-}"

# Read from file or standard input
if [ -n "$INPUT_FILE" ] && [ -f "$INPUT_FILE" ]; then
    CONTENT=$(tr -d '\r' < "$INPUT_FILE")
elif [ ! -t 0 ]; then
    CONTENT=$(cat | tr -d '\r')
else
    echo "ERROR: Must provide a JSON file or pass data via stdin." >&2
    echo "Usage: $0 <rally-payload.json> or cat payload.json | $0" >&2
    exit 1
fi

# Extract key fields safely supporting python, node, jq, or grep/sed
extract_json_val() {
    local key="$1"
    if command -v python3 >/dev/null 2>&1; then
        printf '%s' "$CONTENT" | python3 -c "import sys, json; print(json.load(sys.stdin).get(sys.argv[1], ''))" "$key" 2>/dev/null || echo ""
    elif command -v python >/dev/null 2>&1; then
        printf '%s' "$CONTENT" | python -c "import sys, json; print(json.load(sys.stdin).get(sys.argv[1], ''))" "$key" 2>/dev/null || echo ""
    elif command -v jq >/dev/null 2>&1; then
        printf '%s' "$CONTENT" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null || echo ""
    elif command -v node >/dev/null 2>&1; then
        printf '%s' "$CONTENT" | node -e "let b='';process.stdin.on('data',c=>b+=c);process.stdin.on('end',()=>{try{console.log(JSON.parse(b)[process.argv[1]]||'')}catch(e){}});" "$key" 2>/dev/null || echo ""
    else
        printf '%s' "$CONTENT" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/' || echo ""
    fi
}

FORMATTED_ID=$(extract_json_val "FormattedID")
NAME=$(extract_json_val "Name")
SCHEDULE_STATE=$(extract_json_val "ScheduleState")

echo "==> Validating Rally artifact..."

# 1. Validate FormattedID presence and format
if [ -z "$FORMATTED_ID" ]; then
    echo "❌ ERROR: 'FormattedID' field is required and was not found." >&2
    exit 1
fi

if ! echo "$FORMATTED_ID" | grep -Eq '^(US|DE)[0-9]+$'; then
    echo "⚠️ WARNING: 'FormattedID' ($FORMATTED_ID) does not match standard pattern (US12345 or DE12345)." >&2
fi

# 2. Validate Name / Title presence
if [ -z "$NAME" ]; then
    echo "❌ ERROR: 'Name' (story title) field is empty." >&2
    exit 1
fi

# 3. Validate ScheduleState
if [ -z "$SCHEDULE_STATE" ]; then
    echo "⚠️ WARNING: 'ScheduleState' not defined. Defaulting to 'Defined'." >&2
    SCHEDULE_STATE="Defined"
fi

echo "    - FormattedID:    $FORMATTED_ID"
echo "    - Name:           $NAME"
echo "    - ScheduleState:  $SCHEDULE_STATE"

if [ "$SCHEDULE_STATE" = "Accepted" ]; then
    echo "🛑 [CRITICAL ERROR] [Code 2]: Artifact $FORMATTED_ID is already in 'Accepted' state." >&2
    echo "    Accepted stories are immutable per audit policies." >&2
    echo "    ABORTING process." >&2
    exit 2
fi

if [ "$SCHEDULE_STATE" = "Completed" ]; then
    echo "⚠️ [WARNING] [Code 3]: Artifact $FORMATTED_ID is already marked as 'Completed'." >&2
    echo "    Explicit human confirmation is required to re-process." >&2
    exit 3
fi

if [ "$SCHEDULE_STATE" = "Defined" ]; then
    echo "✅ [OK]: Artifact ready. Transitioning 'Defined' -> 'In-Progress'."
    exit 0
fi

if [ "$SCHEDULE_STATE" = "In-Progress" ]; then
    echo "✅ [OK]: Artifact in progress ('In-Progress'). Continuing development."
    exit 0
fi

echo "⚠️ [WARNING]: State '$SCHEDULE_STATE' is non-standard but processable."
exit 0
