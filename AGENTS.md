# OpenAutark OS operating instructions

`apps/`, `services/`, `library/`, `docs/` and `scripts/desktop-release/` are upstream code from
`teydra/OpenAutark`. This repository adds a governed operating layer on top of them. Repository files are the
control plane: read `OWNERS.yaml`, `floors.yaml` and `HARNESS.md` before changing anything.

1. Work only on paths authorized for the authenticated actor and active owner (`node scripts/check-owners.mjs`).
2. Never edit upstream app code for a governance need. `apps/**`, `services/**`, `library/**`,
   `scripts/desktop-release/**` stay merge-clean against `upstream/main`. Governance lives in the files this
   repository owns: the root contract files, `harness/`, `scripts/`, `tests/`, `blueprints/`, `docs/`,
   `research/`, `golden/`, `routes.yaml`, `floors.yaml`.
3. The live install is data, not source. `~/Library/Application Support/Autark` holds the person's settings,
   agents, memory, secrets and database. Never hand-edit it while the app runs; use the app, the `wf` client or
   the documented file contracts, take a backup first, and never print a secret value.
4. Keep the harness contract `H=(E,T,C,S,L,V)`: exit `0` means pass, `1` means hold, `2` means block.
5. Never weaken floors F1-F8, delete a verification step, or treat missing evidence as success.
6. Anything outward (messages, email, social posts, spending, publishing) stops at Gate-D until the Principal
   approves the exact text by `sha12`. Any later edit voids the approval.
7. Hosted Jev is the judge. Unreachable, errored or absent classifier evidence produces `HOLD`; it is never
   self-certified as `PASS`.
8. Run `npm test`, `python3 scripts/yaml_lint.py`, `python3 scripts/secret_scan.py` and
   `python3 scripts/doctor.py` before promotion. The doctor is read-only.
9. Truth floor: every claim in `docs/` and `research/` traces to an inspected path, a command output, an
   explicitly labelled `Inferred`, or `Not observed`. No invented services, tables, numbers or metrics.
10. One worktree, two writers: commit path-limited (`git commit -m "..." -- <your paths>`). Never
    `git add -A`, `git commit -a`, `git stash`, `git reset` or `git checkout .`.
11. No push to `main` and no pull request to `teydra/OpenAutark` without the Principal's word for that exact
    branch and text.

Use `golden/` for verification artifacts and `research/architecture/` for scans. Preserve fail-closed behavior and
deterministic output.
