---
name: zettelkasten-documenter
description: Automatically documents learning interactions into a Tag-based, Insight-heavy Zettelkasten structure.
---

# Zettelkasten Documenter

## Purpose
This skill aligns with the AGENTS.md instruction "위키(Wiki) 및 지식 문서화 가이드라인 (Zettelkasten)". It transforms deep dives and solved problems into persistent, highly dense markdown notes using a bottom-up graph structure.

## Triggers
- When the user explicitly requests documentation.
- When the agent determines a highly valuable knowledge exchange has concluded and proactively suggests documentation.

## Actions
1. **Categorize & Tag (Bottom-up Graph):**
   - Place files in `10_Concepts/` for atomic knowledge or `20_Sessions/` for interaction logs.
   - **CRITICAL:** Do NOT force premature linking to `00_MOCs/` (Tree structure). Instead, heavily utilize **Tag-based Multi-clustering**. Add tags in the YAML frontmatter or body (e.g., `#concept/tensor`, `#architecture/attention`) to allow natural, bottom-up knowledge graphs to emerge.

2. **Draft High-Density Content (Insight-Heavy):**
   - **DO NOT write simple summaries or mere conclusions.**
   - **Capture the Cognitive Journey:** Document the struggles, the "Why", the physical/geometric mapping, and the exact "Aha-moments" reached during the deep dive.
   - **Contrast & Context:** Always contrast the fundamental principles with the limitations of "black-box" APIs or common junior mistakes. 
   - Adhere to the "Deep-dive Learner Persona": Be mathematically and geometrically rigorous. Code should map 1:1 with theoretical concepts.

3. **Write the Files:**
   - Use `write_to_file` to create the markdown files. Ensure valid YAML frontmatter is included.

4. **Track with Beads:**
   - Track documentation efforts with beads. Ensure you use `--type=knowledge` for Zettelkasten documentations.
