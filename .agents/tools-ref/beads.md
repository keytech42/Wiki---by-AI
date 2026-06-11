[bd prime] If this output is truncated by your host, read the full persisted hook output before continuing; it may contain project memories and session rules not visible in the preview.

# Beads Workflow Context

> **Context Recovery**: Run `bd prime` after compaction, clear, or new session
> Hooks auto-call this in Claude Code when a beads workspace is resolved

# 🚨 SESSION CLOSE PROTOCOL 🚨

**CRITICAL**: You MUST adhere to the 2-Turn Commit Protocol when finishing work:

```
[Turn 1] Present work to user for verification. Wait for explicit approval.
[Turn 2] ONLY after approval:
[ ] 1. bd close <id>           (close the verified issues)
[ ] 2. git status              (check what changed)
[ ] 3. git add <files>         (stage code changes)
[ ] 4. git commit -m "..."     (commit code)
[ ] 5. git push                (push to remote)
```

**NEVER skip this.** Work is not done until pushed.

## Core Rules
- **Language & Context Constraint:** When creating or updating Beads issues, you MUST use **Korean**. Actively utilize flags like `--acceptance`, `--design`, and `--notes` to maximize the context density of each issue.
- **Default**: Use beads for ALL task tracking (`bd create`, `bd ready`, `bd close`)
- **Prohibited**: Do NOT use TodoWrite, TaskCreate, or markdown files for task tracking
- **Workflow**: Create beads issue BEFORE writing code, mark in_progress when starting
- **[💾 Persistent Lifeline] Memory**: Use `bd remember "insight"` for persistent knowledge across sessions. Do NOT use MEMORY.md files — they fragment across accounts. Search with `bd memories <keyword>`. (Crucial for preventing the agent from losing insights after a session ends).
- Persistence you don't need beats lost context
- Git workflow: beads auto-commit to Dolt, run `git push` at session end
- Session management: check `bd ready` for available work

## Essential Commands

### Finding Work
- **[🛡️ Hard Rule] DO NOT USE `bd list` directly.** It hides critical context (Design/Acceptance Criteria).
- `bash .agents/scripts/read_issues.sh` - Read full details of all active issues.
- `bash .agents/scripts/read_issues.sh --type=knowledge` - Filter ONLY Zettelkasten/Knowledge issues (Mentor Persona).
- `bash .agents/scripts/read_issues.sh --type=meta` - Filter ONLY System/Infra issues (System Persona).
- `bash .agents/scripts/read_issues.sh --status=open` - Filter by specific status.
- `bd ready` - Show issues ready to work (still useful for a quick check, but must follow up with `bd show`).

### Creating & Updating
- `bash .agents/scripts/create_issue.sh --title="..." --description="..." --type=knowledge|meta|task --priority=2` - New issue (CRITICAL: DO NOT use bd create directly)
  - **[🗂️ Two-Track Typology]**:
    - `--type=knowledge` : STRICTLY for Zettelkasten deep-dives, research, and documentation (Builds the Knowledge Graph).
    - `--type=meta` : STRICTLY for workspace infrastructure, agent rules, and system upgrades (Builds the Meta/System Graph).
    - `--type=task|bug` : For standard coding or bug fixes.
  - Priority: 0-4 or P0-P4 (0=critical, 2=medium, 4=backlog). NOT "high"/"medium"/"low"

  **Advanced Create Flags (Context & Structure):**
  - **[🧠 Meta-Cognitive Core]** `--acceptance="Criteria"` : Define acceptance criteria.
  - **[🧠 Meta-Cognitive Core]** `--design="Notes"` : Record design rationale and architectural decisions.
  - `--notes="Context"` : Add supplementary background context and notes.
  - `--context="String"` : Provide highly specific context for the issue.
  - **[🛠️ Skill Binding]** `--skills="Skills"` : Specify the essential agent skills/tools required to solve this issue.
  - `--parent="bd-id"` : Bind to a hierarchical parent epic/task.
  - **[⛓️ Edge Connection]** `--deps="type:id"` : Actively search for and register dependencies (blockers, dependents) when creating issues. (Exception: If it is a truly independent Root Node, avoid polluting the graph with forced connections, but you must be able to justify its isolation).
  - `--labels="a,b"` : Comma-separated labels.
  - `--estimate=60` : Time estimate in minutes.
  - `--due="tomorrow"` : Set due date (e.g., +2w, 2025-01-15).

