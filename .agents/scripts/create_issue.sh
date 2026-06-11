#!/usr/bin/env bash
# Wrapper script for 'bd create' to enforce semantic type mappings (Hard Rule)

TITLE=""
TYPE=""
DEPS=""
CMD_ARGS=()

# Parse all arguments. Intercept specific ones for validation, pass everything else blindly.
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --title=*) TITLE="${1#*=}"; CMD_ARGS+=("$1"); shift ;;
        --title) TITLE="$2"; CMD_ARGS+=("$1" "$2"); shift 2 ;;
        --type=*) TYPE="${1#*=}"; CMD_ARGS+=("$1"); shift ;;
        --type) TYPE="$2"; CMD_ARGS+=("$1" "$2"); shift 2 ;;
        --deps=*) DEPS="${1#*=}"; CMD_ARGS+=("$1"); shift ;;
        --deps) DEPS="$2"; CMD_ARGS+=("$1" "$2"); shift 2 ;;
        *) CMD_ARGS+=("$1"); shift ;; # Capture all other flags blindly
    esac
done

if [[ -z "$TITLE" || -z "$TYPE" ]]; then
    echo "Error: Missing required arguments. (--title and --type are required)"
    exit 1
fi

fail_with_reflection() {
    local reason="$1"
    echo "❌ [Semantic Type Error] $reason"
    echo ""
    echo "=========================================================="
    echo "🧠 [Agent Reflection Trigger] System Guidelines Reminder"
    echo "=========================================================="
    echo "As an AI Agent, you have violated the structural topology of the workspace."
    echo "You MUST self-verify your classification against the core guide:"
    echo "  - '--type=knowledge' : STRICTLY for Zettelkasten deep-dives, research, and documentation (Graph: Knowledge). Valid prefixes: [Docs], [Concept], [Session], [Wiki]."
    echo "  - '--type=meta' : STRICTLY for workspace infrastructure, agent rules, and system upgrades (Graph: Meta). Valid prefixes: [Infra], [System], [Meta]."
    echo "  - '--type=task' : Standard coding/bug fixes."
    echo ""
    echo "Self-Correction Instruction for Agent:"
    echo "1. Stop and analyze the core intent of your issue."
    echo "2. Ask yourself: 'Am I building the Knowledge Graph, the Meta Graph, or just writing code?'"
    echo "3. Fix the '--type' or title prefix and run this script again."
    exit 1
}

# Semantic Validation
if [[ "$TITLE" =~ ^\[(Infra|System|Meta)\] ]]; then
    if [[ "$TYPE" != "meta" ]]; then
        fail_with_reflection "Title indicates Meta/Infra work, but --type is not 'meta'."
    fi
elif [[ "$TITLE" =~ ^\[(Docs|Wiki|Zettelkasten|Concept|Session)\] ]]; then
    if [[ "$TYPE" != "knowledge" ]]; then
        fail_with_reflection "Title indicates Knowledge/Zettelkasten work, but --type is not 'knowledge'."
    fi
elif [[ "$TYPE" == "meta" || "$TYPE" == "knowledge" ]]; then
    fail_with_reflection "You used a custom type ('$TYPE') without a proper semantic prefix in the title."
fi

# Pass validation, execute bd create
echo "✅ Semantic validation passed. Creating issue..."
bd create "${CMD_ARGS[@]}"
EXIT_CODE=$?

# If successful, output the nudge
if [[ $EXIT_CODE -eq 0 ]]; then
    if [[ -z "$DEPS" ]]; then
        echo ""
        echo "=========================================================="
        echo "⚠️ [Agent Reflection: Missing Dependencies]"
        echo "=========================================================="
        echo "You just created an isolated issue without the '--deps' flag."
        echo "Creating isolated nodes is an Anti-pattern in this workspace."
        echo "If this issue is related to an existing Epic or Blocker, please"
        echo "immediately link them using the 'bd dep add' command."
        echo "=========================================================="
        echo ""
    fi
    
    echo ""
    echo "=========================================================="
    echo "💡 [Agent Reflection: Advanced Context Flags]"
    echo "=========================================================="
    echo "Did you maximize the context density? Keep these in mind:"
    echo " - [--design]: Specify architectural constraints or rationale."
    echo " - [--acceptance]: Clearly define the 'Definition of Done'."
    echo " - [--skills]: Pre-bind required agent skills for this task."
    echo "Rich context prevents memory loss in future sessions."
    echo "=========================================================="
    echo ""
fi

exit $EXIT_CODE
