# Autark OS — the operating layer for your AI company

Autark gives you a company: a manager, specialist agents, chats, tasks, memory, your own PC.
What it does not decide for you is **how the company works** — who routes the work, which
specialists exist, what each one must hand back, which action needs your word, and how the
team proves it finished.

This folder is that layer. It is data, not code: agent definitions and skills in exactly the
format Autark already reads, a routing table, a gate ladder, seed memory, and the evidence
that the work is done. Nothing under `apps/` is touched, so `git pull upstream main` stays clean.

| | |
|---|---|
| Upstream | `teydra/OpenAutark` — Apache-2.0, Electron desktop app (runtime + Preact UI + SQLite) |
| This layer | Apache-2.0, additive: `agents/`, `skills/`, `memory/`, `orchestrator/`, `gtm/` |
| Version | 1.0.0 (2026-11-23) |
| Check | `sh autark-os/scripts/check.sh all` |
| Install | `sh autark-os/scripts/install.sh --dry-run` then without the flag |

## What you get

**One orchestrator, five heads, nine doers.** The chief of staff routes; heads own an area;
doers produce. Every agent is a `SYSTEM.md` with a name, a role, a mode and the skills it
may use — the same shape Autark ships, so the app needs no changes to read it.

**24 skills that carry the standard.** Not prompts: procedures with a stated output, a gate
and a way to prove the claim. Architecture before code, evidence before "done", a draft
before any message leaves the house.

**A gate ladder, with an honest boundary between policy and enforcement.** Autark's Security
settings are enforced by the runtime: they close files, shell, web, messages, accounts and money.
This ladder governs the *work* on top of that: reading is free, drafts are free, reversible
internal writes are logged, anything outward or any money needs your exact approval of the exact
action. The agent obeys it and the approval record proves it; the runtime does not yet inspect
which gate a task is on (the ApprovalRequest hooks appear in the app's source and land in the
installed build from 0.3.19; the build installed here on 2026-11-23 is 0.3.14). Treat the ladder
as a policy your team follows and can be audited against, not as a sandbox.

**A GTM branch that already knows the business.** ICP, signal tiers, offer ladder, sequences,
AEO surface and the scorecard, lifted from RIG's GTM studio and written so an agent can run it
without the studio.

**Evidence it is better, not just different.** `research/what-great-looks-like/` holds 18
screenshots of the category leaders (Manus, Lindy, Notion AI, Devin, OpenHands, CrewAI, Letta,
Dyad, LibreChat, Open WebUI, n8n, Claude, Codex, CrewAI and Autark itself) scored on 12
dimensions, with the gaps and the 30 moves that close them.

## The team

```
you
└── chief-of-staff            routes, filters, owns the loop, never does the work twice
    ├── head-of-gtm           pipeline, offers, outbound, content, AEO
    │   ├── outbound-strategist      signals → sequences → replies
    │   ├── content-strategist       editorial calendar, briefs, distribution
    │   ├── linkedin-writer          the writing trio: brief → craft → vocabulary
    │   ├── seo-aeo-strategist       llms.txt, citation surface, answer pages
    │   └── gtme-panel               produce → score → revise, draft-only
    ├── head-of-engineering   repos, reviews, releases
    │   ├── software-architect       inspect → blueprint → boundary check
    │   └── qa-reviewer              correctness, security, finish gate
    ├── head-of-design        brand, interface, critique
    ├── head-of-finance-ops   money, process, reporting
    ├── head-of-security      secrets, permissions, incident
    ├── research-analyst      sourced answers with a claim ledger
    ├── proof-verifier        independent check of any "done"
    └── council-reviewer      ten masters argue before anything ships
```

## First five minutes

1. **Connect one AI plan or key** in the app (Settings › Models). The team is only as good as the
   model behind it; this layer does not choose one.
2. **Decide about the public library.** Autark's own default shares a skill or note to
   `library.openautark.com` when an agent judges it worth sharing, while the app checks it for
   secrets, paths and names first. If that is not what you want, set `library.publish: false` in
   `settings.json` **before** the first working session. This layer never publishes anything.
3. **Install this layer**, then ask for one brief. If the answer does not name an owner, a gate and
   a done-test, the layer did not load - say so rather than using it.
4. **Learn the brake**: `Ctrl+Alt+Shift+X` stops every agent on the PC. Show it to anyone who will
   use this machine.

## Install

```sh
sh autark-os/scripts/install.sh                      # dry run: prints every write, changes nothing
sh autark-os/scripts/install.sh --write              # skills + agents + memory seed
sh autark-os/scripts/install.sh --write --skills-only   # skills only, app need not be running
sh autark-os/scripts/install.sh --uninstall          # preview the removal
sh autark-os/scripts/install.sh --uninstall --write  # remove only unchanged, installer-owned files
```

The data folder is found the way Autark itself finds it: `AUTARK_DATA` if set, otherwise
`~/Library/Application Support/Autark` (macOS), `~/.config/Autark` (Linux),
`%APPDATA%\Autark` (Windows).

What gets written, and why it is safe on a live install:

| Target | Rule |
|---|---|
| `<workspace>/skills/<name>/SKILL.md` | created only if the folder does not exist; never overwritten |
| agents | created **through the running app** (`wf call agents.create`), so the app's roster knows them. Dropping a folder is not enough - an agent the roster does not list is skipped |
| `<data>/memory/company/autark-os/` | only if that folder is absent; never merged into existing memory |
| `<data>/autark-os.manifest` | one line per write, with the file's SHA-256, so uninstall can tell an untouched file from one you edited |

`--uninstall` needs `--write` on purpose, deletes a file only when its hash still matches what was
installed, keeps anything you edited and says so, and archives installed agents through the app.

**Smoke test after installing**: ask the chief of staff for one brief. It should answer with an
owner, a gate and a done-test - not a paragraph of enthusiasm.

## Check

```sh
sh autark-os/scripts/check.sh all
```

Seven checks: layout, agent front matter, skill format, routing closure, link and secret
scan, install dry-run, and the whole gate in order. The blueprint that these commands verify
is `blueprints/autark-os/blueprint.md`.

## What this is not

- Not a fork of the app's behaviour, and not a marketplace of prompts.
- Not a publishing channel: nothing here is sent to the public library unless you say so.
- Not a promise of autonomy. The gates exist because an agent that can spend and publish
  without a word is a liability, not a company.

## Credits

Team patterns and the skill format come from Autark's own `apps/desktop/resources/`
(`agents/`, `skills/`, `patterns/`). Specialist methods are adapted from
[Agency Agents](https://github.com/msitarzewski/agency-agents) (MIT, 283 specialists) and
RIG GTM Studio v2's agents and skills. Each adapted file names its source at the top.
