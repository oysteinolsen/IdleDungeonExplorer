# Project instructions

## Project
This is a Roblox incremental idle rpg game.

## Developer context
- The developer is an experienced C#/.NET backend developer who is new to Roblox development.
- Explain Roblox-specific tools, workflows, terminology, and design choices in plain language, using .NET/backend analogies where helpful.
- Before requesting approval for a Roblox-specific decision, explain why it is needed, what changes, what remains unchanged, and the practical tradeoffs.

## Authoritative documents
- `docs/GAME_DESIGN.md`: short design index and session reading contract
- `docs/design/README.md`: roadmap-to-design-brief map; read only the active item's brief and its explicit dependencies
- `docs/DECISIONS.md`: accepted decisions and their reasoning
- `docs/ROADMAP.md`: planned milestones and work status
- `docs/CURRENT_STATE.md`: current implementation state and next task

## Working rules
- Before planning or implementing, read `docs/ROADMAP.md`, `docs/CURRENT_STATE.md`, `docs/DECISIONS.md`, and only the active roadmap brief named by `docs/design/README.md` plus any briefs it explicitly lists under **Read with**.
- Do not load `docs/design/archive/INITIAL_GAME_BRIEF.md` unless historical research or decision provenance is specifically needed.
- Do not change an accepted design decision without asking.
- Work on only one roadmap item at a time.
- Before starting a session, create a new branch to work on, unless we are continuing on a previous roadmap step.
- Before ending a session, update `docs/CURRENT_STATE.md`.
- Record important new design details in the active roadmap brief. Add cross-cutting accepted decisions to `docs/DECISIONS.md` and link affected briefs.
- Run relevant tests and review the diff before declaring work complete.
- When creating a pull request, include a plain-language summary of what was implemented, a concrete list of what to test and how to test it, and a clearly highlighted section for known or possible issues.
