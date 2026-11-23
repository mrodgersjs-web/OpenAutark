# Proof packet — skill packs (blueprint autark-skill-packs)

Date: 2026-11-23. Branch: `taste/autark-os-layer`. Repo: mrodgersjs-web/OpenAutark.

## 1. The check suite, verbatim

```
ok   layout: folders and entry files present
ok   agents: 15 agents, front matter and skills resolve
ok   skills: 24 skills, format and modes valid
ok   router: 14 routes, agents, skills and gates resolve
ok   docs: relative links and screenshots resolve
ok   docs: no secret patterns
ok   sources: 20 packs (7 vendor, 13 reference), ids unique, owners resolve, catalog.md in sync
ok   sources: agent map covers 15 agents; applied record consistent
ok   sources: remove: unedited files deleted, edited file kept, manifest updated
ok   sources: a pack containing a symlink is refused
ok   sources: fixture install: copied, renamed to <pack>--<name>, recorded in the manifest
ok   install: dry run exits 0 on an empty data folder (temp, nothing written)
ok   install: uninstall without --write refuses (non-zero exit)
ok   install: dry run wrote nothing
PASS all
```

## 2. The twenty packs, re-opened upstream

```
ok     awesome-claude-skills  (travisvn/awesome-claude-skills/.)
ok     awesome-claude-prompts  (langgptai/awesome-claude-prompts/.)
PASS packs: 20 of 20 paths still resolve
```

## 3. What was actually installed

```
installed packs (5):
  superpowers           MIT             https://github.com/obra/superpowers
      brainstorming (8 files)
      executing-plans (3 files)
      receiving-code-review (1 files)
      systematic-debugging (6 files)
      test-driven-development (2 files)
      using-git-worktrees (1 files)
      verification-before-completion (1 files)
      writing-plans (1 files)
  voltagent-subagents   MIT             https://github.com/VoltAgent/awesome-claude-code-subagents
      code-reviewer (1 files)
      qa-expert (1 files)
      security-auditor (1 files)
      business-analyst (1 files)
      product-manager (1 files)
      multi-agent-coordinator (1 files)
      workflow-orchestrator (1 files)
      competitive-analyst (1 files)
      research-analyst (1 files)
  wshobson-agents       MIT             https://github.com/wshobson/agents
      accessibility-audit (1 files)
      team-lead (1 files)
      team-delegate (1 files)
      team-spawn (1 files)
      team-status (1 files)
      avoid-ai-writing (4 files)
  context-engineering-prpMIT             https://github.com/coleam00/context-engineering-intro
      prp_base (1 files)
  fabric-patterns       MIT             https://github.com/danielmiessler/Fabric
      analyze_claims (6 files)
      create_summary (4 files)
      extract_wisdom (6 files)
      write_essay (4 files)
```

## 4. File count and archive hash

Tracked files under `autark-os/`: 86 at the commit before this packet;
working tree files: 91. Archive sha256: `c4cd94ab6fa704cda8428440786b81061a7e0a8fe1ec75b0b7886213fb872e47` (`tar -cf - autark-os`).

## 5. The reviews behind it

- Licensing and installer-security reviews, 15 findings, every disposition: `docs/design/pack-system/resolution.md`.
- Pre-commit gate history, including the escalation left open for Mike: `docs/design/precommit-gate-log.md`.
- Architecture assessment and debt: `docs/architecture/autark-repo-map.md`.
