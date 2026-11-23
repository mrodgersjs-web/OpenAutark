The operating instructions for this repository are in `AGENTS.md`. Read it first, together with `OWNERS.yaml`,
`floors.yaml` and `HARNESS.md`.

Do not edit `apps/**`, `services/**` or `library/**` (upstream `teydra/OpenAutark`). The live Autark install under
`~/Library/Application Support/Autark` is the Principal's data: read-only, secrets never printed. Harness exit codes
are `0` pass, `1` hold, `2` block. Outward actions stop at Gate-D.
