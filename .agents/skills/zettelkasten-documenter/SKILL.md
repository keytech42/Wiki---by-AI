---
name: zettelkasten-documenter
description: Automatically documents, summarizes, and categorizes learning interactions into the Zettelkasten structure (00_MOCs, 10_Concepts, 20_Sessions).
---

# Zettelkasten Documenter

## Purpose
This skill aligns with the AGENTS.md instruction "위키(Wiki) 및 지식 문서화 가이드라인 (Zettelkasten)". It transforms conversational knowledge, deep dives, and solved problems into persistent, structured markdown notes.

## Triggers
- When the user explicitly requests documentation (e.g., "Document this", "Save this to wiki", "Make a note of our session").
- When the agent determines a highly valuable knowledge exchange has concluded and proactively suggests documentation (as required by AGENTS.md).

## Actions
1. **Categorize the Knowledge:**
   - `00_MOCs/` (Map of Content): If the topic bridges multiple existing concepts or establishes a new major category, update or create an MOC index.
   - `10_Concepts/` (Atomic Notes): If the knowledge is a single, focused theory, principle, or code pattern, create a note here.
   - `20_Sessions/` (Session Logs): If documenting the narrative, context, and flow of the interaction itself, create a session log.
2. **Draft the Content:**
   - Adhere to the "학습자 페르소나" (Learner Persona): Be rigorous, expansive, and include underlying principles, not just black-box solutions.
   - Follow strict markdown standards and include links to related concepts (`[[Concept Name]]` or standard markdown links).
3. **Write the Files:**
   - Use `write_to_file` to create the markdown files in the appropriate directories.
4. **Track with Beads:** Track documentation efforts with beads if part of a larger epic or task (e.g., `bd create --title="Document [Topic] into Zettelkasten"`).

## Context
Fulfills requirements for Bead: `wiki-by-ai-hyb`.
