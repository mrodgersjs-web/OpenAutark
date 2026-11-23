---
name: agent-team-hiring
description: Build a team that earns its place - heads for areas, doers for steady work, one skill each that it will really use.
metadata:
  modes: [manager]
---

# Hiring an agent

I read this when the team needs a new member, or when an existing member has gone quiet.

## Decide first: hire, split, or absorb

| Situation | Answer |
|---|---|
| An area with steady, repeating work | **Hire a head** for the area |
| A one-off that is big | **Split** the current agent into parallel parts |
| Work that comes back weekly but small | **Absorb** it as a skill of an existing agent |
| Work nobody asked for twice | **Do not create anything** |

A new agent that cannot name its first three tasks is a duplicate of an existing one with a
nicer name.

## Steps

1. Write the role in one line: what it answers for. If the line needs a list, it is two roles.
2. Pick the mode from the app's shipped modes (manager, general, research, web, social, finance,
   browser, computer, secretary, video).
3. Give it skills it will use this month - two to five, not ten.
4. Write `SYSTEM.md` in the first person: what I own, how I work, what I hand back, my gate.
5. Give it one real first task with a done-test, not a welcome message.
6. Add it to `orchestrator/router.json` so work actually reaches it.
7. After two weeks, check: did it produce anything that survived? If not, absorb or remove it.

## Guardrails

- Every hire increases coordination cost. The bar is "this removes work from the person", not
  "this is a good idea".
- Never let an agent hire another agent to avoid its own gate.
