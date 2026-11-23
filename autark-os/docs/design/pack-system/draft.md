# Draft — pack system, revision 1

Date 2026-11-23. EGM step: draft.

## Shape

```
sources/catalog.json     20 packs: id, repo, stars, license, mode, take, why, owners, risk
sources/catalog.md       the same for a human, one row per pack
sources/README.md        the license policy and the four steps to add the twenty-first
scripts/add-pack.sh      dry run by default; --write copies; --from for offline/fixture; no --remove yet
tests/fixtures/pack/     one fixture skill, so the copy loop is tested without network
```

## The four decisions inside it

1. **Two modes, enforced by a check, not by a promise.** `vendor` requires MIT/Apache-2.0/BSD/ISC;
   anything else is `reference` and never gets copied. `check.sh sources` fails a `vendor` entry with
   an unlisted license.
2. **Names are rewritten on copy.** A pack skill installs as `<pack>--<name>`, and its front-matter
   `name:` is rewritten to match, so the app's resolver cannot prefer an upstream skill over ours.
3. **The catalog is data with a `take` path.** The path is verified through the GitHub API at install
   time; a repo that moved fails loudly instead of installing half a pack.
4. **The manifest is the receipt.** Same format as `install.sh` (`file <sha256> <path>`), so one
   uninstall story covers both, and an edited file is never deleted silently.

## What the first pass got wrong

Written down because it is the point of a draft: the first `add-pack.sh` resolved the workspace in
its own `if` block (duplicating `install.sh`), used `shasum` only (BSD), passed relative paths to
`cp` after the plan was computed in another directory, and left upstream skill names unchanged. All
four were caught by running it rather than reading it, and all four are fixed before this draft was
written.

## Deliberate omissions

- No `--list` and no `--remove` yet: they are blueprint steps P2 and P3, not smuggled in.
- No bulk "install everything": twenty packs at once is how a team ends up with 300 skills it cannot
  reason about.
- No automatic fetching of prompts from `data/patterns`: Fabric's patterns are a source to read, not
  an installer.

## Open questions for the reviewers

1. Is the license line strong enough to keep us out of trouble, given `NOASSERTION` repos are in the
   list as references?
2. Does the installer have a way to write outside the intended folders that I have not seen?
3. Is 20 the right number, or does the catalog itself become a maintenance burden?
