---
name: auto-rule-generator
description: Detects repetitive tasks and automatically appends rules to AGENTS.md or proposes new skills.
---

# Auto Rule Generator

## Purpose
This skill aligns with the AGENTS.md system instruction "반복 작업 탐지 및 자기 진화 규칙" (Repetitive Task Detection and Self-Evolution Rule). When an agent notices a workflow, script, or sequence of actions being repeated across multiple sessions, it should invoke this skill to codify the behavior into a permanent rule or a new skill.

## Triggers
- When the agent performs a manual repetitive action more than twice.
- When the user says "Make this a rule", "Remember how we did this", or "Add this to AGENTS.md".
- When an interaction pattern reveals a missing system prompt instruction.

## Actions
1. **Analyze the Pattern:** Identify the repeated steps, required context, and exact conditions under which this pattern applies.
2. **Determine Target:** 
   - If it's a simple heuristic or constraint, it belongs in `AGENTS.md` under a new or existing section.
   - If it's a complex multi-step workflow with scripts, create a new skill in `.agents/skills/`.
3. **Execute Update (Talk First):**
   - **CRITICAL:** Before modifying `AGENTS.md`, you MUST propose the specific rule addition to the user and receive their explicit approval (Talk First, Act Later).
   - Use the `view_file` tool to read the current `AGENTS.md` to find the right place.
   - Upon user approval, use `replace_file_content` or `multi_replace_file_content` to append or insert the rule into `AGENTS.md`.
4. **Track with Beads:** Ensure this system evolution is tracked via beads (e.g., `bd create --title="Auto-added rule: [Rule Name]" --type=task`).

## Context
Fulfills requirements for Bead: `wiki-by-ai-e3q`.