- `bd update <id> --claim` - Claim work
- `bd update <id> --assignee=username` - Assign to someone
- `bd update <id> --title/--description/--notes/--design` - Update fields inline
- `bd note <id> "text"` - Append a quick note to the issue description.
- `bd comment <id> "text"` - Add a comment to the issue thread (useful for conversational history tracking).
- **[🔥 HIGH ROI]** `bd comment <id> --file logs.txt` - Use this as the primary method to attach unlimited context, preventing long error logs or multi-line code blocks from polluting the main issue description.
- `bd close <id>` - Mark complete
- `bd close <id1> <id2> ...` - Close multiple issues at once (more efficient)
- `bd close <id> --reason="explanation"` - Close with reason
- **Tip**: When creating multiple issues/tasks/epics, use parallel subagents for efficiency
- **WARNING**: Do NOT use `bd edit` - it opens $EDITOR (vim/nano) which blocks agents

### Dependencies & Blocking
- **[Edge Evaluation Principle]** The lifeblood of a Zettelkasten is connection. Rigorously search for existing dependencies (Edges) whenever creating a task or issue. However, if it is genuinely an independent Root Node, proudly leave it isolated rather than polluting the graph with forced connections—provided you can justify its isolation.
- **[⛓️ Edge Connection]** `bd dep add <issue> <depends-on>` - Add dependency (Essential for visualizing the relationship network).
- `bd blocked` - Show all blocked issues
- `bd show <id>` - See what's blocking/blocked by this issue
- **[📐 Geometric Mapping]** `bd graph` - Display a visual dependency graph of the entire workspace (Mandatory for structurally grasping complex dependencies during a deep-dive).

### Sync & Collaboration
- `bd dolt push` - Push beads to Dolt remote
- `bd dolt pull` - Pull beads from Dolt remote
- `bd search <query>` - Search issues by keyword

### Project Health
- `bd stats` - Project statistics (open/closed/blocked counts)
- `bd doctor` - Check for issues (sync problems, missing hooks)
- `bd doctor --check=conventions` - Check for convention drift (lint, stale, orphans)

### Quality Tools
- `bd create --validate` - Check description has required sections
- `bd config set validation.on-create warn` - Auto-validate on every create
- `bd lint` - Check existing issues for missing sections

### Lifecycle & Hygiene
- `bd defer <id> --until="date"` - Defer work to a future date
- `bd supersede <id> --with=<new-id>` - Mark issue as superseded
- `bd close <id> --suggest-next` - Show newly unblocked issues after closing
- `bd stale` - Find issues with no recent activity
- `bd orphans` - Find issues with broken dependencies
- `bd preflight` - Pre-PR checks (lint, stale, orphans)
- `bd human <id>` - Flag for human decision (list/respond/dismiss)

### Structured Workflows
- `bd formula list` - See available workflow templates
- `bd mol pour <name>` - Start structured workflow from formula

## Common Workflows

**Starting work:**
```bash
bd ready           # Find available work
bd show <id>       # Review issue details
bd update <id> --claim  # Claim it
```

**Completing work (2-Turn Commit Protocol):**
```bash
# TURN 1: STOP. Present your work to the user for verification. Do NOT close the issue or commit yet.
# TURN 2: Only after receiving explicit user approval ("Proceed" or "Commit"):
bd close <id1> <id2> ...    # Close all verified issues
git add . && git commit -m "..."  # Commit code changes
git push                    # Push to remote
```

**Creating dependent work:**
```bash
# Run bd create commands in parallel (CRITICAL: Use the wrapper script)
bash .agents/scripts/create_issue.sh --title="Implement feature X" --description="Why this issue exists and what needs to be done" --type=task
bash .agents/scripts/create_issue.sh --title="Write tests for X" --description="Why this issue exists and what needs to be done" --type=task
bd dep add beads-yyy beads-xxx  # Tests depend on Feature (Feature blocks tests)
```
