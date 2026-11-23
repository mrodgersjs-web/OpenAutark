# Resolution — pack system, after two zero-context reviews

Date 2026-11-23. Inputs: a legal/licensing reviewer and an installer-security reviewer, both fresh
context (`codex exec`), each given only file paths. 15 findings; every one has a disposition.

## Licensing

| # | Finding | Disposition | Change |
|---|---|---|---|
| L1 | MIT requires the copyright and permission notice to travel with copies | **FIXED** | `add-pack.sh` now copies the pack's `LICENSE`/`NOTICE`/`COPYING` into every installed skill as `UPSTREAM-LICENSE.txt` |
| L2 | `awesome-copilot` is mixed MIT and Apache-2.0 with per-skill NOTICE files | **FIXED** | moved from `vendor` to `reference`; individual named skills can be promoted after reading their own license |
| L3 | `awesome-claude-code` is CC BY-NC-ND, which bars commercial reuse and adaptation | **FIXED** | license recorded as `CC-BY-NC-ND-4.0`; links only, never copied |
| L4 | `awesome-claude-skills` and `awesome-claude-prompts` have no license | **FIXED** | `license_note` states: link, summarise in our own words, copy nothing |
| L5 | `anthropic-skills` has per-skill terms (four office skills Apache-2.0, `doc-coauthoring` no grant) | **FIXED** | license recorded as `mixed-per-skill` with the specific note; reference only |
| L6 | Three NOASSERTION repos hide distinct terms | **FIXED** | each carries its own `license_note` (BMad trademark terms, 12-factor Apache-2.0 plus CC BY-SA prose, MCP per-server licenses) |
| L7 | `openhands-agents` pointed at a path that no longer exists | **FIXED** | re-pointed at `.agents/skills`, verified through the API the same day |

## Installer security

| # | Finding | Disposition | Change |
|---|---|---|---|
| S1 | A pack-supplied symlink could redirect a write outside the skills folder | **FIXED** | every pack is scanned for symlinks before planning and refused; each skill is re-scanned; a symlinked destination is refused |
| S2 | The manifest temp file could be a symlink and truncate an unrelated file | **FIXED** | symlinked manifest is refused before writing |
| S3 | Tabs and newlines in pack paths could corrupt the copy plan | **FIXED** | the planner rejects any name outside `[A-Za-z0-9._-]` and any path containing control characters, and exits 3 |
| S4 | A mutable branch means unreviewed content each install | **PARTIAL** | the clone is pinned-friendly (`--pin <sha>`) and the commit SHA is printed and can be recorded; full review-before-install is a person's step, not a script's claim |
| S5 | `git clone` can run host smudge/process filters from a pack's attributes | **PARTIAL** | clone runs with `GIT_CONFIG_NOSYSTEM=1`, `core.symlinks=false`, `core.hooksPath=/dev/null` and `protocol.ext.allow=never`; a checkout can still run a configured global filter, which is a host-side risk we document rather than pretend to solve |
| S6 | A pack is agent instructions, so a malicious pack steers an agent | **OPEN, by design** | this is why `vendor` mode is limited to seven named repos, why nothing is installed without a person running `--write`, and why the reference list prints URLs instead of copying |

## What the reviews changed in substance

Two packs left the vendorable list (8 → 7), four license labels were corrected from a comfortable
"MIT-ish" to the exact terms, two behaviours changed from "trust the checkout" to "refuse the
symlink", and one documentation claim was weakened: the layer no longer implies that pinning makes a
pack safe, only traceable.

## What is still not proven

- No pack has been installed into a live 429-agent install.
- `--pin` is available but no catalog entry carries a pinned SHA yet; every entry records the commit
  it was installed from at install time instead.
- Windows was never executed; the script branches exist.
