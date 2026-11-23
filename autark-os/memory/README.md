# Seed memory

Autark's memory is a tree of Markdown files under `<data>/memory/`, one file per entry, in
folders by who it is for. This folder is a **seed**: facts about how this company works, written
before any work is done. Copy it in on first install, then let the team edit it like any other
memory.

- `company/` — what every agent needs: the contract, the standard, the scorecard shape.
- `branches/<area>/` — what one area knows: GTM, engineering, design, finance, security, research.
- `_folder.md` — describes what the folder is for, so a reader knows before opening files.

Rules that apply to every entry here (see `skills/memory-hygiene`): an absolute date on every
durable claim, one source per claim, contradictions reconciled on write, and no secrets — only
`secret://` handles.
