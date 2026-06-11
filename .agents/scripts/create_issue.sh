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
        --type=*) TYPE="${1#*=}"; CMD_ARGS+=("$1"); shift ;;
        --deps=*) DEPS="${1#*=}"; CMD_ARGS+=("$1"); shift ;;
        *) CMD_ARGS+=("$1"); shift ;; # Capture all other advanced flags (--acceptance, --design, etc.)
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
BD_EXIT_CODE=$?

# Advanced Flags Warning & Reminders (Agent Reflection Prompt)
if [[ $BD_EXIT_CODE -eq 0 ]]; then
    echo ""
    echo "=========================================================="
    echo "💡 [Agent Reflection: Advanced Context Flags]"
    echo "=========================================================="
    if [[ -z "$DEPS" ]]; then
        echo "⚠️ MISSING EDGE CONNECTION: You created an issue without --deps."
        echo "   Rule Reminder: The workspace is a Graph. Isolated nodes are anti-patterns unless it is a true Root Node."
        echo "   Action: If you forgot a blocker/epic, use 'bd dep add' immediately."
        echo ""
    fi
    echo "Did you maximize the context density? Keep these powerful flags in mind for future use:"
    echo "  - '--design=\"...\"' : Record architectural rationale and geometric mapping insights."
    echo "  - '--acceptance=\"...\"' : Define clear 'Definition of Done'."
    echo "  - '--notes=\"...\"' : Add supplementary background context."
    echo "  - '--skills=\"...\"' : Bind specific agent skills needed for this task."
    echo "=========================================================="
fi

exit $BD_EXIT_CODE
