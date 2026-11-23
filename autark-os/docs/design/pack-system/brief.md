# Brief — skill packs for Autark

Date 2026-11-23. EGM step: brainstorm to brief.

## The problem, without the product

An agent team with 24 hand-written skills still does 24 things one way and everything else its own
way. Around the app there are hundreds of public skills, subagents and patterns that already solve
the specific cases - code review, planning, claim analysis, codebase knowledge - written by people
who do that work daily. The naive move is to copy them in. That breaks two things at once: licenses
(most lists carry no license, some carry code under a different one) and names (two packs both ship
`brainstorming`, and the app resolves a skill by its name).

## Who has this problem

Anyone standing up a team on Autark, and us on every new install: the first hour is always "what
does this team know how to do, and what is it about to improvise?"

## What good looks like

- A person can see the twenty sources, what each is for, and which license governs it, in one table.
- Installing one is a decision with a name: `add-pack.sh superpowers`, dry run first.
- Nothing installed can shadow our own skills, and everything installed can be removed.
- A source that disappears gets caught by CI, not by an agent at 2am.
- No file moves from a repository whose license has not been read.

## Options

1. **Copy a curated set into `autark-os/skills/`.** Simplest, worst: license text gets lost, names
   collide, and the repo becomes a fork of other people's work that we must maintain.
2. **Catalog and install on demand** (chosen). The repo holds the catalog, the policy and the
   installer; the skills live in the workspace, named `<pack>--<name>`, recorded in the manifest.
3. **Do nothing.** Defensible - twenty sources is more than one team can absorb in a month - but it
   leaves every new install starting from our 24 skills alone.

## What we will not do

No autonomous install, no bulk copy, no file from a `reference`-mode pack, no pack that ships a
script or a plugin manifest. Markdown only.

## Success, stated as a test

`sh autark-os/scripts/check.sh sources` proves four things without network access: the catalog is
consistent (20 packs, unique ids, owners that exist, licenses compatible with the mode), the human
table matches the machine file, a real install from a local fixture copies and renames correctly, and
the manifest records what was written. That is the test that must keep passing.
