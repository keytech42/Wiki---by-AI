#!/usr/bin/env bash
# Wrapper to enforce reading FULL details of issues and filtering by persona/type

TYPE=""
STATUS="open,in_progress,blocked"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --type=*) TYPE="${1#*=}"; shift ;;
        --status=*) STATUS="${1#*=}"; shift ;;
        -h|--help) 
            echo "Usage: bash .agents/scripts/read_issues.sh [--type=knowledge|meta|task] [--status=open,in_progress]"
            echo "Description: Forces the agent to read FULL details of issues (including Design & Acceptance Criteria)."
            exit 0 
            ;;
        *) echo "Unknown parameter passed: $1. Use --help"; exit 1 ;;
    esac
done

CMD_ARGS=(--status="$STATUS" --flat)
if [[ -n "$TYPE" ]]; then
    CMD_ARGS+=(--type="$TYPE")
fi

echo "======================================================================"
echo "🔍 Fetching Persona-Specific Backlog (Status: $STATUS | Type: ${TYPE:-ALL})"
echo "======================================================================"
echo ""

# Fetch raw list
RAW_LIST=$(bd list "${CMD_ARGS[@]}")

# Extract IDs (Fail-Fast on missing Unicode icons)
IDS=""
while IFS= read -r line; do
    # Skip empty lines or headers
    if [[ -z "$line" || "$line" != *"["* ]]; then
        continue
    fi
    
    # Check the first character
    first_char="${line:0:1}"
    if [[ "$first_char" =~ [a-zA-Z0-9] ]]; then
        echo "❌ [System Error] Missing Unicode status icon in 'bd list' output."
        echo "   Line: $line"
        echo "   Please check your terminal's Unicode support. The script expects icons like ○, ❄, ◐."
        exit 1
    fi
    
    # First column is icon, second is ID
    ID=$(echo "$line" | awk '{print $2}')
    IDS+="$ID"$'\n'
done <<< "$RAW_LIST"

IDS=$(echo "$IDS" | sort -u | grep -v '^$')

if [[ -z "$IDS" ]]; then
    echo "No matching issues found for this persona/status."
    exit 0
fi

for ID in $IDS; do
    bd show "$ID"
    echo ""
    echo "----------------------------------------------------------------------"
    echo ""
done
