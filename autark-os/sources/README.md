# Skill sources — twenty packs, and the rule for taking from them

`catalog.json` is the record: 20 public repositories whose skills, agents, patterns or doctrine we
borrow from when we stand up Autark's team. `catalog.md` is the same thing for a human. Neither is
a wish list: every entry carries the repo, the license, the path we take, who uses it, why, and the
risk.

## What was checked, and when

On **2026-11-23** each repo was opened through the GitHub API: existence, stars, license, and the
`take` path listed in that repo's contents. An entry whose path later 404s fails
`sh autark-os/scripts/check.sh sources`, so a dead link is caught by CI rather than by an agent at
the moment it needs the skill.

## The two modes

| Mode | Meaning | Allowed licenses |
|---|---|---|
| `vendor` | files may be copied into a workspace by `scripts/add-pack.sh --write` | MIT, Apache-2.0, BSD |
| `reference` | read, quote, link - never copy | no declared license, NOASSERTION, or a license that needs a lawyer |

Seven packs are `vendor`, thirteen are `reference` after the licensing review (`docs/design/pack-system/resolution.md`). The distinction is a legal line, not a quality
judgement: `obra/superpowers` and `wshobson/agents` are MIT and can be installed; `bmad-code-org` and
`humanlayer` are the most interesting reading in the list and cannot be copied until someone reads
their terms.

## How a pack enters a machine

```sh
sh autark-os/scripts/add-pack.sh superpowers                    # dry run: lists the skills it would copy
sh autark-os/scripts/add-pack.sh superpowers --write             # copies into <workspace>/skills/
sh autark-os/scripts/add-pack.sh bmad-method                     # reference mode: prints the URLs, copies nothing
```

Every copied skill is renamed `<pack>--<skill>` so a collision can never overwrite one of ours, the
pack's own `LICENSE`/`NOTICE` is copied beside it as `UPSTREAM-LICENSE.txt` (the MIT notice must
travel with the files), and every path is recorded in the same SHA-256 manifest the installer uses,
so `--uninstall` can remove it later. A pack containing a symlink is refused outright. Reference
packs are printed, not installed: the agent reads the page or asks a person to.

`--pin <sha>` installs only if the clone matches that commit; either way the commit SHA is printed so
an install can be traced. Pinning makes an install traceable, not safe - a person still reads what is
being installed.

## Adding the twenty-first

1. Open the repo, read the license, find the exact folder. Not the README - the folder.
2. Add one object to `catalog.json`: id, repo, stars, license, mode, take, why, owners, risk.
3. Run `sh autark-os/scripts/check.sh sources`. It fails on a duplicate id, a missing field, an
   unknown license in `vendor` mode, or a `catalog.md` that has not been regenerated.
4. Never add a pack nobody asked for. Twenty is already more than one team can absorb; the number
   that matters is how many of these an agent actually opens in a month.
