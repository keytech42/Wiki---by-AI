# Wiki - by AI (Aggressive Second Brain)

This repository is not a static wiki. It is an **Autonomous, Self-Evolving Zettelkasten** powered by a multi-agent system. It is engineered exclusively for a "Deep-dive Engineer" who demands low-level mathematical rigor, geometric mapping, and systemic perfection.

## ⚙️ Core Architecture & Functionality

### 1. Dual-Graph Synchronization (Beads ↔ Obsidian)
The space operates on a strictly separated but synchronized two-graph system:
- **Task & Context Graph (Beads):** The agent's operational memory. Every thought, investigation, and system upgrade is rigorously tracked as an issue.
- **Knowledge Graph (Obsidian Zettelkasten):** The persistent, interconnected markdown repository of atomic knowledge (`10_Concepts/`) and overarching maps (`00_MOCs/`).
- **[⛓️ Edge Connection Constraint]:** No node exists in isolation. Task dependencies registered in Beads mathematically translate into structural `[[Internal Links]]` in the resulting Markdown.

### 2. The Two-Track Typology (`knowledge` vs `meta`)
To prevent the knowledge graph from being polluted by infrastructure changes, the system enforces a strict ontology:
- `--type=knowledge`: Used exclusively for atomic concepts and theoretical deep-dives.
- `--type=meta`: Used for upgrading the agent's prompts, automating scripts, or modifying the environment.

### 3. "Cold Judge" Subagent Protocol
Before engaging in massive knowledge retrieval or architectural rabbit holes, the main agent must summon a `Cold Judge` subagent. This protocol enforces a multi-turn debate focusing purely on **ROI (Time vs. Energy)** and **Goal Alignment**, actively preventing inefficient or overly abstracted inquiries.

### 4. Talk First & 2-Turn Commit Protocol
The user retains absolute low-level control. The AI is strictly forbidden from silently mutating the system or executing Git operations.
- **Turn 1 (Verification):** The agent presents a structured diff and status report.
- **Turn 2 (Execution):** Only upon explicit user authorization does the agent close the task and commit the history.

### 5. Self-Evolving Ruleset
The space is alive. If the agent detects a repetitive task or a valuable ad-hoc workflow during a session, it proactively drafts a new `SKILL.md` or modifies `AGENTS.md` to permanently absorb that capability into its system.

---

## 📂 Physical Directory Structure
- `00_MOCs/` : Maps of Content (Navigational hubs and architecture overviews).
- `10_Concepts/` : Atomic notes (Deep-dive principles, mathematical proofs, code implementations).
- `20_Sessions/` : Narrative logs of rigorous debates and raw learning paths.
- `.agents/` : The operational brain, containing system prompts, CLI manuals, and custom skills.
